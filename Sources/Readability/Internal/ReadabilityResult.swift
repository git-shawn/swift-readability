import Foundation

public struct ReadabilityResult: Decodable, Sendable {
    public let title: String?
    public let byline: String?
    public let content: String?   // HTML 形式の記事本文
    public let textContent: String?
    public let length: Int?
    public let excerpt: String?
    public let siteName: String?
}
