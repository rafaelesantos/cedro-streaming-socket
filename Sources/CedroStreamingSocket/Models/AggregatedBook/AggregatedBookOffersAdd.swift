import Foundation

public struct AggregatedBookOffersAdd: ServiceModelProtocol {
    public var asset: String
    /// Posição da oferta no livro de ofertas. Inicia em zero.
    public var position: Int
    /// Direção da oferta. As direções podem ser: oferta de compra (A) ou oferta de venda (V)
    public var direction: OfferDirection
    /// Preço da oferta
    public var price: Double
    /// Quantidade da oferta
    public var amount: Double
    /// Número de ofertas agregadas.
    public var offerNumbers: Int
    /// Data e hora da oferta
    public var dateHour: Date
    
    init(asset: String, position: Int, direction: OfferDirection, price: Double, amount: Double, offerNumbers: Int, dateHour: Date) {
        self.asset = asset
        self.position = position
        self.direction = direction
        self.price = price
        self.amount = amount
        self.offerNumbers = offerNumbers
        self.dateHour = dateHour
    }
    
    init(aggregatedBookOffersUpdate: AggregatedBookOffersUpdate) {
        asset = aggregatedBookOffersUpdate.asset
        position = aggregatedBookOffersUpdate.position
        direction = aggregatedBookOffersUpdate.direction
        price = aggregatedBookOffersUpdate.price
        amount = aggregatedBookOffersUpdate.amount
        offerNumbers = aggregatedBookOffersUpdate.offerNumbers
        dateHour = aggregatedBookOffersUpdate.dateHour
    }
}

// MARK: - Group By
extension Array where Element == AggregatedBookOffersAdd {
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
extension AggregatedBookOffersAdd: ServiceContentProtocol {
    public typealias ServiceContentTypeProtocol = AggregatedBookContentType
    public var contentType: ServiceContentTypeProtocol { return .offersAdd }
}

// MARK: - ServiceProtocol
extension AggregatedBookOffersAdd: ServiceProtocol {
    public static var serviceId: ServiceId { return .aggregatedBook }
    
    public static func decode(from components: [String]) throws -> AggregatedBookOffersAdd {
        try decodeService(from: components)
        return AggregatedBookOffersAdd(
            asset: try decodeAsset(from: components),
            position: try decodePosition(from: components),
            direction: try decodeDirection(from: components),
            price: try decodePrice(from: components),
            amount: try decodeAmount(from: components),
            offerNumbers: try decodeOfferNumbers(from: components),
            dateHour: try decodeDateHour(from: components)
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
    
    private static func decodeOfferNumbers(from components: [String]) throws -> Int {
        guard components.indices.contains(7) else { throw CedroServiceError.dontContainsOfferNumbers }
        guard let offerNumbers = components[7].intValue else { throw CedroServiceError.invalidOfferNumbers }
        return offerNumbers
    }
    
    private static func decodeDateHour(from components: [String]) throws -> Date {
        guard components.indices.contains(8) else { throw CedroServiceError.dontContainsDateHour }
        guard let dateHour = components[8].dateHour() else { throw CedroServiceError.invalidDateHour }
        return dateHour
    }
}
