import SwiftUI
import WebKit

@MainActor
final class ReadabilityDaemon: ObservableObject {
    private let runner = ReadabilityRunner()

    var webView: WKWebView {
        runner.webView
    }

    func parseHTML(_ html: String, baseURL: URL? = nil) async throws -> ReadabilityResult {
        try await runner.parseHTML(html, baseURL: baseURL)
    }
}
