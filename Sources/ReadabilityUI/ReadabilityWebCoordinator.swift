import SwiftUI
import WebKit
import ReadabilityCore

@MainActor
public final class ReadabilityWebCoordinator: ObservableObject {
    private weak var messageHandler: ReadabilityMessageHandler<ReaderContentGenerator>?
    private weak var configuration: WKWebViewConfiguration?

    private let scriptLoader = ScriptLoader(bundle: .module)
    private let messageHandlerName = "readabilityMessageHandler"

    private var contentParsed: (@Sendable (_ html: String) -> Void)?
    private var availabilityChanged: (@Sendable (_ availability: ReaderAvailability) -> Void)?

    public let initialStyle: ReaderStyle

    public init(initialStyle: ReaderStyle) {
        self.initialStyle = initialStyle
    }

    public func createReadableWebViewConfiguration() async throws -> WKWebViewConfiguration {
        async let documentStartStringTask = scriptLoader.load(.atDocumentStart)
        async let documentEndStringTask = scriptLoader.load(.atDocumentEnd)

        let (documentStartString, documentEndString) = try await (documentStartStringTask, documentEndStringTask)

        let documentStartScript = WKUserScript(
            source: documentStartString,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        let documentEndScript = WKUserScript(
            source: documentEndString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        let configuration = WKWebViewConfiguration()
        let messageHandler = ReadabilityMessageHandler(
            mode: .generateReaderHTML(initialStyle: initialStyle),
            readerContentGenerator: ReaderContentGenerator()
        )

        self.configuration = configuration
        self.messageHandler = messageHandler

        configuration.userContentController.addUserScript(documentStartScript)
        configuration.userContentController.addUserScript(documentEndScript)
        configuration.userContentController.add(messageHandler, name: messageHandlerName)

        messageHandler.eventHandler = { [weak self] event in
            switch event {
            case .availabilityChanged(let availability):
                self?.availabilityChanged?(availability)
            case .contentParsedAndGeneratedHTML(html: let html):
                self?.contentParsed?(html)
            case .contentParsed:
                break
            }
        }

        return configuration
    }

    deinit {
        MainActor.assumeIsolated {
            configuration?.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
            configuration?.userContentController.removeAllUserScripts()
        }
    }

    public func contentParsed(_ operation: @Sendable @escaping (_ html: String) -> Void) {
        self.contentParsed = operation
    }

    public func availabilityChanged(_ operation: @Sendable @escaping (_ availability: ReaderAvailability) -> Void) {
        self.availabilityChanged = operation
    }
}

public extension View {
    func onReadableContentParsed(
        using coordinator: ReadabilityWebCoordinator,
        perform action: @MainActor @escaping (_ html: String) -> Void
    ) -> some View {
        onAppear {
            coordinator.contentParsed { html in
                Task { @MainActor in
                    action(html)
                }
            }
        }
    }

    func onReaderAvailabilityChanged(
        using coordinator: ReadabilityWebCoordinator,
        perform action: @MainActor @escaping (_ availability: ReaderAvailability) -> Void
    ) -> some View {
        onAppear {
            coordinator.availabilityChanged { availability in
                Task { @MainActor in
                    action(availability)
                }
            }
        }
    }
}
