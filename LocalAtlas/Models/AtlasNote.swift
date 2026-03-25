import Foundation

struct AtlasNote: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var url: String
    var title: String
    var createdAt: Date = Date()
    var summary: String
    var tags: [String] = []
}
