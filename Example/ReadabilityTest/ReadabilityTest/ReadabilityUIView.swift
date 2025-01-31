import SwiftUI
import WebUI
import WebKit
import ReadabilityUI

struct ReaderWebView: View {
    @State var content: String?
    @State var configuration: WKWebViewConfiguration?
    @State var isLoading = false
    @State var urlString = ""
    @State var isPresented = true
    @State var html: String?
    @State var isReaderAvailable = false
    @State var isReaderPresenting = false

    private let webCoordinator = ReadabilityWebCoordinator(initialStyle: .init(theme: .dark, fontSize: .size5))

    var body: some View {
        WebViewReader { proxy in
            if let configuration {
                WebView(configuration: configuration)
                    .uiDelegate(ReadabilityUIDelegate())
                    .navigationDelegate(NavigationDelegate())
                    .searchable(text: $urlString, isPresented: $isPresented)
                    .onSubmit(of: .search) {
                        withLoading {
                            if let url = URL(string: urlString) {
                                proxy.load(request: URLRequest(url: url))
                            }
                        }
                    }
                    .onReadableContentParsed(using: webCoordinator) { html in
                        self.html = html
                    }
                    .onReaderAvailabilityChanged(using: webCoordinator) { availability in
                        self.isReaderAvailable = availability == .available
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if let html {
                            Button {
                                if isReaderPresenting, let url = URL(string: urlString) {
                                    proxy.goBack()
                                } else {
                                    proxy.loadHTMLString(html, baseURL: nil)
                                }
                                isReaderPresenting.toggle()
                            } label: {
                                Image(systemName: "text.page")
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(.circle)
                            }
                            .symbolVariant(isReaderPresenting ? .fill : .none)
                            .offset(x: -50, y: -50)
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

@MainActor
final class NavigationDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
//            try await webView.setStyle(.init(theme: .dark, fontSize: .size1))
        }
    }
}
