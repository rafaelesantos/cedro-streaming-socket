import Foundation

protocol BookQuoteDelegate {
    func bookQuoteOffersAdd(didReceived bookQuoteOffersAdd: BookQuoteOffersAdd)
    func bookQuoteOffersUpdate(didReceived bookQuoteOffersUpdate: BookQuoteOffersUpdate)
    func bookQuoteOffersCancel(didReceived bookQuoteOffersCancel: BookQuoteOffersCancel)
    func bookQuoteEndOfInitialMessages(didReceived bookQuoteEndOfInitialMessages: BookQuoteEndOfInitialMessages)
}

public protocol BookQuoteStreamingSocketDelegate {
    func bookQuote(didReceived bookQuote: [BookQuoteOffersAdd], contentType: BookQuoteContentType)
}

public final class BookQuoteStreamingSocket {
    public private(set) var bookQuoteOffersAdd = [BookQuoteOffersAdd]()
    public private(set) var bookQuoteOffersUpdate = [BookQuoteOffersUpdate]()
    public private(set) var bookQuoteOffersCancel = [BookQuoteOffersCancel]()
    public private(set) var bookQuoteEndOfInitialMessages = [BookQuoteEndOfInitialMessages]()
    public private(set) var bookQuote = [BookQuoteOffersAdd]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: BookQuoteStreamingSocketDelegate
    private var currentAsset: String
    private let delegateQueue = DispatchQueue(label: "cedro.streaming.socket.bookquote.delegate", attributes: .concurrent)
    private let socketQueue = DispatchQueue(label: "cedro.streaming.socket.bookquote.socket", attributes: .concurrent)
    
    public init(
        authentication: SocketAuthenticationProtocol,
        endpoint: SocketEndpointProtocol,
        asset: String,
        delegate: BookQuoteStreamingSocketDelegate
    ) throws {
        currentAsset = asset
        self.delegate = delegate
        cedroStreamingSocket = CedroStreamingSocket(authentication: authentication, endpoint: endpoint)
        cedroStreamingSocket.bookQuoteDelegate = self
        try newSubscribe(asset: asset)
    }
    
    public func newSubscribe(asset: String) throws {
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
    func bookQuoteOffersAdd(didReceived bookQuoteOffersAdd: BookQuoteOffersAdd) {
        self.bookQuoteOffersAdd.append(bookQuoteOffersAdd)
        bookQuote.append(bookQuoteOffersAdd)
        delegate.bookQuote(didReceived: bookQuote, contentType: .offersAdd)
    }
    
    func bookQuoteOffersUpdate(didReceived bookQuoteOffersUpdate: BookQuoteOffersUpdate) {
        self.bookQuoteOffersUpdate.append(bookQuoteOffersUpdate)
        if let bookQuoteToUpdateIndex = bookQuote.firstIndex(where: {
            $0.orderId == bookQuoteOffersUpdate.orderId &&
            $0.position == bookQuoteOffersUpdate.oldPosition &&
            $0.asset == bookQuoteOffersUpdate.asset
        }) {
            bookQuote[bookQuoteToUpdateIndex] = BookQuoteOffersAdd(
                asset: bookQuoteOffersUpdate.asset,
                position: bookQuoteOffersUpdate.newPosition,
                direction: bookQuoteOffersUpdate.direction,
                price: bookQuoteOffersUpdate.price,
                amount: bookQuoteOffersUpdate.amount,
                broker: bookQuoteOffersUpdate.broker,
                dateHour: bookQuoteOffersUpdate.dateHour,
                orderId: bookQuoteOffersUpdate.orderId,
                offerType: bookQuoteOffersUpdate.offerType
            )
        }
        delegate.bookQuote(didReceived: bookQuote, contentType: .offersUpdate)
    }
    
    func bookQuoteOffersCancel(didReceived bookQuoteOffersCancel: BookQuoteOffersCancel) {
        self.bookQuoteOffersCancel.append(bookQuoteOffersCancel)
        if let bookQuoteToCancelIndex = bookQuote.firstIndex(where: {
            $0.asset == bookQuoteOffersCancel.asset &&
            $0.position == bookQuoteOffersCancel.position &&
            $0.direction == bookQuoteOffersCancel.direction
        }) {
            bookQuote.remove(at: bookQuoteToCancelIndex)
        }
        delegate.bookQuote(didReceived: bookQuote, contentType: .offersCancel)
    }
    
    func bookQuoteEndOfInitialMessages(didReceived bookQuoteEndOfInitialMessages: BookQuoteEndOfInitialMessages) {
        self.bookQuoteEndOfInitialMessages.append(bookQuoteEndOfInitialMessages)
        delegate.bookQuote(didReceived: bookQuote, contentType: .endOfInitialMessages)
    }
}
