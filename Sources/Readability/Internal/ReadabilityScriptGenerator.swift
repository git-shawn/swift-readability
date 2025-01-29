import Foundation
import ReadabilityCore

actor ReadabilityScriptGenerator: Sendable  {
    private let encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    var readabilityScript: JavaScriptString?

    init(readabilityScript: JavaScriptString? = nil) {
        self.readabilityScript = readabilityScript
    }

    func generateNonInteractiveScript(options: Readability.Options?) throws -> JavaScriptString {
        let readabilityScript = try getReadabilityScript()
        let jsonOptions = try generateJSONOptions(options: options)

        return """
        (function() {
            \(readabilityScript)
            const doc = document.cloneNode(true);
            const article = new Readability(
                doc,
                \(jsonOptions)
            ).parse();
            return JSON.stringify(article);
        })();
        """
    }

    func generateInteractiveScript(options: Readability.Options?) throws -> JavaScriptString {
        let readabilityScript = try getReadabilityScript()
        let jsonOptions = try generateJSONOptions(options: options)

        return """
        (function() {
            \(readabilityScript)
            const doc = document.cloneNode(true);
            const article = new Readability(
                doc,
                \(jsonOptions)
            ).parse();
            document.body.innerHTML = article.content
            document.documentElement.style.visibility = '';
        
            const observer = new MutationObserver(() => {
                if (document.body.innerHTML !== article.content) {
                    document.body.innerHTML = article.content
                }
            });

            observer.observe(document.body, { childList: true, subtree: true });

            return JSON.stringify(article);
        })();
        """
    }
}

extension ReadabilityScriptGenerator {
    private func loadReadabilityScript() throws -> JavaScriptString {
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

    private func generateJSONOptions(options: Readability.Options?) throws -> String {
        if let options {
            let data = try encoder.encode(options)
            return String(data: data, encoding: .utf8) ?? "{}"
        } else {
            return "{}"
        }
    }
}

extension ReadabilityScriptGenerator {
    enum Error: Swift.Error {
        case failedToCopyReadabilityScriptFromNodeModules
        case failedToCopyJSDOMScriptFromNodeModules
    }
}
