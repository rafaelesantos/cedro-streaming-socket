import Foundation

public extension Encodable {
    var prettyJson: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self),
            let output = String(data: data, encoding: .utf8)
            else { return "Error converting \(self) to JSON string" }
        return output
    }
}
