import Foundation

struct FavoriteFolder: Identifiable, Codable {
    let id: UUID
    let url: URL
    var name: String
    let dateAdded: Date
    
    var displayName: String {
        name.isEmpty ? url.lastPathComponent : name
    }
    
    init(url: URL, name: String = "") {
        self.id = UUID()
        self.url = url
        self.name = name.isEmpty ? url.lastPathComponent : name
        self.dateAdded = Date()
    }
}