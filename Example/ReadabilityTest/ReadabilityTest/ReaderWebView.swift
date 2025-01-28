import SwiftUI
import WebUI
import WebKit
import Readability

struct ReaderWebView: View {
    @State var content: String?
    @State var configuration: WKWebViewConfiguration?
    @State var isLoading = false
    @State var urlString = ""
    @State var isPresented = true

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
            } else {
                ProgressView()
            }
        }
        .task {
            configuration = try? await Readability.createReadableWebViewConfiguration()
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

final class ReaderUIDelegate: NSObject, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
