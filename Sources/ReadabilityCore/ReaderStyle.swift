// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

/// A structure representing the style settings for the reader mode.
public struct ReaderStyle: Sendable, Codable, Hashable {
    /// The theme to be applied in reader mode.
    public var theme: Theme
    /// The font size to be applied in reader mode.
    public var fontSize: FontSize

    /// Initializes a new `ReaderStyle` with the specified theme and font size.
    ///
    /// - Parameters:
    ///   - theme: The theme to use (e.g., light, dark, sepia).
    ///   - fontSize: The font size setting.
    public init(theme: Theme, fontSize: FontSize) {
        self.theme = theme
        self.fontSize = fontSize
    }

    /// An enumeration representing the available themes for reader mode.
    public enum Theme: String, Sendable, Codable, Hashable, CaseIterable {
        /// A light theme.
        case light
        /// A dark theme.
        case dark
        /// A sepia theme.
        case sepia
    }

    /// An enumeration representing the available font sizes for reader mode.
    public enum FontSize: Int, Sendable, Codable, Hashable, CaseIterable {
        /// The smallest font size.
        case size1 = 1
        case size2 = 2
        case size3 = 3
        case size4 = 4
        case size5 = 5
        case size6 = 6
        case size7 = 7
        case size8 = 8
        case size9 = 9
        case size10 = 10
        case size11 = 11
        case size12 = 12
        /// The largest font size.
        case size13 = 13

        /// Checks if the current font size is the smallest.
        public var isSmallest: Bool {
            self == FontSize.size1
        }

        /// Checks if the current font size is the largest.
        public var isLargest: Bool {
            self == FontSize.size13
        }

        /// Returns a smaller font size if available.
        ///
        /// - Returns: The next smaller font size, or the current size if already smallest.
        public func smaller() -> FontSize {
            if isSmallest {
                return self
            } else {
                return FontSize(rawValue: rawValue - 1)!
            }
        }

        /// Returns a larger font size if available.
        public func bigger() -> FontSize {
            if isLargest {
                return self
            } else {
                return FontSize(rawValue: rawValue + 1)!
            }
        }

        /// The default font size based on the user's preferred content size category.
        #if canImport(UIKit)
            @MainActor
            static var defaultSize: FontSize {
                switch UIApplication.shared.preferredContentSizeCategory {
                case .extraSmall:
                    .size1
                case .small:
                    .size2
                case .medium:
                    .size3
                case .large:
                    .size5
                case .extraLarge:
                    .size7
                case .extraExtraLarge:
                    .size9
                case .extraExtraExtraLarge:
                    .size12
                default:
                    .size5
                }
            }
        #endif
    }
}
