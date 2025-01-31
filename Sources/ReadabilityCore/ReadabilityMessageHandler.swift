import Foundation
import WebKit

@MainActor
package final class ReadabilityMessageHandler<Generator: ReaderContentGeneratable>: NSObject, WKScriptMessageHandler {
    package enum Mode {
        case generateReaderHTML(initialStyle: ReaderStyle)
        case generateReadabilityResult
    }

    package enum Event {
        case contentParsedAndGeneratedHTML(html: String)
        case contentParsed(readabilityResult: ReadabilityResult)
        case availabilityChanged(availability: ReaderAvailability)
    }

    private let readerContentGenerator: Generator
    private let mode: Mode

    package var eventHandler: (@MainActor @Sendable (Event) -> Void)?

    package init(mode: Mode, readerContentGenerator: Generator) {
        self.mode = mode
        self.readerContentGenerator = readerContentGenerator
    }

    package func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? [String: Any],
              let typeString = message["Type"] as? String,
              let type = ReadabilityMessageType(rawValue: typeString),
              let value = message["Value"]
        else {
            return
        }

        switch type {
        case .stateChange:
            if let availability = ReaderAvailability(rawValue: value as? String ?? "") {
                eventHandler?(.availabilityChanged(availability: availability))
            }
        case .contentParsed:
            Task.detached { [weak self, mode] in
                if let jsonString = value as? String,
                   let jsonData = jsonString.data(using: .utf8),
                   let result = try? JSONDecoder().decode(ReadabilityResult.self, from: jsonData)
                {
                    switch mode {
                    case .generateReaderHTML(let initialStyle):
                        if let html = await self?.readerContentGenerator.generate(result, initialStyle: initialStyle) {
                            await self?.eventHandler?(.contentParsedAndGeneratedHTML(html: html))
                        }
                    case .generateReadabilityResult:
                        await self?.eventHandler?(.contentParsed(readabilityResult: result))
                    }
                }
            }
        }
    }

    package func subscribeEvent(_ operation: @MainActor @Sendable @escaping (Event) -> Void) {
        eventHandler = operation
    }
}
