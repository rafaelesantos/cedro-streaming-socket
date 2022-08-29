import Foundation

public enum BookQuoteContentType: String, Codable {
    case offersAdd = "A"
    case offersUpdate = "U"
    case endOfInitialMessages = "E"
    case offersCancel = "D"
}
