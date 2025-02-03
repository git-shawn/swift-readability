import WebKit
import ReadabilityCore

public extension WKWebView {
    func setStyle(_ style: ReaderStyle) async throws {
        try await getReaderController().set(style: style)
    }

    func showReaderContent(with html: String) async throws {
        try await getReaderController().showReaderContent(with: html)
    }

    func hideReaderOverlay() async throws {
        try await getReaderController().hideReaderOverlay()
    }

    func isReaderMode() async throws -> Bool {
        try await getReaderController().isReaderMode()
    }

    private func getReaderController() -> ReaderController<WebViewJavaScriptRunner> {
        let runner = WebViewJavaScriptRunner(webView: self)
        return ReaderController(runner: runner)
    }
}
