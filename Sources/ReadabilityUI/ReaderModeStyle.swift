// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public struct ReaderModeStyle: Sendable, Codable {
    public var theme: ReaderModeTheme
    public var fontSize: ReaderModeFontSize
}

public enum ReaderModeTheme: Sendable, Codable {
    case light
    case dark
    case sepia
}

public enum ReaderModeFontSize: Int, Sendable, Codable {
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
        return self == ReaderModeFontSize.size1
    }

    func smaller() -> ReaderModeFontSize {
        if isSmallest() {
            return self
        } else {
            return ReaderModeFontSize(rawValue: self.rawValue - 1)!
        }
    }

    func isLargest() -> Bool {
        return self == ReaderModeFontSize.size13
    }

    @MainActor
    static var defaultSize: ReaderModeFontSize {
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

    func bigger() -> ReaderModeFontSize {
        if isLargest() {
            return self
        } else {
            return ReaderModeFontSize(rawValue: self.rawValue + 1)!
        }
    }
}
