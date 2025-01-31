import WebKit

struct WebViewJavaScriptRunner: WebViewJavaScriptRunnable {
    let webView: WKWebView

    func evaluate(_ script: String, contentWorld: WKContentWorld) async throws {
        await webView.evaluateJavaScript(
            script,
            in: nil,
            in: contentWorld,
            completionHandler: nil
        )
    }
}
