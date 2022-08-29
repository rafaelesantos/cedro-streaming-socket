import Foundation

public struct BookQuoteOffersAdd: ServiceModelProtocol {
    public var asset: String
    /// Posição da oferta no livro de ofertas
    public var position: Int
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
    /// Identifica o tipo da oferta.
    public var offerType: OfferType?
}

// MARK: - Group By
extension Array where Element == BookQuoteOffersAdd {
    public var sell: Self {
        return filter({ $0.direction == .sell })
    }
    
    public var buy: Self {
        return filter({ $0.direction == .buy })
    }
    
    public var sortByPosition: Self {
        return sorted(by: { $0.position < $1.position })
    }
}

// MARK: - ServiceContentProtocol
extension BookQuoteOffersAdd: ServiceContentProtocol {
    public typealias ServiceContentTypeProtocol = BookQuoteContentType
    public var contentType: ServiceContentTypeProtocol { return .offersAdd }
}

// MARK: - ServiceProtocol
extension BookQuoteOffersAdd: ServiceProtocol {
    public static var serviceId: ServiceId { return .bookQuote }
    
    public static func decode(from components: [String]) throws -> BookQuoteOffersAdd {
        try decodeService(from: components)
        return BookQuoteOffersAdd(
            asset: try decodeAsset(from: components),
            position: try decodePosition(from: components),
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
    
    private static func decodePosition(from components: [String]) throws -> Int {
        guard components.indices.contains(3) else { throw CedroServiceError.dontContainsPosition }
        guard let position = components[3].intValue else { throw CedroServiceError.invalidPosition }
        return position
    }
    
    private static func decodeDirection(from components: [String]) throws -> OfferDirection {
        guard components.indices.contains(4) else { throw CedroServiceError.dontContainsDirection }
        guard let direction = OfferDirection(rawValue: components[4]) else { throw CedroServiceError.invalidDirection }
        return direction
    }
    
    private static func decodePrice(from components: [String]) throws -> Double {
        guard components.indices.contains(5) else { throw CedroServiceError.dontContainsPrice }
        guard let price = components[5].doubleValue else { throw CedroServiceError.invalidPrice }
        return price
    }
    
    private static func decodeAmount(from components: [String]) throws -> Double {
        guard components.indices.contains(6) else { throw CedroServiceError.dontContainsAmount }
        guard let amount = components[6].doubleValue else { throw CedroServiceError.invalidAmount }
        return amount
    }
    
    private static func decodeBroker(from components: [String]) throws -> Int {
        guard components.indices.contains(7) else { throw CedroServiceError.dontContainsBroker }
        guard let broker = components[7].intValue else { throw CedroServiceError.invalidBroker }
        return broker
    }
    
    private static func decodeDateHour(from components: [String]) throws -> Date {
        guard components.indices.contains(8) else { throw CedroServiceError.dontContainsDateHour }
        guard let dateHour = components[8].dateHour() else { throw CedroServiceError.invalidDateHour }
        return dateHour
    }
    
    private static func decodeOrderId(from components: [String]) -> String? {
        guard components.indices.contains(9) else { return nil }
        return components[9]
    }
    
    private static func decodeOfferType(from components: [String]) -> OfferType? {
        guard components.indices.contains(10) else { return nil }
        return OfferType(rawValue: components[10])
    }
}
