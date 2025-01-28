import Foundation

extension Readability {
    /// Options for configuring Mozilla Readability.
    ///
    /// Corresponds to the `options` object in:
    /// ```
    /// new Readability(document, options)
    /// ```
    public struct Options: Encodable, Sendable {
        /// Whether to enable debugging/logging.
        /// - Default: `false`
        public var debug: Bool = false

        /// The maximum number of DOM elements to parse.
        /// `0` means no limit.
        /// - Default: `0` (no limit)
        public var maxElemsToParse: Int = 0

        /// The number of top candidates to consider when analysing how tight
        /// the competition is among candidates.
        /// - Default: `5`
        public var nbTopCandidates: Int = 5

        /// The minimum number of characters an article must have in order
        /// for Readability to return a result.
        /// - Default: `500`
        public var charThreshold: Int = 500

        /// When `keepClasses` is `false`, only classes in this list are preserved.
        /// - Default: `[]` (no classes preserved)
        public var classesToPreserve: [String] = []

        /// Whether to preserve all classes on HTML elements.
        /// If `false`, only the classes in `classesToPreserve` are kept.
        /// - Default: `false`
        public var keepClasses: Bool = false

        /// Whether to skip JSON-LD parsing.
        /// If `true`, metadata from JSON-LD is ignored.
        /// - Default: `false`
        public var disableJSONLD: Bool = false

        /// Controls how the content property is produced from the root DOM element.
        /// By default (`el => el.innerHTML` in JS) it returns an HTML string.
        /// In Swift, a direct function pointer to JavaScript is not straightforward,
        /// so we store a string or some identifier for how we want it serialized.
        ///
        /// - Default: `nil` (uses the default serializer `el.innerHTML`)
        public var serializer: String? = nil

        /// A regular expression (as a string) that matches video URLs to be allowed.
        /// If `nil`, the default regex is applied on the JS side.
        /// - Default: `nil`
        public var allowedVideoRegex: String? = nil

        /// A number added to the base link density threshold during "shadiness" checks.
        /// This can be used to penalize or reward nodes with high link density.
        /// - Default: `0`
        public var linkDensityModifier: Double = 0

        // MARK: - Initializers

        /// Default memberwise initializer, plus any convenient custom ones if needed.
        public init(
            debug: Bool = false,
            maxElemsToParse: Int = 0,
            nbTopCandidates: Int = 5,
            charThreshold: Int = 500,
            classesToPreserve: [String] = [],
            keepClasses: Bool = false,
            disableJSONLD: Bool = false,
            serializer: String? = nil,
            allowedVideoRegex: String? = nil,
            linkDensityModifier: Double = 0
        ) {
            self.debug = debug
            self.maxElemsToParse = maxElemsToParse
            self.nbTopCandidates = nbTopCandidates
            self.charThreshold = charThreshold
            self.classesToPreserve = classesToPreserve
            self.keepClasses = keepClasses
            self.disableJSONLD = disableJSONLD
            self.serializer = serializer
            self.allowedVideoRegex = allowedVideoRegex
            self.linkDensityModifier = linkDensityModifier
        }
    }
}
