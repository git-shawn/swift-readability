import SwiftUI
import Readability
import WebUI
import WebKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("ReaderTextView") {
                    ReaderTextView()
                }
                NavigationLink("ReaderWebView") {
                    ReaderWebView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
