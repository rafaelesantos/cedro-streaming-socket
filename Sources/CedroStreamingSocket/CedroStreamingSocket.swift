import CocoaAsyncSocket

protocol ServiceProtocol {
    static var serviceId: ServiceId { get }
    static func decode(from components: [String]) throws -> Self
}

public final class CedroStreamingSocket: NSObject {
    private var authentication: SocketAuthenticationProtocol
    private var endpoint: SocketEndpointProtocol
    private var isOpenConnection: Bool { return socket != nil && socket?.isConnected == true }
    
    private let delegateQueue = DispatchQueue(
        label: "cedro.streaming.socket.delegate",
        qos: .userInteractive,
        attributes: .concurrent
    )
    
    private let socketQueue = DispatchQueue(
        label: "cedro.streaming.socket.socket",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    var bookQuoteDelegate: BookQuoteDelegate?
    var playerDelegate: PlayerDelegate?
    var aggregatedBookDelegate: AggregatedBookDelegate?
    
    private var socket: GCDAsyncSocket?
    
    public init(authentication: SocketAuthenticationProtocol, endpoint: SocketEndpointProtocol) {
        self.authentication = authentication
        self.endpoint = endpoint
        super.init()
        needOpenConnection()
    }
    
    private func needOpenConnection() {
        if !isOpenConnection { openConnection() }
    }
    
    private func openConnection() {
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
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        socket = nil
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        autoreleasepool {
            if let allComponents = data.message?.replacingOccurrences(of: "\r", with: "")
                .components(separatedBy: "\n")
                .map({ $0.components(separatedBy: ":") }){
                for components in allComponents {
                    if components.indices.contains(0), let serviceId = ServiceId(rawValue: components[0]) {
                        switch serviceId {
                        case .bookQuote: try? receivedBookQuote(didReceived: components)
                        case .player: try? receivedPlayer(didReceived: components)
                        case .aggregatedBook: try? receivedAggregatedBook(didReceived: components)
                        }
                    }
                }
                sock.readData(withTimeout: -1, tag: 0)
            } else { sock.readData(withTimeout: -1, tag: 0) }
        }
    }
    
    private func read(_ sock: GCDAsyncSocket, withTag tag: Int, size: Int) {
        if ServiceCommand.aggregatedBook(asset: "").tag == tag || ServiceCommand.bookQuote(asset: "").tag == tag || ServiceCommand.player(market: .bmf).tag == tag {
            sock.readData(toLength: UInt(size), withTimeout: -1, tag: tag)
        } else {
            sock.readData(withTimeout: -1, tag: tag)
        }
    }
}

// MARK: - Book Quote
extension CedroStreamingSocket {
    func subscribeBookQuote(asset: String) throws {
        needOpenConnection()
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
    func subscribePlayer(market: Market) throws {
        needOpenConnection()
        let playerCommand = ServiceCommand.player(market: market)
        socket?.write(playerCommand.subscribe, withTimeout: -1, tag: playerCommand.tag)
    }
    
    private func receivedPlayer(didReceived components: [String]) throws {
        guard components.indices.contains(2) else { throw CedroServiceError.dontContainsContent }
        if let contentType = PlayerContentType(rawValue: components[2]), contentType == .endOfInitialMessages {
            playerDelegate?.playerEndOfInitialMessages(didReceived: try PlayerEndOfInitialMessages.decode(from: components))
        } else {
            playerDelegate?.player(didReceived: try Player.decode(from: components))
        }
    }
}

// MARK: - Aggregated Book
extension CedroStreamingSocket {
    func subscribeAggregatedBook(asset: String) throws {
        needOpenConnection()
        let aggregatedBookCommand = ServiceCommand.aggregatedBook(asset: asset)
        socket?.write(aggregatedBookCommand.subscribe, withTimeout: -1, tag: aggregatedBookCommand.tag)
    }
    
    func unsubscribeAggregatedBook(asset: String) {
        let aggregatedBookCommand = ServiceCommand.aggregatedBook(asset: asset)
        socket?.write(aggregatedBookCommand.unsubscribe, withTimeout: -1, tag: aggregatedBookCommand.tag)
    }
    
    private func receivedAggregatedBook(didReceived components: [String]) throws {
        guard components.indices.contains(2) else { throw CedroServiceError.dontContainsContent }
        guard let contentType = AggregatedBookContentType(rawValue: components[2]) else { throw CedroServiceError.invalidContentType }
        switch contentType {
        case .offersAdd:
            aggregatedBookDelegate?.aggregatedBookOffersAdd(didReceived: try AggregatedBookOffersAdd.decode(from: components))
        case .offersUpdate:
            aggregatedBookDelegate?.aggregatedBookOffersUpdate(didReceived: try AggregatedBookOffersUpdate.decode(from: components))
        case .offersCancel:
            aggregatedBookDelegate?.aggregatedBookOffersCancel(didReceived: try AggregatedBookOffersCancel.decode(from: components))
        case .endOfInitialMessages:
            aggregatedBookDelegate?.aggregatedBookEndOfInitialMessages(didReceived: try AggregatedBookEndOfInitialMessages.decode(from: components))
        }
    }
}
