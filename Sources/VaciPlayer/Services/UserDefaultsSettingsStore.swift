import Foundation

class UserDefaultsSettingsStore: SettingsStoreProtocol {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func setValue<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func getValue<T>(forKey key: String, defaultValue: T) -> T {
        if let value = userDefaults.object(forKey: key) as? T {
            return value
        }
        return defaultValue
    }
    
    func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

// MARK: - Mock Implementation for Testing
class MockSettingsStore: SettingsStoreProtocol {
    private var storage: [String: Any] = [:]
    
    func setValue<T>(_ value: T, forKey key: String) {
        storage[key] = value
    }
    
    func getValue<T>(forKey key: String, defaultValue: T) -> T {
        return storage[key] as? T ?? defaultValue
    }
    
    func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    // Test helpers
    func getAllValues() -> [String: Any] {
        return storage
    }
    
    func clear() {
        storage.removeAll()
    }
}