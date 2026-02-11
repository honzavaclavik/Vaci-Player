import Foundation

enum BuildInfo {
    static let version = "1.2"
    static let buildDate = "__BUILD_DATE__"

    static var displayString: String {
        if buildDate == "__BUILD_DATE__" {
            // Development build - show current date
            let formatter = DateFormatter()
            formatter.dateFormat = "d.M.yyyy"
            return "v\(version) · \(formatter.string(from: Date()))"
        }
        return "v\(version) · \(buildDate)"
    }
}
