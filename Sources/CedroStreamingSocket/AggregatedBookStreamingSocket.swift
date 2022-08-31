import Foundation

protocol AggregatedBookDelegate {
    func aggregatedBookOffersAdd(didReceived aggregatedBookOffersAdd: AggregatedBookOffersAdd)
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate)
    func aggregatedBookOffersCancel(didReceived aggregatedBookOffersCancel: AggregatedBookOffersCancel)
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages)
}

public protocol AggregatedBookStreamingSocketDelegate {
    func aggregatedBook(didReceived aggregatedBook: [(buy: AggregatedBookOffersAdd?, sell: AggregatedBookOffersAdd?)], contentType: AggregatedBookContentType)
}

public final class AggregatedBookStreamingSocket {
    private var _aggregatedBook = [String: (buy: AggregatedBookOffersAdd?, sell: AggregatedBookOffersAdd?)]()
    private var cedroStreamingSocket: CedroStreamingSocket
    private var delegate: AggregatedBookStreamingSocketDelegate
    private var currentAsset: String
    
    public var aggregatedBook: [(buy: AggregatedBookOffersAdd?, sell: AggregatedBookOffersAdd?)] {
        return Array(_aggregatedBook.values).sorted(by: { sortValidation(prev: sortValidationPosition(at: $0), next: sortValidationPosition(at: $1)) })
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
        try newSubscribe(asset: asset)
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
            _aggregatedBook[index] = (buy: aggregatedBookOffersAdd, sell: _aggregatedBook[index]?.sell)
        } else if aggregatedBookOffersAdd.direction == .sell {
            _aggregatedBook[index] = (buy: _aggregatedBook[index]?.buy, sell: aggregatedBookOffersAdd)
        }
        delegate.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersAdd)
    }
    
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate) {
        let index = "\(aggregatedBookOffersUpdate.asset).\(aggregatedBookOffersUpdate.position)"
        if aggregatedBookOffersUpdate.direction == .buy {
            _aggregatedBook[index] = (buy: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate), sell: _aggregatedBook[index]?.sell)
        } else if aggregatedBookOffersUpdate.direction == .sell {
            _aggregatedBook[index] = (buy: _aggregatedBook[index]?.buy, sell: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate))
        }
        delegate.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersUpdate)
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
        delegate.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .offersCancel)
    }
    
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages) {
        delegate.aggregatedBook(didReceived: Array(_aggregatedBook.values), contentType: .endOfInitialMessages)
    }
    
    private func sortValidationPosition(at value: (buy: AggregatedBookOffersAdd?, sell: AggregatedBookOffersAdd?)) -> Int? {
        if value.buy == nil {
            if value.sell == nil { return nil }
            else { return value.sell?.position }
        } else { return value.buy?.position }
    }
    
    private func sortValidation(prev: Int?, next: Int?) -> Bool {
        guard let prev = prev, let next = next else { return false }
        return prev < next
    }
}
