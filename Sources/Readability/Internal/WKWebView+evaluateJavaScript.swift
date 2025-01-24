import Foundation
import WebKit

extension WKWebView {
    func evaluateJavaScript(_ string: JavaScriptString) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            self.evaluateJavaScript(string) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result as? String)
                }
            }
        }
    }
}
