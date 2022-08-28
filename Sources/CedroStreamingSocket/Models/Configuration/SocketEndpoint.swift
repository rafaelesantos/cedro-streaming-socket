import Foundation

public protocol SocketEndpointProtocol {
    var host: String { get set }
    var port: UInt16 { get set }
}

public struct SocketEndpoint: SocketEndpointProtocol {
    public var host: String
    public var port: UInt16
}
