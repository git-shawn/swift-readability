import SwiftUI
import WebKit
import ReadabilityCore

@MainActor
public struct Readability {
    private let runner: ReadabilityRunner

    public init() {
        runner = ReadabilityRunner()
    }

    public static func createReadableWebViewConfiguration(
        options: Readability.Options? = nil
    ) async throws -> WKWebViewConfiguration {
        try await WebKitConfigurationGenerator.createReadableWebViewConfiguration(options: options)
    }

    public func parse(
        url: URL,
        options: Readability.Options? = nil
    ) async throws -> ReadabilityResult {
        let html = try await HTMLFetcher().fetch(url: url)
        return try await parse(
            html: html,
            options: options,
            baseURL: nil
        )
    }

    public func parse(
        html: String,
        options: Readability.Options?,
        baseURL: URL?
    ) async throws -> ReadabilityResult {
        try await runner.parseHTML(
            html,
            options: options,
            baseURL: baseURL
        )
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
