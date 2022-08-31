import Foundation

protocol PlayerDelegate: AnyObject {
    func player(didReceived player: Player)
    func playerEndOfInitialMessages(didReceived playerEndOfInitialMessages: PlayerEndOfInitialMessages)
}

public protocol PlayerStreamingSocketDelegate {
    func players(didReceived players: [Player], contentType: PlayerContentType)
}

public final class PlayerStreamingSocket {
    public private(set) var players = [Player]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: PlayerStreamingSocketDelegate
    private var currentMarket: Market
    
    public init(
        _ cedroStreamingSocket: CedroStreamingSocket,
        _ delegate: PlayerStreamingSocketDelegate,
        market: Market
    ) throws {
        currentMarket = market
        self.delegate = delegate
        self.cedroStreamingSocket = cedroStreamingSocket
        self.cedroStreamingSocket.playerDelegate = self
        try newSubscribe(market: currentMarket)
    }
    
    public func newSubscribe(market: Market) throws {
        currentMarket = market
        try cedroStreamingSocket.subscribePlayer(market: market)
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
        delegate.players(didReceived: players, contentType: .player)
    }
    
    func playerEndOfInitialMessages(didReceived playerEndOfInitialMessages: PlayerEndOfInitialMessages) {
        delegate.players(didReceived: players, contentType: .endOfInitialMessages)
    }
}
