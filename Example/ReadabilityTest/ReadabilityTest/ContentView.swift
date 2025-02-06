import Readability
import SwiftUI
import WebKit
import WebUI

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
