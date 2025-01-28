import Foundation

public struct ReadabilityResult: Decodable, Sendable {
    public let title: String
    public let byline: String
    public let content: String
    public let textContent: String
    public let length: Int
    public let excerpt: String
    public let siteName: String
    public let lang: String
    public let dir: String?
    public let publishedTime: String
}
