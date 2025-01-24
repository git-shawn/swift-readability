import Foundation

struct HTMLFetcher {
    enum Error: LocalizedError {
        case noValidEncodingFound

        var errorDescription: String? {
            switch self {
            case .noValidEncodingFound:
                "No valid encoding found"
            }
        }
    }

    private let session = URLSession.shared

    func fetch(url: URL) async throws -> String {
        let (htmlData, _) = try await URLSession.shared.data(from: url)
        let encodings: [String.Encoding] = [
            .utf8,
            .shiftJIS,
            .ascii,
            .utf16,
            .utf16LittleEndian,
            .utf32,
            .utf32LittleEndian,
            .isoLatin1,
            .japaneseEUC,
            .windowsCP1250,
            .windowsCP1251,
            .windowsCP1252,
        ]

        var html: String?
        for encoding in encodings {
            if let string = String(data: htmlData, encoding: encoding) {
                html = string
                break
            }
        }

        guard let html else {
            throw Error.noValidEncodingFound
        }

        return html
    }
}
