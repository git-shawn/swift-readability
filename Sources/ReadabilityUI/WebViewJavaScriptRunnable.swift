import WebKit

public protocol WebViewJavaScriptRunnable {
    func evaluate(_ script: String, contentWorld: WKContentWorld) async throws
}
