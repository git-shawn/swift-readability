import Foundation

actor ScriptLoader {
    enum Resource {
        case atDocumentStart
        case readerHTML

        var name: String {
            switch self {
            case .atDocumentStart:
                "AtDocumentStart"
            case .readerHTML:
                "Reader"
            }
        }

        var ext: String {
            switch self {
            case .atDocumentStart:
                "js"
            case .readerHTML:
                "html"
            }
        }
    }

    func load(_ resource: Resource) throws -> String {
        try load(forResource: resource.name, withExtension: resource.ext)
    }

    private func load(forResource name: String, withExtension ext: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
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
