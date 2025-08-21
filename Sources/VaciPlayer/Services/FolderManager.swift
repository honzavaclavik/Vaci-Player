import Foundation

class FolderManager: ObservableObject {
    @Published var favoriteFolders: [FavoriteFolder] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoriteFoldersKey = "favoriteFolders"
    
    init() {
        loadFavoriteFolders()
    }
    
    func addFavoriteFolder(_ url: URL, name: String = "") {
        // Check if folder already exists
        if favoriteFolders.contains(where: { $0.url == url }) {
            return
        }
        
        let favoriteFolder = FavoriteFolder(url: url, name: name)
        favoriteFolders.append(favoriteFolder)
        saveFavoriteFolders()
    }
    
    func removeFavoriteFolder(_ folder: FavoriteFolder) {
        favoriteFolders.removeAll { $0.id == folder.id }
        saveFavoriteFolders()
    }
    
    func updateFolderName(_ folder: FavoriteFolder, newName: String) {
        if let index = favoriteFolders.firstIndex(where: { $0.id == folder.id }) {
            favoriteFolders[index].name = newName
            saveFavoriteFolders()
        }
    }
    
    func isFavorite(_ url: URL) -> Bool {
        return favoriteFolders.contains { $0.url == url }
    }
    
    private func saveFavoriteFolders() {
        if let data = try? JSONEncoder().encode(favoriteFolders) {
            userDefaults.set(data, forKey: favoriteFoldersKey)
        }
    }
    
    private func loadFavoriteFolders() {
        guard let data = userDefaults.data(forKey: favoriteFoldersKey),
              let folders = try? JSONDecoder().decode([FavoriteFolder].self, from: data) else {
            return
        }
        
        // Filter out folders that no longer exist
        favoriteFolders = folders.filter { folder in
            FileManager.default.fileExists(atPath: folder.url.path)
        }
        
        // Save the filtered list if any folders were removed
        if favoriteFolders.count != folders.count {
            saveFavoriteFolders()
        }
    }
}