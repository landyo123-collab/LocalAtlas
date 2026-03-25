import Foundation

struct AtlasConversation: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var createdAt: Date = Date()
    var messages: [ChatMessage] = []
}
