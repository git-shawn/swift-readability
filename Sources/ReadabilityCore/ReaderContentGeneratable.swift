/// A protocol that defines the ability to generate reader content (HTML) from a `ReadabilityResult` and an initial style.
package protocol ReaderContentGeneratable: Sendable {
    /// Generates reader HTML content based on the provided readability result and initial style.
    ///
    /// - Parameters:
    ///   - readabilityResult: The result of the readability parsing.
    ///   - initialStyle: The initial style to apply to the reader content.
    /// - Returns: An optional `String` containing the generated HTML content.
    func generate(
        _ readabilityResult: ReadabilityResult,
        initialStyle: ReaderStyle
    ) async -> String?
}
