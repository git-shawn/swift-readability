import Foundation
import WebKit
import ReadabilityCore

public struct ReaderStyleSetter<Runner: WebViewJavaScriptRunnable> {
    private let runner: Runner

    public init(runner: Runner) {
        self.runner = runner
    }

    public func set(style: ReaderStyle) async throws {
        let jsonData = try JSONEncoder().encode(style)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        try await runner.evaluate(
            "window.__swift_readability__.setStyle(\(jsonString));0",
            contentWorld: .defaultClient
        )
    }
}
