import Foundation

public enum ServiceCommand {
    case login(authentication: SocketAuthenticationProtocol)
    case bookQuote(asset: String)
    case player(market: Market)
    case aggregatedBook(asset: String)
    
    var subscribe: String {
        switch self {
        case .login(let authentication): return "ftcedro\n\(authentication.username)\n\(authentication.password)\n"
        case .bookQuote(let asset): return "bqt \(asset.lowercased())\n"
        case .player(let market): return "gpn \(market.rawValue.lowercased())\n"
        case .aggregatedBook(let asset): return "sab \(asset.lowercased())\n"
        }
    }
    
    var unsubscribe: String {
        switch self {
        case .login(_): return "quit\n"
        case .bookQuote(let asset): return "ubq \(asset.lowercased())\n"
        case .player(_): return ""
        case .aggregatedBook(let asset): return "uab \(asset.lowercased())\n"
        }
    }
}
