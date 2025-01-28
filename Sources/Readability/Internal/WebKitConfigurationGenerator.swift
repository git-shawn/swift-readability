import Foundation
import WebKit

@MainActor
enum WebKitConfigurationGenerator {
    static func createReadableWebViewConfiguration(
        options: Readability.Options? = nil
    ) async throws -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let script = try await ReadabilityScriptGenerator().generateInteractiveScript(options: options)

        let documentEndScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        let documentStartScript = WKUserScript(
            source: "document.documentElement.style.visibility = 'hidden';",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        configuration.userContentController.addUserScript(documentEndScript)
        configuration.userContentController.addUserScript(documentStartScript)

        return configuration
    }
}
