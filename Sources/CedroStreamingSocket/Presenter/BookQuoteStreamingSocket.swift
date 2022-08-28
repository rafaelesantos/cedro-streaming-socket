import Foundation

public protocol BookQuoteDelegate {
    func bookQuoteOffersAdd(didReceived bookQuoteOffersAdd: BookQuoteOffersAdd)
    func bookQuoteOffersUpdate(didReceived bookQuoteOffersUpdate: BookQuoteOffersUpdate)
    func bookQuoteOffersCancel(didReceived bookQuoteOffersCancel: BookQuoteOffersCancel)
    func bookQuoteEndOfInitialMessages(didReceived bookQuoteEndOfInitialMessages: BookQuoteEndOfInitialMessages)
}

public final class BookQuoteStreamingSocket {
    public private(set) var bookQuoteOffersAdd = [BookQuoteOffersAdd]()
    public private(set) var bookQuoteOffersUpdate = [BookQuoteOffersUpdate]()
    public private(set) var bookQuoteOffersCancel = [BookQuoteOffersCancel]()
    public private(set) var bookQuoteEndOfInitialMessages = [BookQuoteEndOfInitialMessages]()
    public var onReceivedBookQuote: (BookQuoteContentType) -> Void
    private var cedroStreamingSocket: CedroStreamingSocket
    private var currentAsset: String
    
    public init(
        authentication: SocketAuthenticationProtocol,
        endpoint: SocketEndpointProtocol,
        asset: String,
        onReceivedBookQuote: @escaping (BookQuoteContentType) -> Void,
        delegateQueue: DispatchQueue = .main,
        socketQueue: DispatchQueue = .global(qos: .background)
    ) throws {
        self.onReceivedBookQuote = onReceivedBookQuote
        currentAsset = asset
        cedroStreamingSocket = CedroStreamingSocket(authentication: authentication, endpoint: endpoint)
        cedroStreamingSocket.bookQuoteDelegate = self
        try newSubscribe(asset: asset, delegateQueue: delegateQueue, socketQueue: socketQueue)
    }
    
    public func newSubscribe(asset: String, delegateQueue: DispatchQueue, socketQueue: DispatchQueue) throws {
        unsubscribe()
        currentAsset = asset
        try cedroStreamingSocket.subscribeBookQuote(asset: asset, delegateQueue: delegateQueue, socketQueue: socketQueue)
    }
    
    public func unsubscribe() {
        cedroStreamingSocket.unsubscribeBookQuote(asset: currentAsset)
        bookQuoteOffersAdd = []
        bookQuoteOffersUpdate = []
        bookQuoteOffersCancel = []
        bookQuoteEndOfInitialMessages = []
    }
    
    public func closeConnection() {
        unsubscribe()
        cedroStreamingSocket.closeConnection()
    }
}

// MARK: - BookQuoteDelegate
extension BookQuoteStreamingSocket: BookQuoteDelegate {
    public func bookQuoteOffersAdd(didReceived bookQuoteOffersAdd: BookQuoteOffersAdd) {
        self.bookQuoteOffersAdd.append(bookQuoteOffersAdd)
        onReceivedBookQuote(.offersAdd)
    }
    
    public func bookQuoteOffersUpdate(didReceived bookQuoteOffersUpdate: BookQuoteOffersUpdate) {
        self.bookQuoteOffersUpdate.append(bookQuoteOffersUpdate)
        onReceivedBookQuote(.offersUpdate)
    }
    
    public func bookQuoteOffersCancel(didReceived bookQuoteOffersCancel: BookQuoteOffersCancel) {
        self.bookQuoteOffersCancel.append(bookQuoteOffersCancel)
        onReceivedBookQuote(.offersCancel)
    }
    
    public func bookQuoteEndOfInitialMessages(didReceived bookQuoteEndOfInitialMessages: BookQuoteEndOfInitialMessages) {
        self.bookQuoteEndOfInitialMessages.append(bookQuoteEndOfInitialMessages)
        onReceivedBookQuote(.endOfInitialMessages)
    }
}
