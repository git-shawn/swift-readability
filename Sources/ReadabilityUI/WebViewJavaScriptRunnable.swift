import WebKit

@MainActor
public protocol WebViewJavaScriptRunnable {
    func evaluate(_ script: String) async throws
}
