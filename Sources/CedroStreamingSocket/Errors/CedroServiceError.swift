import Foundation

public enum CedroServiceError: Error {
    case invalidMessageFormat
    case wrongService
    // MARK: - Book Quote
    case dontContainsAsset
    case invalidAsset
    case dontContainsContent
    case invalidContentType
    case dontContainsPosition
    case invalidPosition
    case dontContainsDirection
    case invalidDirection
    case dontContainsPrice
    case invalidPrice
    case dontContainsAmount
    case invalidAmount
    case dontContainsBroker
    case invalidBroker
    case dontContainsDateHour
    case invalidDateHour
    case dontContainsNewPosition
    case invalidNewPosition
    case dontContainsOldPosition
    case invalidOldPosition
    case dontContainsOfferCancelType
    case invalidOfferCancelType
    // MARK: - Player
    case dontContainsMarketName
    case invalidMarketName
    case dontContainsBrokerCodeMarket
    case invalidBrokerCodeMarket
    case dontContainsBrokerName
    case dontContainsBrokerCodeBank
    case invalidBrokerCodeBank
    case dontContainsMarketCode
    case invalidMarketCode
}
