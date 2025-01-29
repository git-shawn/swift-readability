import SwiftUI
import WebUI
import WebKit
import ReadabilityUI

struct ReadabilityUIView: View {
    @State var content: String?
    @State var configuration: WKWebViewConfiguration? = .init()
    @State var isLoading = false
    @State var urlString = ""
    @State var isPresented = true

    @StateObject private var webCoordinator = ReadabilityWebCoordinator()

    var body: some View {
        WebViewReader { proxy in
            if let configuration {
                WebView(configuration: configuration)
                    .uiDelegate(ReaderUIDelegate())
                    .searchable(text: $urlString, isPresented: $isPresented)
                    .onSubmit(of: .search) {
                        withLoading {
                            if let url = URL(string: urlString) {
                                proxy.load(request: URLRequest(url: url))
                            }
                        }
                    }
                    .onReadabilityContentParsed(using: webCoordinator) { html in
                        Task { @MainActor in
                            proxy.loadHTMLString(html, baseURL: nil)
                        }
                    }
            } else {
                ProgressView()
            }
        }
        .task {
            configuration = try? await webCoordinator.createReadableWebViewConfiguration()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }

    }

    private func withLoading(_ operation: @escaping () async throws -> Void) {
        isLoading = true
        Task {
            do {
                try await operation()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

final class ReadabilityUIDelegate: NSObject, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
