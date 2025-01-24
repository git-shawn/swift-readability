import SwiftUI
import Readability
import WebUI
import WebKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("ReaderWebView") {
                    ReaderWebView()
                }
                NavigationLink("ReaderTextView") {
                    ReaderTextView()
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
