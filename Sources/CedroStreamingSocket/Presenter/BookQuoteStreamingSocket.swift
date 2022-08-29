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
    public private(set) var bookQuote = [BookQuoteOffersAdd]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: BookQuoteStreamingSocketDelegate
    private var currentAsset: String
    
    public init(
        _ cedroStreamingSocket: CedroStreamingSocket,
        _ delegate: BookQuoteStreamingSocketDelegate,
        asset: String
    ) throws {
        currentAsset = asset
        self.delegate = delegate
        self.cedroStreamingSocket = cedroStreamingSocket
        cedroStreamingSocket.bookQuoteDelegate = self
        try newSubscribe(asset: asset)
    }
    
    public func newSubscribe(asset: String) throws {
        unsubscribe()
        currentAsset = asset
        try cedroStreamingSocket.subscribeBookQuote(asset: asset)
    }
    
    public func unsubscribe() {
        cedroStreamingSocket.unsubscribeBookQuote(asset: currentAsset)
        bookQuote = []
    }
    
    public func closeConnection() {
        unsubscribe()
        cedroStreamingSocket.closeConnection()
    }
}

// MARK: - BookQuoteDelegate
extension BookQuoteStreamingSocket: BookQuoteDelegate {
    func bookQuoteOffersAdd(didReceived bookQuoteOffersAdd: BookQuoteOffersAdd) {
        if let bookQuoteToPutIndex = bookQuote.firstIndex(where: { $0.position == bookQuoteOffersAdd.position }) {
            bookQuote[bookQuoteToPutIndex] = bookQuoteOffersAdd
        } else {
            bookQuote.append(bookQuoteOffersAdd)
        }
        delegate.bookQuote(didReceived: bookQuote, contentType: .offersAdd)
    }
    
    func bookQuoteOffersUpdate(didReceived bookQuoteOffersUpdate: BookQuoteOffersUpdate) {
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
        if bookQuoteOffersCancel.offerCancelType == .allBuySell {
            bookQuote = []
        } else if let bookQuoteToCancelIndex = bookQuote.firstIndex(where: {
            $0.asset == bookQuoteOffersCancel.asset &&
            $0.position == bookQuoteOffersCancel.position &&
            $0.direction == bookQuoteOffersCancel.direction
        }) {
            bookQuote.remove(at: bookQuoteToCancelIndex)
        }
        delegate.bookQuote(didReceived: bookQuote, contentType: .offersCancel)
    }
    
    func bookQuoteEndOfInitialMessages(didReceived bookQuoteEndOfInitialMessages: BookQuoteEndOfInitialMessages) {
        delegate.bookQuote(didReceived: bookQuote, contentType: .endOfInitialMessages)
    }
}
