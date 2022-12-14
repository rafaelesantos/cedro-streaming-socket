import Foundation

public enum ServiceCommand {
    case login(authentication: SocketAuthenticationProtocol)
    case bookQuote(asset: String)
    case player(market: Market)
    case aggregatedBook(asset: String)
    
    var subscribe: Data? {
        switch self {
        case .login(let authentication): return "ftcedro\n\(authentication.username)\n\(authentication.password)\n".dataValue
        case .bookQuote(let asset): return "bqt \(asset.lowercased())\n".dataValue
        case .player(let market): return "gpn \(market.rawValue.lowercased())\n".dataValue
        case .aggregatedBook(let asset): return "sab \(asset.lowercased())\n".dataValue
        }
    }
    
    var unsubscribe: Data? {
        switch self {
        case .login(_): return "quit\n".dataValue
        case .bookQuote(let asset): return "ubq \(asset.lowercased())\n".dataValue
        case .player(_): return "".dataValue
        case .aggregatedBook(let asset): return "uab \(asset.lowercased())\n".dataValue
        }
    }
    
    var tag: Int {
        switch self {
        case .login(_): return 1
        case .bookQuote(_): return 2
        case .player(_): return 3
        case .aggregatedBook(_): return 4
        }
    }
}
