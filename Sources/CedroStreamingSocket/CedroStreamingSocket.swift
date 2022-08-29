import CocoaAsyncSocket

protocol ServiceProtocol {
    static var serviceId: ServiceId { get }
    static func decode(from components: [String]) throws -> Self
}

final class CedroStreamingSocket: NSObject {
    private var authentication: SocketAuthenticationProtocol
    private var endpoint: SocketEndpointProtocol
    
    var bookQuoteDelegate: BookQuoteDelegate?
    var playerDelegate: PlayerDelegate?
    
    private var socket: GCDAsyncSocket?
    
    init(authentication: SocketAuthenticationProtocol, endpoint: SocketEndpointProtocol) {
        self.authentication = authentication
        self.endpoint = endpoint
    }
    
    private func openConnection(delegateQueue: DispatchQueue = .main, socketQueue: DispatchQueue = .global()) {
        socket = socket == nil ? GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue, socketQueue: socketQueue) : socket
        guard socket != nil else { return }
        try? socket?.connect(toHost: endpoint.host, onPort: endpoint.port)
        let loginCommand = ServiceCommand.login(authentication: authentication)
        self.socket?.write(loginCommand.subscribe, withTimeout: -1, tag: loginCommand.tag)
    }
    
    func closeConnection() {
        let loginCommand = ServiceCommand.login(authentication: authentication)
        socket?.write(loginCommand.unsubscribe, withTimeout: -1, tag: loginCommand.tag)
        socket?.disconnect()
        socket = nil
    }
}


// MARK: - GCDAsyncSocketDelegate
extension CedroStreamingSocket: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        socket = nil
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        guard let allComponents = data.message?.replacingOccurrences(of: "\r", with: "")
            .components(separatedBy: "\n")
            .map({ $0.components(separatedBy: ":") }) else { return sock.readData(withTimeout: -1, tag: 0) }
        
        for components in allComponents {
            if components.indices.contains(0), let serviceId = ServiceId(rawValue: components[0]) {
                switch serviceId {
                case .bookQuote: try? receivedBookQuote(didReceived: components)
                case .player: try? receivedPlayer(didReceived: components)
                }
            }
        }
        
        return sock.readData(withTimeout: -1, tag: 0)
    }
}

// MARK: - Book Quote
extension CedroStreamingSocket {
    func subscribeBookQuote(asset: String, delegateQueue: DispatchQueue, socketQueue: DispatchQueue) throws {
        openConnection(delegateQueue: delegateQueue, socketQueue: socketQueue)
        let bookQuoteCommand = ServiceCommand.bookQuote(asset: asset)
        socket?.write(bookQuoteCommand.subscribe, withTimeout: -1, tag: bookQuoteCommand.tag)
    }
    
    func unsubscribeBookQuote(asset: String) {
        let bookQuoteCommand = ServiceCommand.bookQuote(asset: asset)
        socket?.write(bookQuoteCommand.unsubscribe, withTimeout: -1, tag: bookQuoteCommand.tag)
    }
    
    private func receivedBookQuote(didReceived components: [String]) throws {
        guard components.indices.contains(2) else { throw CedroServiceError.dontContainsContent }
        guard let contentType = BookQuoteContentType(rawValue: components[2]) else { throw CedroServiceError.invalidContentType }
        switch contentType {
        case .offersAdd:
            bookQuoteDelegate?.bookQuoteOffersAdd(didReceived: try BookQuoteOffersAdd.decode(from: components))
        case .offersUpdate:
            bookQuoteDelegate?.bookQuoteOffersUpdate(didReceived: try BookQuoteOffersUpdate.decode(from: components))
        case .offersCancel:
            bookQuoteDelegate?.bookQuoteOffersCancel(didReceived: try BookQuoteOffersCancel.decode(from: components))
        case .endOfInitialMessages:
            bookQuoteDelegate?.bookQuoteEndOfInitialMessages(didReceived: try BookQuoteEndOfInitialMessages.decode(from: components))
        }
    }
}

// MARK: - Player
extension CedroStreamingSocket {
    func subscribePlayer(market: Market, delegateQueue: DispatchQueue, socketQueue: DispatchQueue) throws {
        openConnection(delegateQueue: delegateQueue, socketQueue: socketQueue)
        let playerCommand = ServiceCommand.player(market: market)
        socket?.write(playerCommand.subscribe, withTimeout: -1, tag: playerCommand.tag)
    }
    
    private func receivedPlayer(didReceived components: [String]) throws {
        playerDelegate?.player(didReceived: try Player.decode(from: components))
    }
}
