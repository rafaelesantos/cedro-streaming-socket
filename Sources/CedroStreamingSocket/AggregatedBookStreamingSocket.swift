import Foundation

protocol AggregatedBookDelegate: AnyObject {
    func aggregatedBookOffersAdd(didReceived aggregatedBookOffersAdd: AggregatedBookOffersAdd)
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate)
    func aggregatedBookOffersCancel(didReceived aggregatedBookOffersCancel: AggregatedBookOffersCancel)
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages)
}

public protocol AggregatedBookStreamingSocketDelegate: AnyObject {
    func aggregatedBook(didReceived aggregatedBook: AggregatedBook, contentType: AggregatedBookContentType)
}

public final class AggregatedBookStreamingSocket {
    private var _aggregatedBook = [String: AggregatedBookOffer]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var currentAsset: String
    
    private weak var delegate: AggregatedBookStreamingSocketDelegate?
    
    public var aggregatedBook: AggregatedBook {
        return Array(_aggregatedBook.values).sortedByPosition
    }
    
    public init(
        _ cedroStreamingSocket: CedroStreamingSocket,
        _ delegate: AggregatedBookStreamingSocketDelegate,
        asset: String
    ) throws {
        currentAsset = asset
        self.delegate = delegate
        self.cedroStreamingSocket = cedroStreamingSocket
        cedroStreamingSocket.aggregatedBookDelegate = self
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            try? self?.newSubscribe(asset: asset)
        }
    }
    
    public func newSubscribe(asset: String) throws {
        unsubscribe()
        currentAsset = asset
        try cedroStreamingSocket.subscribeAggregatedBook(asset: asset)
    }
    
    public func unsubscribe() {
        cedroStreamingSocket.unsubscribeAggregatedBook(asset: currentAsset)
        _aggregatedBook = [:]
    }
}

// MARK: - AggregatedBook
extension AggregatedBookStreamingSocket: AggregatedBookDelegate {
    func aggregatedBookOffersAdd(didReceived aggregatedBookOffersAdd: AggregatedBookOffersAdd) {
        let index = "\(aggregatedBookOffersAdd.asset).\(aggregatedBookOffersAdd.position)"
        if aggregatedBookOffersAdd.direction == .buy {
            _aggregatedBook[index] = AggregatedBookOffer(buy: aggregatedBookOffersAdd, sell: _aggregatedBook[index]?.sell)
        } else if aggregatedBookOffersAdd.direction == .sell {
            _aggregatedBook[index] = AggregatedBookOffer(buy: _aggregatedBook[index]?.buy, sell: aggregatedBookOffersAdd)
        }
        delegate?.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersAdd)
    }
    
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate) {
        let index = "\(aggregatedBookOffersUpdate.asset).\(aggregatedBookOffersUpdate.position)"
        if aggregatedBookOffersUpdate.direction == .buy {
            _aggregatedBook[index] = AggregatedBookOffer(buy: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate), sell: _aggregatedBook[index]?.sell)
        } else if aggregatedBookOffersUpdate.direction == .sell {
            _aggregatedBook[index] = AggregatedBookOffer(buy: _aggregatedBook[index]?.buy, sell: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate))
        }
        delegate?.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersUpdate)
    }
    
    func aggregatedBookOffersCancel(didReceived aggregatedBookOffersCancel: AggregatedBookOffersCancel) {
        if aggregatedBookOffersCancel.offerCancelType == .allBuySell {
            _aggregatedBook = [:]
        } else if let position = aggregatedBookOffersCancel.position, let direction = aggregatedBookOffersCancel.direction {
            let index = "\(aggregatedBookOffersCancel.asset).\(position)"
            if direction == .buy {
                _aggregatedBook[index]?.buy = nil
            } else if direction == .sell {
                _aggregatedBook[index]?.sell = nil
            }
        }
        delegate?.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersCancel)
    }
    
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages) {
        delegate?.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .endOfInitialMessages)
    }
}
