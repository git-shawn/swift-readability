import WebKit

struct WebViewJavaScriptRunner: WebViewJavaScriptRunnable {
    let webView: WKWebView

    func evaluate(_ script: String) async throws {
        webView.evaluateJavaScript(
            script,
            completionHandler: nil
        )
    }
}
