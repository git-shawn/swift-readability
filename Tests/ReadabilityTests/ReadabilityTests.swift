import Testing
@testable import Readability
import Foundation

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let html = try await HTMLFetcher().fetch(url: URL(string: "https://qiita.com/Ryu0118/items/851a96eb1d362ecce11f")!)
    let result = try await ReadabilityRunner().parse(html: html, options: nil)
    print(result.textContent)
}
