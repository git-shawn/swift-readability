import Foundation
import WebKit
import ReadabilityCore

@MainActor
public struct ReaderController<Runner: WebViewJavaScriptRunnable> {
    private let namespace = "window.__swift_readability__"
    private let runner: Runner
    private let encoder = JSONEncoder()

    public init(runner: Runner) {
        self.runner = runner
    }

    public func set(style: ReaderStyle) async throws {
        let jsonData = try encoder.encode(style)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await runner.evaluate(
            "\(namespace).setStyle(\(jsonString));0"
        )
    }

    public func set(theme: ReaderStyle.Theme) async throws {
        let jsonData = try encoder.encode(theme)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await runner.evaluate("\(namespace).setTheme(\(jsonString));0")
    }

    public func set(fontSize: ReaderStyle.FontSize) async throws {
        let jsonData = try encoder.encode(fontSize)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await runner.evaluate("\(namespace).setFontSize(\(jsonString));0")
    }

    public func showReaderContent(with html: String) async throws {
        let escapedHTML = html.jsonEscaped
        _ = try await runner.evaluate("\(namespace).showReaderOverlay(\(escapedHTML));0")
    }

    public func hideReaderContent() async throws {
        _ = try await runner.evaluate("\(namespace).hideReaderOverlay();0")
    }

    public func isReaderMode() async throws -> Bool {
        let isReaderMode = try await runner.evaluate("\(namespace).isReaderMode();") as? Bool
        return isReaderMode ?? false
    }
}

fileprivate extension String {
    var jsonEscaped: String {
        let data = try? JSONSerialization.data(withJSONObject: [self], options: [])
        if let data = data,
           let json = String(data: data, encoding: .utf8),
           json.first == "[", json.last == "]" {
            return String(json.dropFirst().dropLast())
        }
        return self
    }
}
