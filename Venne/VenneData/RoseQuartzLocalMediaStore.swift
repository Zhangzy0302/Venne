import Foundation

enum RoseQuartzLocalMediaStore {
    static func roseQuartzSaveImageData(
        _ roseQuartzImageData: Data,
        folder roseQuartzFolderName: String
    ) throws -> String {
        let roseQuartzBaseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        let roseQuartzDirectoryURL = roseQuartzBaseURL
            .appendingPathComponent("VenneUploads", isDirectory: true)
            .appendingPathComponent(roseQuartzFolderName, isDirectory: true)

        if FileManager.default.fileExists(atPath: roseQuartzDirectoryURL.path) == false {
            try FileManager.default.createDirectory(
                at: roseQuartzDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        let roseQuartzFileURL = roseQuartzDirectoryURL
            .appendingPathComponent("\(UUID().uuidString).jpg")

        try roseQuartzImageData.write(to: roseQuartzFileURL, options: [.atomic])
        return roseQuartzFileURL.path
    }
}
