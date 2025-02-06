import ReadabilityCore
import SwiftUI
import WebKit

/// A runner class responsible for processing HTML content and producing a `ReadabilityResult`.
/// This class uses a WKWebView to load HTML and execute JavaScript for parsing.
@MainActor
final class ReadabilityRunner {
    private let webView: WKWebView

    // The message handler that listens for events from the injected JavaScript.
    private weak var messageHandler: ReadabilityMessageHandler<EmptyContentGenerator>?
    // The script loader for fetching JavaScript resources from the bundle.
    private let scriptLoader = ScriptLoader(bundle: .module)

    private let encoder = JSONEncoder()

    init() {
        let configuration = WKWebViewConfiguration()
        let messageHandler = ReadabilityMessageHandler(
            mode: .generateReadabilityResult,
            readerContentGenerator: EmptyContentGenerator()
        )

        configuration.userContentController.add(messageHandler, name: "readabilityMessageHandler")

        self.messageHandler = messageHandler
        webView = WKWebView(frame: .zero, configuration: configuration)
    }

    func parseHTML(
        _ html: String,
        options: Readability.Options?,
        baseURL: URL? = nil
    ) async throws -> ReadabilityResult {
        let shouldSanitize = options?.shouldSanitize ?? false
        let script = try await scriptLoader
            .load(shouldSanitize ? .readabilitySanitized : .readabilityBasic)
            .replacingOccurrences(
                of: "__READABILITY_OPTION__",
                with: generateJSONOptions(options: options)
            )

        let endScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        webView.configuration.userContentController.addUserScript(endScript)
        webView.loadHTMLString(html, baseURL: baseURL)

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.messageHandler?.subscribeEvent { event in
                switch event {
                case let .contentParsed(readabilityResult):
                    continuation.resume(returning: readabilityResult)
                    self?.messageHandler?.subscribeEvent(nil)
                case let .availabilityChanged(availability):
                    if availability == .unavailable {
                        continuation.resume(throwing: Error.readerIsUnavailable)
                        self?.messageHandler?.subscribeEvent(nil)
                    }
                default:
                    break
                }
            }
        }
    }
}

extension ReadabilityRunner {
    private func generateJSONOptions(options: Readability.Options?) throws -> String {
        if let options = options {
            let data = try encoder.encode(options)
            return String(data: data, encoding: .utf8) ?? "{}"
        } else {
            return "{}"
        }
    }
}

extension ReadabilityRunner {
    /// Errors that can occur during HTML parsing.
    enum Error: Swift.Error {
        /// Indicates that the reader became unavailable during parsing.
        case readerIsUnavailable
    }
}

/// A placeholder content generator that conforms to `ReaderContentGeneratable` and does not generate any content.
private struct EmptyContentGenerator: ReaderContentGeneratable {
    func generate(_: ReadabilityResult, initialStyle _: ReaderStyle) async -> String? {
        nil
    }
}
