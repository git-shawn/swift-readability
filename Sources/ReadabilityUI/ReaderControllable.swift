import Foundation
import WebKit
import ReadabilityCore

@MainActor
public protocol ReaderControllable {
    func evaluateJavaScript(_ javascriptString: String) async throws -> Any
}

extension ReaderControllable {
    private var namespace: String {
        "window.__swift_readability__"
    }

    public func set(style: ReaderStyle) async throws {
        let jsonData = try JSONEncoder().encode(style)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript(
            "\(namespace).setStyle(\(jsonString));0"
        )
    }

    public func set(theme: ReaderStyle.Theme) async throws {
        let jsonData = try JSONEncoder().encode(theme)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript("\(namespace).setTheme(\(jsonString));0")
    }

    public func set(fontSize: ReaderStyle.FontSize) async throws {
        let jsonData = try JSONEncoder().encode(fontSize)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript("\(namespace).setFontSize(\(jsonString));0")
    }

    public func showReaderContent(with html: String) async throws {
        let escapedHTML = html.jsonEscaped
        _ = try await evaluateJavaScript("\(namespace).showReaderOverlay(\(escapedHTML));0")
    }

    public func hideReaderContent() async throws {
        _ = try await evaluateJavaScript("\(namespace).hideReaderOverlay();0")
    }

    public func isReaderMode() async throws -> Bool {
        let isReaderMode = try await evaluateJavaScript("\(namespace).isReaderMode();") as? Bool
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

extension WKWebView: ReaderControllable {}
