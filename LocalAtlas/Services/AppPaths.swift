import Foundation

enum AppPaths {
    static func appSupportDir() throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("LocalAtlas", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func notesFileURL() throws -> URL {
        try appSupportDir().appendingPathComponent("notes.json")
    }

    static func conversationsFileURL() throws -> URL {
        try appSupportDir().appendingPathComponent("conversations.json")
    }
}
