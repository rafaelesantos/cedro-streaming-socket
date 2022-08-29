import Foundation

public struct BookQuoteOffersUpdate: ServiceModelProtocol {
    public var asset: String
    /// Nova posição da oferta no livro de ofertas
    public var newPosition: Int
    /// Posição que a oferta ocupava antes da atualização
    public var oldPosition: Int
    /// Direção da oferta. As direções podem ser: oferta de compra (A) ou oferta de venda (V)
    public var direction: OfferDirection
    /// Preço da oferta
    public var price: Double
    /// Quantidade da oferta
    public var amount: Double
    /// Código de identificação da corretora detentora da oferta
    public var broker: Int
    /// Data e hora da oferta
    public var dateHour: Date
    /// Identificador da ordem, único para instrumento no dia.
    public var orderId: String?
    /// Identifica o tipo da oferta. O tipo L indica oferta Limitada, O oferta ao preço de Abertura, X oferta ao melhor preço e M oferta ao preço de Mercado.
    public var offerType: OfferType?
}

// MARK: - ServiceContentProtocol
extension BookQuoteOffersUpdate: ServiceContentProtocol {
    public typealias ServiceContentTypeProtocol = BookQuoteContentType
    public var contentType: ServiceContentTypeProtocol { return .offersUpdate }
}
    
// MARK: - ServiceProtocol
extension BookQuoteOffersUpdate: ServiceProtocol {
    public static var serviceId: ServiceId { return .bookQuote }
    
    public static func decode(from components: [String]) throws -> BookQuoteOffersUpdate {
        try decodeService(from: components)
        return BookQuoteOffersUpdate(
            asset: try decodeAsset(from: components),
            newPosition: try decodeNewPosition(from: components),
            oldPosition: try decodeOldPosition(from: components),
            direction: try decodeDirection(from: components),
            price: try decodePrice(from: components),
            amount: try decodeAmount(from: components),
            broker: try decodeBroker(from: components),
            dateHour: try decodeDateHour(from: components),
            orderId: decodeOrderId(from: components),
            offerType: decodeOfferType(from: components)
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
    
    private static func decodeNewPosition(from components: [String]) throws -> Int {
        guard components.indices.contains(3) else { throw CedroServiceError.dontContainsNewPosition }
        guard let position = components[3].intValue else { throw CedroServiceError.invalidNewPosition }
        return position
    }
    
    private static func decodeOldPosition(from components: [String]) throws -> Int {
        guard components.indices.contains(4) else { throw CedroServiceError.dontContainsOldPosition }
        guard let position = components[4].intValue else { throw CedroServiceError.invalidOldPosition }
        return position
    }
    
    private static func decodeDirection(from components: [String]) throws -> OfferDirection {
        guard components.indices.contains(5) else { throw CedroServiceError.dontContainsDirection }
        guard let direction = OfferDirection(rawValue: components[5]) else { throw CedroServiceError.invalidDirection }
        return direction
    }
    
    private static func decodePrice(from components: [String]) throws -> Double {
        guard components.indices.contains(6) else { throw CedroServiceError.dontContainsPrice }
        guard let price = components[6].doubleValue else { throw CedroServiceError.invalidPrice }
        return price
    }
    
    private static func decodeAmount(from components: [String]) throws -> Double {
        guard components.indices.contains(7) else { throw CedroServiceError.dontContainsAmount }
        guard let amount = components[7].doubleValue else { throw CedroServiceError.invalidAmount }
        return amount
    }
    
    private static func decodeBroker(from components: [String]) throws -> Int {
        guard components.indices.contains(8) else { throw CedroServiceError.dontContainsBroker }
        guard let broker = components[8].intValue else { throw CedroServiceError.invalidBroker }
        return broker
    }
    
    private static func decodeDateHour(from components: [String]) throws -> Date {
        guard components.indices.contains(9) else { throw CedroServiceError.dontContainsDateHour }
        guard let dateHour = components[9].dateHour() else { throw CedroServiceError.invalidDateHour }
        return dateHour
    }
    
    private static func decodeOrderId(from components: [String]) -> String? {
        guard components.indices.contains(10) else { return nil }
        return components[10]
    }
    
    private static func decodeOfferType(from components: [String]) -> OfferType? {
        guard components.indices.contains(11) else { return nil }
        return OfferType(rawValue: components[11])
    }
}
