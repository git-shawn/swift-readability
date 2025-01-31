// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import ReadabilityCore

struct ReaderContentGenerator: ReaderContentGeneratable {
    private let encoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    private let scriptLoader = ScriptLoader(bundle: .module)

    func generate(
        _ readabilityResult: ReadabilityResult,
        initialStyle: ReaderStyle
    ) async -> String? {
        guard let template = try? await scriptLoader.load(.readerHTML),
              let styleData = try? encoder.encode(initialStyle),
              let styleString = String(data: styleData, encoding: .utf8)
        else { return nil }

        return template.replacingOccurrences(of: "%READER-STYLE%", with: styleString)
            .replacingOccurrences(of: "%READER-TITLE%", with: readabilityResult.title)
            .replacingOccurrences(of: "%READER-BYLINE%", with: readabilityResult.byline)
            .replacingOccurrences(of: "%READER-CONTENT%", with: readabilityResult.content)
            .replacingOccurrences(of: "%READER-LANGUAGE%", with: readabilityResult.language)
            .replacingOccurrences(of: "%READER-DIRECTION%", with: readabilityResult.direction ?? "auto")
    }
}
