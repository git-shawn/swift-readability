import SwiftUI
import WebKit
import ReadabilityCore

/// A coordinator that manages a WKWebView configured for reader mode.
/// It sets up the necessary scripts and message handlers to parse content and manage reader mode availability.
@MainActor
public final class ReadabilityWebCoordinator: ObservableObject {
    // A weak reference to the message handler that processes JavaScript messages.
    private weak var messageHandler: ReadabilityMessageHandler<ReaderContentGenerator>?
    // A weak reference to the WKWebView configuration.
    private weak var configuration: WKWebViewConfiguration?

    private let scriptLoader = ScriptLoader(bundle: .module)
    private let messageHandlerName = "readabilityMessageHandler"

    // Closure called when readable content is parsed.
    private var contentParsed: (@Sendable (_ html: String) -> Void)?
    // Closure called when the reader availability changes.
    private var availabilityChanged: (@Sendable (_ availability: ReaderAvailability) -> Void)?

    /// The initial style to apply to the reader content.
    public let initialStyle: ReaderStyle

    /// Initializes a new `ReadabilityWebCoordinator` with the specified initial style.
    ///
    /// - Parameter initialStyle: The initial `ReaderStyle` to use.
    public init(initialStyle: ReaderStyle) {
        self.initialStyle = initialStyle
    }

    /// Creates and configures a `WKWebViewConfiguration` for reader mode.
    ///
    /// - Returns: A configured `WKWebViewConfiguration` with injected scripts and message handlers.
    /// - Throws: An error if script loading fails.
    public func createReadableWebViewConfiguration() async throws -> WKWebViewConfiguration {
        // Load scripts for document start and document end asynchronously.
        async let documentStartStringTask = scriptLoader.load(.atDocumentStart)
        async let documentEndStringTask = scriptLoader.load(.atDocumentEnd)

        let (documentStartString, documentEndString) = try await (documentStartStringTask, documentEndStringTask)

        // Create user scripts for injection.
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

    /// Registers a closure to be called when readable content is parsed.
    ///
    /// - Parameter operation: A closure that receives the generated HTML as a `String`.
    public func contentParsed(_ operation: @Sendable @escaping (_ html: String) -> Void) {
        self.contentParsed = operation
    }

    /// Registers a closure to be called when the reader availability changes.
    ///
    /// - Parameter operation: A closure that receives the new `ReaderAvailability` status.
    public func availabilityChanged(_ operation: @Sendable @escaping (_ availability: ReaderAvailability) -> Void) {
        self.availabilityChanged = operation
    }
}

public extension View {
    /// Adds an action to perform when readable content is parsed.
    ///
    /// - Parameters:
    ///   - coordinator: The `ReadabilityWebCoordinator` managing reader mode.
    ///   - action: The action to perform with the generated HTML content.
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

    /// Adds an action to perform when the reader availability changes.
    ///
    /// - Parameters:
    ///   - coordinator: The `ReadabilityWebCoordinator` managing reader mode.
    ///   - action: The action to perform with the new availability status.
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
