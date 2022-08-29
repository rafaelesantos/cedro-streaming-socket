import Foundation

protocol AggregatedBookDelegate {
    func aggregatedBookOffersAdd(didReceived aggregatedBookOffersAdd: AggregatedBookOffersAdd)
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate)
    func aggregatedBookOffersCancel(didReceived aggregatedBookOffersCancel: AggregatedBookOffersCancel)
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages)
}

public protocol AggregatedBookStreamingSocketDelegate {
    func aggregatedBook(didReceived aggregatedBook: [AggregatedBookOffersAdd], contentType: AggregatedBookContentType)
}

public final class AggregatedBookStreamingSocket {
    public private(set) var aggregatedBook = [AggregatedBookOffersAdd]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: AggregatedBookStreamingSocketDelegate
    private var currentAsset: String
    
    public init(
        _ cedroStreamingSocket: CedroStreamingSocket,
        _ delegate: AggregatedBookStreamingSocketDelegate,
        asset: String
    ) throws {
        currentAsset = asset
        self.delegate = delegate
        self.cedroStreamingSocket = cedroStreamingSocket
        cedroStreamingSocket.aggregatedBookDelegate = self
        try newSubscribe(asset: asset)
    }
    
    public func newSubscribe(asset: String) throws {
        unsubscribe()
        currentAsset = asset
        try cedroStreamingSocket.subscribeAggregatedBook(asset: asset)
    }
    
    public func unsubscribe() {
        cedroStreamingSocket.unsubscribeAggregatedBook(asset: currentAsset)
        aggregatedBook = []
    }
}

// MARK: - AggregatedBook
extension AggregatedBookStreamingSocket: AggregatedBookDelegate {
    func aggregatedBookOffersAdd(didReceived aggregatedBookOffersAdd: AggregatedBookOffersAdd) {
        if let aggregatedBookToPutIndex = aggregatedBook.firstIndex(where: { $0.position == aggregatedBookOffersAdd.position }) {
            aggregatedBook[aggregatedBookToPutIndex] = aggregatedBookOffersAdd
        } else {
            aggregatedBook.append(aggregatedBookOffersAdd)
        }
        delegate.aggregatedBook(didReceived: aggregatedBook, contentType: .offersAdd)
    }
    
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate) {
        if let aggregatedBookToUpdateIndex = aggregatedBook.firstIndex(where: {
            $0.position == aggregatedBookOffersUpdate.position &&
            $0.asset == aggregatedBookOffersUpdate.asset
        }) {
            aggregatedBook[aggregatedBookToUpdateIndex] = AggregatedBookOffersAdd(
                asset: aggregatedBookOffersUpdate.asset,
                position: aggregatedBookOffersUpdate.position,
                direction: aggregatedBookOffersUpdate.direction,
                price: aggregatedBookOffersUpdate.price,
                amount: aggregatedBookOffersUpdate.amount,
                offerNumbers: aggregatedBookOffersUpdate.offerNumbers,
                dateHour: aggregatedBookOffersUpdate.dateHour
            )
        }
        delegate.aggregatedBook(didReceived: aggregatedBook, contentType: .offersUpdate)
    }
    
    func aggregatedBookOffersCancel(didReceived aggregatedBookOffersCancel: AggregatedBookOffersCancel) {
        if aggregatedBookOffersCancel.offerCancelType == .allBuySell {
            aggregatedBook = []
        } else if let aggregatedBookToCancelIndex = aggregatedBook.firstIndex(where: {
            $0.asset == aggregatedBookOffersCancel.asset &&
            $0.position == aggregatedBookOffersCancel.position &&
            $0.direction == aggregatedBookOffersCancel.direction
        }) {
            aggregatedBook.remove(at: aggregatedBookToCancelIndex)
        }
        delegate.aggregatedBook(didReceived: aggregatedBook, contentType: .offersCancel)
    }
    
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages) {
        delegate.aggregatedBook(didReceived: aggregatedBook, contentType: .endOfInitialMessages)
    }
}
