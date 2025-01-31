import WebKit
import ReadabilityCore

public extension WKWebView {
    func setStyle(_ style: ReaderStyle) async throws {
        let runner = WebViewJavaScriptRunner(webView: self)
        let styleSetter = ReaderStyleSetter(runner: runner)
        try await styleSetter.set(style: style)
    }
}
