import Foundation

public protocol SocketEndpointProtocol {
    var host: String { get set }
    var port: UInt16 { get set }
}

public struct SocketEndpoint: SocketEndpointProtocol, Codable {
    public var host: String
    public var port: UInt16
    
    public init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
}
