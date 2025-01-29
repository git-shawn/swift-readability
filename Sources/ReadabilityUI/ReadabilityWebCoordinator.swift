import SwiftUI
import WebKit
import ReadabilityCore

@MainActor
public final class ReadabilityWebCoordinator: ObservableObject {
    private let scriptLoader = ScriptLoader()
    private weak var messageHandler: ReadabilityMessageHandler?
    private weak var configuration: WKWebViewConfiguration?

    public init() {
    }

    public func createReadableWebViewConfiguration() async throws -> WKWebViewConfiguration {
        let script = try await scriptLoader.load(.atDocumentStart)

        let documentStartScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true,
            in: .defaultClient
        )
        let documentEndScript = WKUserScript(
            source: "window.__swift_readability__.checkReadability()",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true,
            in: .defaultClient
        )

        let configuration = WKWebViewConfiguration()
        let messageHandler = ReadabilityMessageHandler()
        self.configuration = configuration
        self.messageHandler = messageHandler

        configuration.userContentController.addUserScript(documentStartScript)
        configuration.userContentController.addUserScript(documentEndScript)
        configuration.userContentController.add(messageHandler, contentWorld: .defaultClient, name: "readabilityMessageHandler")

        return configuration
    }

    deinit {
        MainActor.assumeIsolated {
            configuration?.userContentController.removeScriptMessageHandler(forName: "readabilityMessageHandler", contentWorld: .defaultClient)
            configuration?.userContentController.removeAllUserScripts()
        }
    }

    public func contentParsed(_ operation: @Sendable @escaping (String) -> Void) {
        messageHandler?.contentParsed = operation
    }
}

public extension View {
    func onReadabilityContentParsed(
        using coordinator: ReadabilityWebCoordinator,
        perform action: @Sendable @escaping (String) -> Void
    ) -> some View {
        onAppear {
            coordinator.contentParsed(action)
        }
    }
}

final class ReadabilityMessageHandler: NSObject, WKScriptMessageHandler {
    private let readerContentGenerator = ReaderContentGenerator()
    var contentParsed: (@Sendable (String) -> Void)?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? [String: Any],
              let typeString = message["Type"] as? String,
              let type = ReadabilityMessageType(rawValue: typeString),
              let value = message["Value"]
        else {
            return
        }
        switch type {
        case .stateChange:
            print(value)
        case .contentParsed:
            Task.detached { [weak self] in
                if let valueDic = value as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: valueDic, options: []),
                   let result = try? JSONDecoder().decode(ReadabilityResult.self, from: data),
                   let html = await self?.readerContentGenerator.generate(result, initialStyle: .init(theme: .dark, fontSize: .size8))
                {
                    await self?.contentParsed?(html)
                }
            }
        }
    }
}
