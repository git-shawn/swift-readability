import Readability
import SwiftUI

struct ReaderTextView: View {
    @State var content: String = ""
    @State var urlString: String = ""
    @State var isLoading = false
    @State var isPresented = true

    private let readability = Readability()

    var body: some View {
        ScrollView {
            Text(content)
        }
        .searchable(text: $urlString, isPresented: $isPresented)
        .onSubmit(of: .search) {
            if let url = URL(string: urlString) {
                withLoading {
                    content = try await readability.parse(url: url).textContent
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }

    private func withLoading(_ operation: @escaping () async throws -> Void) {
        isLoading = true
        Task {
            do {
                try await operation()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}
