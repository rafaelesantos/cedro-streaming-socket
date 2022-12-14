import Foundation

public enum BookQuoteContentType: String, Codable, ServiceContentTypeProtocol {
    case offersAdd = "A"
    case offersUpdate = "U"
    case endOfInitialMessages = "E"
    case offersCancel = "D"
}
