import Foundation
import WebKit
import ReadabilityCore

/// A protocol defining an interface for controlling a reader mode web view.
/// Provides methods to evaluate JavaScript and manipulate the reader overlay.
@MainActor
public protocol ReaderControllable {
    /// Evaluates a JavaScript string in the context of the web view.
    ///
    /// - Parameter javascriptString: The JavaScript code to evaluate.
    /// - Returns: The result of the JavaScript evaluation.
    /// - Throws: An error if the evaluation fails.
    func evaluateJavaScript(_ javascriptString: String) async throws -> Any
}

extension ReaderControllable {
    /// The JavaScript namespace for the Readability functions.
    private var namespace: String {
        "window.__swift_readability__"
    }

    /// Sets the reader style of the web view.
    ///
    /// - Parameter style: The `ReaderStyle` to apply.
    /// - Throws: An error if the JavaScript evaluation fails.
    public func set(style: ReaderStyle) async throws {
        let jsonData = try JSONEncoder().encode(style)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript(
            "\(namespace).setStyle(\(jsonString));0"
        )
    }

    /// Sets the reader theme of the web view.
    ///
    /// - Parameter theme: The `ReaderStyle.Theme` to apply.
    /// - Throws: An error if the JavaScript evaluation fails.
    public func set(theme: ReaderStyle.Theme) async throws {
        let jsonData = try JSONEncoder().encode(theme)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript("\(namespace).setTheme(\(jsonString));0")
    }

    /// Sets the font size of the reader content.
    ///
    /// - Parameter fontSize: The `ReaderStyle.FontSize` to apply.
    /// - Throws: An error if the JavaScript evaluation fails.
    public func set(fontSize: ReaderStyle.FontSize) async throws {
        let jsonData = try JSONEncoder().encode(fontSize)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        _ = try await evaluateJavaScript("\(namespace).setFontSize(\(jsonString));0")
    }

    /// Displays the reader content overlay with the specified HTML.
    ///
    /// - Parameter html: The HTML content to display.
    /// - Throws: An error if the JavaScript evaluation fails.
    public func showReaderContent(with html: String) async throws {
        let escapedHTML = html.jsonEscaped
        _ = try await evaluateJavaScript("\(namespace).showReaderOverlay(\(escapedHTML));0")
    }

    /// Hides the reader content overlay.
    ///
    /// - Throws: An error if the JavaScript evaluation fails.
    public func hideReaderContent() async throws {
        _ = try await evaluateJavaScript("\(namespace).hideReaderOverlay();0")
    }

    /// Checks whether the web view is currently in reader mode.
    ///
    /// - Returns: `true` if the web view is in reader mode, otherwise `false`.
    /// - Throws: An error if the JavaScript evaluation fails.
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
