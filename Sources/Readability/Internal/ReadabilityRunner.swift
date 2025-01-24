import SwiftUI
import WebKit

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

    func parseHTML(_ html: String, baseURL: URL? = nil) async throws -> ReadabilityResult {
        try await loadHTML(html, baseURL: baseURL)
        let articleJSON = try await parseWithReadability()
        guard let data = articleJSON.data(using: .utf8) else {
            throw Error.failedToConvertToData
        }
        return try JSONDecoder().decode(ReadabilityResult.self, from: data)
    }

    private func loadHTML(_ html: String, baseURL: URL?) async throws {
        webView.loadHTMLString(html, baseURL: baseURL)
        try await navigationDelegate.waitForNavigationFinished()
    }

    private func parseWithReadability() async throws -> String {
        let script = try await scriptGenerator.generateNonInteractiveScript()

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
    private var continuation: CheckedContinuation<Void, Error>?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        continuation?.resume(returning: ())
        continuation = nil
    }

    func waitForNavigationFinished() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
}
