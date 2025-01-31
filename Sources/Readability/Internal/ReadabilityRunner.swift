import SwiftUI
import WebKit
import ReadabilityCore

@MainActor
final class ReadabilityRunner {
    private let webView: WKWebView

    private weak var messageHandler: ReadabilityMessageHandler<EmptyContentGenerator>?
    private let scriptLoader = ScriptLoader(bundle: .module)
    private let encoder = JSONEncoder()

    private var transaction = false

    init() {
        let configuration = WKWebViewConfiguration()
        let messageHandler = ReadabilityMessageHandler(
            mode: .generateReadabilityResult,
            readerContentGenerator: EmptyContentGenerator()
        )

        configuration.userContentController.add(messageHandler, contentWorld: .defaultClient, name: "readabilityMessageHandler")

        self.messageHandler = messageHandler
        self.webView = WKWebView(frame: .zero, configuration: configuration)
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
                with: try generateJSONOptions(options: options)
            )

        let endScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true,
            in: .defaultClient
        )

        webView.configuration.userContentController.addUserScript(endScript)
        webView.loadHTMLString(html, baseURL: baseURL)

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.messageHandler?.subscribeEvent { event in
                switch event {
                case let .contentParsed(readabilityResult):
                    continuation.resume(returning: readabilityResult)
                case let .availabilityChanged(availability):
                    if availability == .unavailable {
                        continuation.resume(throwing: Error.readerIsUnavailable)
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
        if let options {
            let data = try encoder.encode(options)
            return String(data: data, encoding: .utf8) ?? "{}"
        } else {
            return "{}"
        }
    }
}

extension ReadabilityRunner {
    enum Error: Swift.Error {
        case readerIsUnavailable
    }
}

private struct EmptyContentGenerator: ReaderContentGeneratable {
    func generate(_ readabilityResult: ReadabilityResult, initialStyle: ReaderStyle) async -> String? {
        nil
    }
}
