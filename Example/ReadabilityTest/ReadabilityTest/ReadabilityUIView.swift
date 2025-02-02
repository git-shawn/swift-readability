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
    @State var readerHTMLCaches: [URL: String] = [:]
    @State var isReaderAvailable = false
    @State var isReaderPresenting = false

    private let webCoordinator = ReadabilityWebCoordinator(initialStyle: .init(theme: .dark, fontSize: .size5))

    var body: some View {
        WebViewReader { proxy in
            if let configuration {
                VStack {
                    ProgressView(value: proxy.estimatedProgress, total: 1)
                        .progressViewStyle(.linear)
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
                            if let url = URL(string: urlString) {
                                readerHTMLCaches[url] = html
                            }
                        }
                        .onReaderAvailabilityChanged(using: webCoordinator) { availability in
                            self.isReaderAvailable = availability == .available
                        }
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 12) {
                                Group {
                                    Button {
                                        proxy.goBack()
                                    } label: {
                                        Image(systemName: "chevron.backward")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .disabled(!proxy.canGoBack)
                                    Button {
                                        proxy.goForward()
                                    } label: {
                                        Image(systemName: "chevron.forward")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .disabled(!proxy.canGoForward)
                                    if let url = URL(string: urlString),
                                       let html = readerHTMLCaches[url]
                                    {
                                        Button {
                                            if isReaderPresenting, let url = URL(string: urlString) {
                                                proxy.load(request: URLRequest(url: url))
                                            } else {
                                                proxy.loadHTMLString(html, baseURL: nil)
                                            }
                                            isReaderPresenting.toggle()
                                        } label: {
                                            Image(systemName: "text.page")
                                                .resizable()
                                                .scaledToFit()
                                        }
                                        .symbolVariant(isReaderPresenting ? .fill : .none)
                                        Button {
                                            Task {
                                                let setter = ReaderStyleSetter(runner: JSRunner(proxy: proxy))
                                                try! await setter.set(style: .init(theme: .sepia, fontSize: .size10))
                                            }
                                        } label: {
                                            Image(systemName: "circle")
                                        }
                                    }
                                }
                                .frame(width: 15)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(.capsule)
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

@MainActor
struct JSRunner: WebViewJavaScriptRunnable {
    let proxy: WebViewProxy

    func evaluate(_ script: String, contentWorld: WKContentWorld) async throws {
        _ = try await proxy.evaluateJavaScript(script)
    }
}
