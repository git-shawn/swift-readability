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
```swift
let readability = Readability()
let result = try await readability.parse(url: URL(string: "https://example.com/article")!)
```

```swift
let html = """
<html>
...
</html>
"""
let result = try await readability.parse(html: html)
```

## Implementing Reader Mode with WKWebView
swift-readability provides a `ReadabilityWebCoordinator` that prepares a WKWebView configuration, observes availability of reader mode, and notifies when reader HTML is generated. 
This configuration enables your WKWebView to detect when a web page is suitable for reader mode, generate a reader-friendly HTML overlay, and toggle the reader mode dynamically.


## Credits
This library uses [mozilla/readability](https://github.com/mozilla/readability) for parsing and cleaning web content.
