// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public struct ReaderStyle: Sendable, Codable, Hashable {
    public var theme: Theme
    public var fontSize: FontSize

    public init(theme: Theme, fontSize: FontSize) {
        self.theme = theme
        self.fontSize = fontSize
    }

    public enum Theme: String, Sendable, Codable, Hashable, CaseIterable {
        case light
        case dark
        case sepia
    }

    public enum FontSize: Int, Sendable, Codable, Hashable, CaseIterable {
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
        case size13 = 13

        func isSmallest() -> Bool {
            return self == FontSize.size1
        }

        func smaller() -> FontSize {
            if isSmallest() {
                return self
            } else {
                return FontSize(rawValue: self.rawValue - 1)!
            }
        }

        func isLargest() -> Bool {
            return self == FontSize.size13
        }

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

        func bigger() -> FontSize {
            if isLargest() {
                return self
            } else {
                return FontSize(rawValue: self.rawValue + 1)!
            }
        }
    }
}
