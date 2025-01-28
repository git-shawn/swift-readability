import SwiftUI
import WebKit
import JavaScriptCore

@MainActor
final class ReadabilityRunner {
    let webView: WKWebView

    private let navigationDelegate = NavigationDelegate()
    private let scriptGenerator = ReadabilityScriptGenerator()

    init() {
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.navigationDelegate = navigationDelegate
    }

    func parseHTML(
        _ html: String,
        options: Readability.Options?,
        baseURL: URL? = nil
    ) async throws -> ReadabilityResult {
        await loadHTML(html, baseURL: baseURL)

        let articleJSON = try await parseWithReadability(options: options)

        guard let data = articleJSON.data(using: .utf8) else {
            throw Error.failedToConvertToData
        }

        return try JSONDecoder().decode(ReadabilityResult.self, from: data)
    }
}

extension ReadabilityRunner {
    private func loadHTML(_ html: String, baseURL: URL?) async {
        webView.loadHTMLString(html, baseURL: baseURL)
        await navigationDelegate.waitForNavigationFinished()
    }

    private func parseWithReadability(options: Readability.Options?) async throws -> String {
        let script = try await scriptGenerator.generateNonInteractiveScript(options: options)

        guard let result = try await webView.evaluateJavaScript(script)
        else {
            throw Error.failedToEvaluateJavaScript
        }
        return result
    }
}

extension ReadabilityRunner {
    enum Error: Swift.Error {
        case failedToEvaluateJavaScript
        case failedToConvertToData
    }
}

private final class NavigationDelegate: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Never>?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        continuation?.resume(returning: ())
        continuation = nil
    }

    func waitForNavigationFinished() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
