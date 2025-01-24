import Testing
@testable import Readability
import Foundation

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let response = try await Readability.parse(url: URL(string: "https://qiita.com/kanuma1984/items/c158162adfeb6b217973")!)
    print(response)
}
