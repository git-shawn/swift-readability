import Foundation

package actor ScriptLoader {
    package enum Resource {
        case atDocumentStart
        case atDocumentEnd
        case readerHTML
        case readabilityBasic
        case readabilitySanitized

        var name: String {
            switch self {
            case .atDocumentStart:
                "AtDocumentStart"
            case .atDocumentEnd:
                "AtDocumentEnd"
            case .readerHTML:
                "Reader"
            case .readabilityBasic:
                "ReadabilityBasic"
            case .readabilitySanitized:
                "ReadabilitySanitized"
            }
        }

        var ext: String {
            switch self {
            case .atDocumentStart, .atDocumentEnd, .readabilityBasic, .readabilitySanitized:
                "js"
            case .readerHTML:
                "html"
            }
        }
    }

    private let bundle: Bundle

    package init(bundle: Bundle) {
        self.bundle = bundle
    }

    package func load(_ resource: Resource) throws -> String {
        try load(forResource: resource.name, withExtension: resource.ext)
    }

    private func load(forResource name: String, withExtension ext: String) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw Error.failedToCopyReadabilityScriptFromNodeModules
        }

        let readabilityScript = try String(contentsOf: url, encoding: .utf8)

        return readabilityScript
    }
}

extension ScriptLoader {
    enum Error: Swift.Error {
        case failedToCopyReadabilityScriptFromNodeModules
    }
}
