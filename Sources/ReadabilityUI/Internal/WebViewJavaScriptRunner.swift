import WebKit

struct WebViewJavaScriptRunner: WebViewJavaScriptRunnable {
    let webView: WKWebView

    func evaluate(_ script: String) async throws -> Any? {
        webView.evaluateJavaScript(
            script,
            completionHandler: nil
        )
    }
}
