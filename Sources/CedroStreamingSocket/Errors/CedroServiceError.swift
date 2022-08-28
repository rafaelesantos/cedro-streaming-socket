import Foundation

public enum CedroServiceError: Error {
    case invalidMessageFormat
    case wrongService
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
}
