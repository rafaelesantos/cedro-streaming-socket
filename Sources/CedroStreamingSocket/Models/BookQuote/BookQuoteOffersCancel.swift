import Foundation

public struct BookQuoteOffersCancel {
    public var asset: String
    /// Identifica o tipo de cancelamento de ofertas que deve ser feito.
    public var offerCancelType: OfferCancelType
    /// Direção da oferta. As direções podem ser: oferta de compra (A) ou oferta de venda (V)
    public var direction: OfferDirection?
    /// Posição da oferta no livro de ofertas
    public var position: Int?
}

// MARK: - BookQuoteContentProtocol
extension BookQuoteOffersCancel: BookQuoteContentProtocol {
    public static var contentType: BookQuoteContentType { return .offersCancel }
}

// MARK: - ServiceProtocol
extension BookQuoteOffersCancel: ServiceProtocol {
    public static var serviceId: ServiceId { return .bookQuote }
    
    public static func decode(from components: [String]) throws -> BookQuoteOffersCancel {
        try decodeService(from: components)
        return BookQuoteOffersCancel(
            asset: try decodeAsset(from: components),
            offerCancelType: try decodeOfferCancelType(from: components),
            direction: decodeDirection(from: components),
            position: decodePosition(from: components)
        )
    }
    
    private static func decodeService(from components: [String]) throws {
        guard components.indices.contains(0) else { throw CedroServiceError.invalidMessageFormat }
        guard components[0] == serviceId.rawValue else { throw CedroServiceError.wrongService }
    }
    
    private static func decodeAsset(from components: [String]) throws -> String {
        guard components.indices.contains(1) else { throw CedroServiceError.dontContainsAsset }
        let asset = components[1]
        guard asset.count >= 4 else { throw CedroServiceError.invalidAsset }
        return asset
    }
    
    private static func decodeOfferCancelType(from components: [String]) throws -> OfferCancelType {
        guard components.indices.contains(3) else { throw CedroServiceError.dontContainsOfferCancelType }
        guard let offerCancelTypeNumber = components[3].intValue, let offerCancelType = OfferCancelType(rawValue: offerCancelTypeNumber) else { throw CedroServiceError.invalidOfferCancelType }
        return offerCancelType
    }
    
    private static func decodeDirection(from components: [String]) -> OfferDirection? {
        guard components.indices.contains(4) else { return nil }
        return OfferDirection(rawValue: components[4])
    }
    
    private static func decodePosition(from components: [String]) -> Int? {
        guard components.indices.contains(5) else { return nil }
        return components[5].intValue
    }
}
