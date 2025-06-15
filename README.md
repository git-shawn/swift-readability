# Readability
A Swift library that wraps [@mozilla/readability](https://github.com/mozilla/readability) and generalizes the Firefox Reader, which enhances web pages for better reading.
This library provides a seamless way to detect, parse, and display reader-friendly content from any web page by integrating with WKWebView. Forked from [Ryu0118/swift-readability](https://github.com/Ryu0118/swift-readabilit) to remove UI components.

## Features
- **Parsing** <br>
Parse a URL or HTML string into a structured article using [@mozilla/readability](https://github.com/@mozilla/readability).

## Requirements

- **Swift:** 6.0 or later
- **Xcode:** 16.0 or later

## Installation
swift-readability is available via the Swift Package Manager
```Swift
.package(url: "https://github.com/Ryu0118/swift-readability", exact: "0.1.0")
```

## Usage
### Parsing
You can parse an article either from a URL or directly from an HTML string.<br>

Parsing from a URL:
```swift
import Readability

let readability = Readability()
let result = try await readability.parse(url: URL(string: "https://example.com/article")!)
```

Parsing from an HTML string:
```swift
import Readability

let html = """
<html>
    <!-- Your HTML content here -->
</html>
"""
let result = try await readability.parse(html: html)
```