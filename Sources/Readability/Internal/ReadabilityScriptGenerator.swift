import Foundation

typealias JavaScriptString = String

actor ReadabilityScriptGenerator: Sendable  {
    var readabilityScript: JavaScriptString?

    init(readabilityScript: JavaScriptString? = nil) {
        self.readabilityScript = readabilityScript
    }

    func loadReadabilityScript() throws -> JavaScriptString {
        guard let url = Bundle.module.url(forResource: "Readability", withExtension: "js") else {
            throw Error.failedToCopyReadabilityScriptFromNodeModules
        }

        let readabilityScript = try String(contentsOf: url, encoding: .utf8)

        return readabilityScript
    }

    private func getReadabilityScript() throws -> JavaScriptString {
        if let script = self.readabilityScript {
            return script
        } else {
            let script = try loadReadabilityScript()
            self.readabilityScript = script
            return script
        }
    }

    func generateNonInteractiveScript() throws -> JavaScriptString {
        let readabilityScript = try getReadabilityScript()

        return """
        (function() {
            \(readabilityScript)
            const doc = document.cloneNode(true);
            const article = new Readability(doc).parse();
            return JSON.stringify(article);
        })();
        """
    }

    func generateInteractiveScript() throws -> JavaScriptString {
        let readabilityScript = try getReadabilityScript()

        return """
        (function() {
            \(readabilityScript)
            const article = new Readability(document).parse();
            document.body.innerHTML = article.content
            return JSON.stringify(article);
        })();
        """
    }
}

extension ReadabilityScriptGenerator {
    enum Error: Swift.Error {
        case failedToCopyReadabilityScriptFromNodeModules
    }
}
