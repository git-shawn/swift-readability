import ReadabilityCore
import SwiftUI
import WebKit

/// A public interface for parsing web pages using Mozilla's Readability library.
/// This struct provides asynchronous methods to parse HTML or a URL into a structured `ReadabilityResult`.
@MainActor
public struct Readability {
    private let runner: ReadabilityRunner

    public init() {
        runner = ReadabilityRunner()
    }

    /// Parses the web page at the specified URL and returns a `ReadabilityResult`.
    ///
    /// - Parameters:
    ///   - url: The URL of the web page to parse.
    ///   - options: Optional configuration options for parsing.
    /// - Returns: A `ReadabilityResult` containing the parsed content.
    /// - Throws: An error if fetching or parsing fails.
    public func parse(
        url: URL,
        options: Readability.Options? = nil
    ) async throws -> ReadabilityResult {
        // Fetch HTML content from the URL.
        let html = try await HTMLFetcher().fetch(url: url)
        // Parse the fetched HTML content.
        return try await parse(
            html: html,
            options: options,
            baseURL: nil
        )
    }

    /// Parses the provided HTML string and returns a `ReadabilityResult`.
    ///
    /// - Parameters:
    ///   - html: The HTML content to parse.
    ///   - options: Optional configuration options for parsing.
    ///   - baseURL: The base URL for the HTML content.
    /// - Returns: A `ReadabilityResult` containing the parsed content.
    /// - Throws: An error if parsing fails.
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
