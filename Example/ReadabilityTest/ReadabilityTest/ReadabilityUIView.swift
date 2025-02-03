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
            let readerController = ReaderController(runner: JSRunner(proxy: proxy))

            if let configuration {
                VStack(spacing: 0) {
                    ProgressView(value: proxy.estimatedProgress, total: 1)
                        .progressViewStyle(.linear)
                    WebView(configuration: configuration)
                        .uiDelegate(ReadabilityUIDelegate())
                        .navigationDelegate(
                            NavigationDelegate {
                                Task { @MainActor in
                                    isReaderPresenting = try await readerController.isReaderMode()
                                }
                            }
                        )
                        .ignoresSafeArea(edges: .bottom)
                        .searchable(text: $urlString, isPresented: $isPresented)
                        .onSubmit(of: .search) {
                            withLoading {
                                if let url = URL(string: urlString) {
                                    proxy.load(request: URLRequest(url: url))
                                }
                            }
                        }
                        .onReadableContentParsed(using: webCoordinator) { html in
                            if let url = proxy.url {
                                readerHTMLCaches[url] = html
                            }
                        }
                        .onReaderAvailabilityChanged(using: webCoordinator) { availability in
                            self.isReaderAvailable = availability == .available
                        }
                        .safeAreaInset(edge: .bottom) {
                            bottomBar(proxy: proxy, readerController: readerController)
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

    private func bottomBar(proxy: WebViewProxy, readerController: ReaderController<JSRunner>) -> some View {
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

                if let url = proxy.url,
                   let html = readerHTMLCaches[url]
                {
                    Button {
                        Task {
                            if isReaderPresenting {
                                try await readerController.hideReaderOverlay()
                            } else {
                                try await readerController.showReaderContent(with: html)
                            }
                            isReaderPresenting.toggle()
                        }
                    } label: {
                        Image(systemName: "text.page")
                            .resizable()
                            .scaledToFit()
                    }
                    .symbolVariant(isReaderPresenting ? .fill : .none)

                    Menu {
                        Menu("Theme") {
                            ForEach(ReaderStyle.Theme.allCases, id: \.self) { theme in
                                Button(theme.rawValue) {
                                    Task {
                                        try! await readerController.set(theme: theme)
                                    }
                                }
                            }
                        }
                        Menu("FontSize") {
                            ForEach(ReaderStyle.FontSize.allCases, id: \.self) { fontSize in
                                Button(fontSize.rawValue.description) {
                                    Task {
                                        try! await readerController.set(fontSize: fontSize)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .disabled(!isReaderPresenting)
                }
            }
            .frame(width: 15)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.capsule)
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

final class NavigationDelegate: NSObject, WKNavigationDelegate {
    let didFinish: () -> Void

    init(didFinish: @escaping () -> Void) {
        self.didFinish = didFinish
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish()
    }
}

@MainActor
struct JSRunner: WebViewJavaScriptRunnable {
    let proxy: WebViewProxy

    func evaluate(_ script: String) async throws -> Any? {
        try await proxy.evaluateJavaScript(script)
    }
}
