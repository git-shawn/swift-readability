import Foundation
import SwiftUI
import WebKit

public extension View {
    func launchReadabilityDaemon() -> some View {
        self.modifier(LaunchReadabilityDaemonViewModifier())
    }
}

private struct HiddenWebViewContainer: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        container.isHidden = true
        webView.frame = .zero
        webView.isHidden = true
        container.addSubview(webView)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private struct LaunchReadabilityDaemonViewModifier: ViewModifier {
    @StateObject private var daemon = ReadabilityDaemon()

    func body(content: Content) -> some View {
        content
            .onAppear {
                Task { @MainActor in
                    Readability.setDaemon(daemon)
                }
            }
            .onDisappear {
                Task { @MainActor in
                    Readability.setDaemon(nil)
                }
            }
            .background(
                HiddenWebViewContainer(webView: daemon.webView)
                    .frame(width: 0, height: 0)
                    .hidden()
            )
    }
}
