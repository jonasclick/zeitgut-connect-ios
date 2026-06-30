import Foundation

enum AppDateFormatter {
    private static let backendDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let shortSwissDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "de_CH")
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    static func displayDate(fromBackendDate value: String) -> String {
        guard let date = backendDateParser.date(from: value) else {
            return value
        }

        return shortSwissDateFormatter.string(from: date)
    }
}
