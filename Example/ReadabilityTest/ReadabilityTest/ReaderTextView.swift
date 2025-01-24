import SwiftUI
import Readability

struct ReaderTextView: View {
    @State var content: String = ""
    @State var urlString: String = ""
    @State var isLoading = false

    var body: some View {
        ScrollView {
            Text(content)
        }
        .launchReadabilityDaemon()
        .searchable(text: $urlString, isPresented: .constant(true))
        .onSubmit(of: .search) {
            if let url = URL(string: urlString) {
                withLoading {
                    content = try await Readability.parse(url: url).textContent ?? ""
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
