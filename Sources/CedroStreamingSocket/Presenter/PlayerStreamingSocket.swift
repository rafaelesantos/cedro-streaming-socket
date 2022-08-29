import Foundation

protocol PlayerDelegate {
    func player(didReceived player: Player)
}

public protocol PlayerStreamingSocketDelegate {
    func players(didReceived players: [Player])
}

public final class PlayerStreamingSocket {
    public private(set) var players = [Player]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: PlayerStreamingSocketDelegate
    private var currentMarket: Market
    private let delegateQueue = DispatchQueue(label: "cedro.streaming.socket.player.delegate", attributes: .concurrent)
    private let socketQueue = DispatchQueue(label: "cedro.streaming.socket.player.socket", attributes: .concurrent)
    
    public init(
        authentication: SocketAuthenticationProtocol,
        endpoint: SocketEndpointProtocol,
        market: Market,
        delegate: PlayerStreamingSocketDelegate
    ) throws {
        currentMarket = market
        self.delegate = delegate
        cedroStreamingSocket = CedroStreamingSocket(authentication: authentication, endpoint: endpoint)
        cedroStreamingSocket.playerDelegate = self
        try newSubscribe(market: currentMarket)
    }
    
    public func newSubscribe(market: Market) throws {
        currentMarket = market
        try cedroStreamingSocket.subscribePlayer(market: market, delegateQueue: delegateQueue, socketQueue: socketQueue)
    }
    
    public func unsubscribe() {
        players = []
        closeConnection()
    }
    
    public func closeConnection() {
        cedroStreamingSocket.closeConnection()
    }
}

// MARK: - Player Delegate
extension PlayerStreamingSocket: PlayerDelegate {
    func player(didReceived player: Player) {
        players.append(player)
        delegate.players(didReceived: players)
    }
}
