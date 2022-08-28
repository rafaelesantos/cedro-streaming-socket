import Foundation

extension Data {
    var message: String? { String(data: self, encoding: .utf8) }
}
