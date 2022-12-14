import Foundation

public struct BookQuoteEndOfInitialMessages: ServiceModelProtocol {
    public var asset: String
}

// MARK: - ServiceContentProtocol
extension BookQuoteEndOfInitialMessages: ServiceContentProtocol {
    public typealias ServiceContentTypeProtocol = BookQuoteContentType
    public var contentType: ServiceContentTypeProtocol { return .endOfInitialMessages }
}

// MARK: - ServiceProtocol
extension BookQuoteEndOfInitialMessages: ServiceProtocol {
    public static var serviceId: ServiceId { return .bookQuote }
    
    public static func decode(from components: [String]) throws -> BookQuoteEndOfInitialMessages {
        try decodeService(from: components)
        return BookQuoteEndOfInitialMessages(asset: try decodeAsset(from: components))
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
}
