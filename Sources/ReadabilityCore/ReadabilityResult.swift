import Foundation

public typealias JavaScriptString = String

public struct ReadabilityResult: Decodable, Sendable {
    public let title: String
    public let byline: String
    public let content: String
    public let textContent: String
    public let length: Int
    public let excerpt: String
    public let siteName: String?
    public let language: String
    public let direction: String?
    public let publishedTime: String?

    public enum CodingKeys: String, CodingKey, Sendable {
        case title
        case byline
        case content
        case textContent
        case length
        case excerpt
        case siteName
        case language = "lang"
        case direction = "dir"
        case publishedTime
    }
}
