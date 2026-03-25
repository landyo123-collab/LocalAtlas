import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }

    var id: UUID = UUID()
    var role: Role
    var text: String
    var createdAt: Date = Date()
}
