import Foundation

public struct Player: ServiceModel {
    public var marketName: String
    public var brokerCodeMarket: Int
    public var brokerName: String
    public var brokerCodeBank: Int
    public var marketCode: Int
}

// MARK: - ServiceProtocol
extension Player: ServiceProtocol {
    static var serviceId: ServiceId { return .player }
    
    static func decode(from components: [String]) throws -> Player {
        try decodeService(from: components)
        return Player(
            marketName: try decodeMarketName(from: components),
            brokerCodeMarket: try decodeBrokerCodeMarket(from: components),
            brokerName: try decodeBrokerName(from: components),
            brokerCodeBank: try decodeBrokerCodeBank(from: components),
            marketCode: try decodeMarketCode(from: components)
        )
    }
    
    private static func decodeService(from components: [String]) throws {
        guard components.indices.contains(0) else { throw CedroServiceError.invalidMessageFormat }
        guard components[0] == serviceId.rawValue else { throw CedroServiceError.wrongService }
    }
    
    private static func decodeMarketName(from components: [String]) throws -> String {
        guard components.indices.contains(1) else { throw CedroServiceError.dontContainsMarketName }
        return components[1]
    }
    
    private static func decodeBrokerCodeMarket(from components: [String]) throws -> Int {
        guard components.indices.contains(2) else { throw CedroServiceError.dontContainsBrokerCodeMarket }
        guard let brokerCodeMarket = components[2].intValue else { throw CedroServiceError.invalidBrokerCodeMarket }
        return brokerCodeMarket
    }
    
    private static func decodeBrokerName(from components: [String]) throws -> String {
        guard components.indices.contains(3) else { throw CedroServiceError.dontContainsBrokerName }
        return components[3]
    }
    
    private static func decodeBrokerCodeBank(from components: [String]) throws -> Int {
        guard components.indices.contains(4) else { throw CedroServiceError.dontContainsBrokerCodeBank }
        guard let brokerCodeBank = components[4].intValue else { throw CedroServiceError.invalidBrokerCodeBank }
        return brokerCodeBank
    }
    
    private static func decodeMarketCode(from components: [String]) throws -> Int {
        guard components.indices.contains(4) else { throw CedroServiceError.dontContainsMarketCode }
        guard let marketCode = components[4].intValue else { throw CedroServiceError.invalidMarketCode }
        return marketCode
    }
}
