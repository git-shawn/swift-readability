import SwiftUI
import WebKit

public enum Readability {
    @MainActor
    private class DaemonHolder {
        static let shared = DaemonHolder()
        weak var daemon: ReadabilityDaemon?
    }

    @MainActor
    static func setDaemon(_ daemon: ReadabilityDaemon?) {
        DaemonHolder.shared.daemon = daemon
    }

    @MainActor
    public static func createReadableWebViewConfiguration() async throws -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let script = try await ReadabilityScriptGenerator().generateInteractiveScript()

        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        configuration.userContentController.addUserScript(userScript)

        return configuration
    }

    public static func parse(html: String, baseURL: URL? = nil) async throws -> ReadabilityResult {
        guard let daemon = await DaemonHolder.shared.daemon else {
            throw Error.daemonNotLaunched
        }
        return try await daemon.parseHTML(html, baseURL: baseURL)
    }

    public static func parse(url: URL) async throws -> ReadabilityResult {
        guard let daemon = await DaemonHolder.shared.daemon else {
            throw Error.daemonNotLaunched
        }
        let html = try await HTMLFetcher().fetch(url: url)
        return try await daemon.parseHTML(html, baseURL: url)
    }
}

extension Readability {
    public enum Error: LocalizedError {
        case daemonNotLaunched

        public var errorDescription: String? {
            switch self {

            case .daemonNotLaunched:
                "Daemon not launched. Please add the .launchReadabilityDaemon() modifier to the View where you intend to use Readability."
            }
        }
    }
}
