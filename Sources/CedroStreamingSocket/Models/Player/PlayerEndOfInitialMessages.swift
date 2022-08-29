import Foundation

public struct PlayerEndOfInitialMessages: ServiceModelProtocol {
    public var market: String
}

// MARK: - ServiceContentProtocol
extension PlayerEndOfInitialMessages: ServiceContentProtocol {
    public typealias ServiceContentTypeProtocol = PlayerContentType
    public var contentType: ServiceContentTypeProtocol { return .endOfInitialMessages }
}

// MARK: - ServiceProtocol
extension PlayerEndOfInitialMessages: ServiceProtocol {
    public static var serviceId: ServiceId { return .player }
    
    public static func decode(from components: [String]) throws -> PlayerEndOfInitialMessages {
        try decodeService(from: components)
        return PlayerEndOfInitialMessages(market: try decodeMarket(from: components))
    }
    
    private static func decodeService(from components: [String]) throws {
        guard components.indices.contains(0) else { throw CedroServiceError.invalidMessageFormat }
        guard components[0] == serviceId.rawValue else { throw CedroServiceError.wrongService }
    }
    
    private static func decodeMarket(from components: [String]) throws -> String {
        guard components.indices.contains(1) else { throw CedroServiceError.dontContainsMarketName }
        return components[1]
    }
}
