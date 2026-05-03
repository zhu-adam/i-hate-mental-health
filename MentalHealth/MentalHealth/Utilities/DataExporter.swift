import Foundation

enum DataExporterError: Error {
    case encodingFailed
    case decodingFailed
}

struct DataExporter {
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static func export(_ entries: [MoodEntry]) throws -> Data {
        let dtos = entries.map { MoodEntryDTO(from: $0) }
        return try encoder.encode(dtos)
    }

    static func `import`(from data: Data) throws -> [MoodEntry] {
        let dtos = try decoder.decode([MoodEntryDTO].self, from: data)
        return dtos.map { $0.toModel() }
    }
}
