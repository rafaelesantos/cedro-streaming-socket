import Foundation

public enum AggregatedBookContentType: String, Codable, ServiceContentTypeProtocol {
    case offersAdd = "A"
    case offersUpdate = "U"
    case endOfInitialMessages = "E"
    case offersCancel = "D"
}
