import Foundation

public enum PlayerContentType: String, Codable, ServiceContentTypeProtocol {
    case endOfInitialMessages = "E"
    case player = ""
}
