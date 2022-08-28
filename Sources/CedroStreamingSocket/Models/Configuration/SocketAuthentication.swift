import Foundation

public protocol SocketAuthenticationProtocol {
    var username: String { get set }
    var password: String { get set }
}

public struct SocketAuthentication: SocketAuthenticationProtocol {
    public var username: String
    public var password: String
}
