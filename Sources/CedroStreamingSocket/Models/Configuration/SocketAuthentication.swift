import Foundation

public protocol SocketAuthenticationProtocol {
    var username: String { get set }
    var password: String { get set }
}

public struct SocketAuthentication: SocketAuthenticationProtocol, Codable {
    public var username: String
    public var password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
