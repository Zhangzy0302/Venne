import Foundation

protocol CrystalBlushLocalPersistable: Codable, Identifiable where ID == String {
    static var crystalBlushStorageFileName: String { get }
}

final class CrystalBlushLocalRepository<Model: CrystalBlushLocalPersistable> {
    private let crystalBlushFileURL: URL
    private let crystalBlushFileManager: FileManager
    private let crystalBlushEncoder: JSONEncoder
    private let crystalBlushDecoder: JSONDecoder

    init(
        storageDirectory: URL = CrystalBlushLocalRepository<Model>.crystalBlushDefaultStorageDirectory,
        fileManager: FileManager = .default
    ) {
        crystalBlushFileManager = fileManager
        crystalBlushFileURL = storageDirectory.appendingPathComponent(Model.crystalBlushStorageFileName)

        crystalBlushEncoder = JSONEncoder()
        crystalBlushEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        crystalBlushEncoder.dateEncodingStrategy = .iso8601

        crystalBlushDecoder = JSONDecoder()
        crystalBlushDecoder.dateDecodingStrategy = .iso8601
    }

    func create(_ crystalBlushModel: Model) throws {
        var crystalBlushModels = try readAll()

        guard crystalBlushModels.contains(where: { $0.id == crystalBlushModel.id }) == false else {
            throw CrystalBlushLocalRepositoryError.duplicateID(crystalBlushModel.id)
        }

        crystalBlushModels.append(crystalBlushModel)
        try save(crystalBlushModels)
    }

    func read(id crystalBlushID: String) throws -> Model? {
        try readAll().first { $0.id == crystalBlushID }
    }

    func readAll() throws -> [Model] {
        guard crystalBlushFileManager.fileExists(atPath: crystalBlushFileURL.path) else {
            return []
        }

        let crystalBlushData = try Data(contentsOf: crystalBlushFileURL)

        guard crystalBlushData.isEmpty == false else {
            return []
        }

        return try crystalBlushDecoder.decode([Model].self, from: crystalBlushData)
    }

    func update(_ crystalBlushModel: Model) throws {
        var crystalBlushModels = try readAll()

        guard let crystalBlushIndex = crystalBlushModels.firstIndex(where: { $0.id == crystalBlushModel.id }) else {
            throw CrystalBlushLocalRepositoryError.missingID(crystalBlushModel.id)
        }

        crystalBlushModels[crystalBlushIndex] = crystalBlushModel
        try save(crystalBlushModels)
    }

    func upsert(_ crystalBlushModel: Model) throws {
        var crystalBlushModels = try readAll()

        if let crystalBlushIndex = crystalBlushModels.firstIndex(where: { $0.id == crystalBlushModel.id }) {
            crystalBlushModels[crystalBlushIndex] = crystalBlushModel
        } else {
            crystalBlushModels.append(crystalBlushModel)
        }

        try save(crystalBlushModels)
    }

    func delete(id crystalBlushID: String) throws {
        var crystalBlushModels = try readAll()

        guard let crystalBlushIndex = crystalBlushModels.firstIndex(where: { $0.id == crystalBlushID }) else {
            throw CrystalBlushLocalRepositoryError.missingID(crystalBlushID)
        }

        crystalBlushModels.remove(at: crystalBlushIndex)
        try save(crystalBlushModels)
    }

    func deleteAll() throws {
        try save([])
    }

    private func save(_ crystalBlushModels: [Model]) throws {
        let crystalBlushDirectoryURL = crystalBlushFileURL.deletingLastPathComponent()

        if crystalBlushFileManager.fileExists(atPath: crystalBlushDirectoryURL.path) == false {
            try crystalBlushFileManager.createDirectory(
                at: crystalBlushDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        let crystalBlushData = try crystalBlushEncoder.encode(crystalBlushModels)
        try crystalBlushData.write(to: crystalBlushFileURL, options: [.atomic])
    }

    private static var crystalBlushDefaultStorageDirectory: URL {
        let crystalBlushBaseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        return crystalBlushBaseURL.appendingPathComponent("VenneData", isDirectory: true)
    }
}

enum CrystalBlushLocalRepositoryError: LocalizedError, Equatable {
    case duplicateID(String)
    case missingID(String)

    var errorDescription: String? {
        switch self {
        case .duplicateID(let crystalBlushID):
            return "A local record already exists for id: \(crystalBlushID)."
        case .missingID(let crystalBlushID):
            return "No local record exists for id: \(crystalBlushID)."
        }
    }
}

