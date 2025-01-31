package protocol ReaderContentGeneratable: Sendable {
    func generate(
        _ readabilityResult: ReadabilityResult,
        initialStyle: ReaderStyle
    ) async -> String?
}
