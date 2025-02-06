# Readability
A Swift library that wraps [@mozilla/readability](https://github.com/@mozilla/readability) and generalizes the Firefox Reader, which enhances web pages for better reading.
This library provides a seamless way to detect, parse, and display reader-friendly content from any web page by integrating with WKWebView.

## Features
- **Parsing & Reader Mode**: Parse a URL or HTML string into a structured article using [@mozilla/readability](https://github.com/@mozilla/readability).
- **WKWebView Integration**: Easily integrate with WKWebView to display web content and dynamically toggle a reader mode. The library injects user scripts into the WKWebView configuration to detect and prepare content for reader mode.
- **Reader Mode Overlay**: Easily toggle a reader overlay with customizable themes and font sizes.

## Requirements

- **Swift:** 6.0 or later
- **Xcode:** 16.0 or later
- **Platforms:** macOS (.v11), iOS (.v14), visionOS (.v1)

## Installation
swift-readability is available via the Swift Package Manager
```Swift
.package(url: "https://github.com/Ryu0118/swift-readability", exact: "0.1.0")
```

## Usage
### Basic Parsing
You can parse an article either from a URL or directly from an HTML string.<br>

Parsing from a URL:
```swift
let readability = Readability()
let result = try await readability.parse(url: URL(string: "https://example.com/article")!)
```

Parsing from an HTML string:
```swift
let html = """
<html>
    <!-- Your HTML content here -->
</html>
"""
let result = try await readability.parse(html: html)
```

### Implementing Reader Mode with WKWebView
swift-readability provides a new version of ReadabilityWebCoordinator that prepares a WKWebView configuration, and exposes two asynchronous streams: contentParsed (emitting generated reader HTML) and availabilityChanged (emitting reader mode availability updates). This configuration enables your WKWebView to detect when a web page is suitable for reader mode, generate a reader-friendly HTML overlay, and toggle reader mode dynamically.

```swift
let coordinator = ReadabilityWebCoordinator(initialStyle: ReaderStyle(theme: .dark, fontSize: .size5))
let webView = WKWebView(frame: .zero, configuration: configuration)

// Process generated reader HTML asynchronously.
Task {
    for await html in coordinator.contentParsed {
        do {
            try await webView.showReaderContent(with: html)
        } catch {
            // Handle the error here.
        }
    }
}

// Monitor reader mode availability asynchronously.
Task {
    for await availability in coordinator.availabilityChanged {
        // For example, update your UI to enable or disable the reader mode button.
    }
}
```

### ReaderControllable Protocol

Below are usage examples for each of the functions provided by the `ReaderControllable` protocol extension. Since `WKWebView` conforms to `ReaderControllable`, you can call these methods directly on your `WKWebView` instance.

> [!WARNING]
>  Changes to the reader style (theme and font size) are only available when the web view is in Reader Mode.

```swift
// Set the entire reader style (theme and font size)
try await webView.set(style: ReaderStyle(theme: .dark, fontSize: .size5))

// Set only the reader theme (supports sepia, light, and dark).
try await webView.set(theme: .sepia)

// Set only the font size
try await webView.set(fontSize: .size7)

// Show the reader overlay using the HTML received from the ReadabilityWebCoordinator.contentParsed(_:) event.
try await webView.showReaderContent(with: html)

// Hide the reader overlay.
try await webView.hideReaderContent()

// Determine if the web view is currently in reader mode.
let isReaderMode = try await webView.isReaderMode()
```

If you are using a SwiftUI wrapper library for WKWebView (such as [Cybozu/WebUI](https://github.com/cybozu/WebUI)) that does not expose the WKWebView instance, you can conform any object that has an evaluateJavaScript method to ReaderControllable. For example:
```swift
import WebUI
import ReadabilityUI

extension WebViewProxy: @retroactive ReaderControllable {
    public func evaluateJavaScript(_ javascriptString: String) async throws -> Any {
        let result: Any? = try await evaluateJavaScript(javascriptString)
        return result ?? ()
    }
}
```

## Example (Integrating with SwiftUI)
For a more detailed implementation of integrating swift-readability with SwiftUI using [Cybozu/WebUI](https://github.com/cybozu/WebUI), please refer to the [Example](./Example) provided in this repository.

## Credits
This library uses [mozilla/readability](https://github.com/mozilla/readability) for parsing and cleaning web content.
