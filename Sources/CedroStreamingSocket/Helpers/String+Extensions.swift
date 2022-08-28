import Foundation

extension String {
    var intValue: Int? { return Int(self) }
    var doubleValue: Double? { return Double(self) }
    var dataValue: Data? { return self.data(using: .utf8) }
    
    func dateHour(format: Self = "ddMMHHmm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -4)
        return dateFormatter.date(from: self)
    }
}
