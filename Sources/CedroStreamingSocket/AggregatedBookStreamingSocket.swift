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
    private var delegateQueue = DispatchQueue(label: "cedro.streaming.socket.aggregatedbook.delegate", qos: .userInteractive, attributes: .concurrent)
    private var socketQueue = DispatchQueue(label: "cedro.streaming.socket.aggregatedbook.socket", qos: .userInitiated, attributes: .concurrent)
    
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
        self.cedroStreamingSocket.aggregatedBookDelegate = self
        try newSubscribe(asset: currentAsset)
    }
    
    public func newSubscribe(asset: String) throws {
        socketQueue.async { [weak self] in
            guard let self = self else { return }
            self.unsubscribe()
            self.currentAsset = asset
            try? self.cedroStreamingSocket.subscribeAggregatedBook(asset: asset)
        }
    }
    
    public func unsubscribe() {
        socketQueue.async { [weak self] in
            guard let self = self else { return }
            self.cedroStreamingSocket.unsubscribeAggregatedBook(asset: self.currentAsset)
            self._aggregatedBook = [:]
        }
    }
    
    private func delegateProxy(didReceived aggregatedBook: AggregatedBook, contentType: AggregatedBookContentType) {
        delegateQueue.async { [weak self] in
            self?.delegate?.aggregatedBook(didReceived: aggregatedBook, contentType: contentType)
        }
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
        delegateProxy(didReceived: Array(_aggregatedBook.values), contentType: .offersAdd)
    }
    
    func aggregatedBookOffersUpdate(didReceived aggregatedBookOffersUpdate: AggregatedBookOffersUpdate) {
        let index = "\(aggregatedBookOffersUpdate.asset).\(aggregatedBookOffersUpdate.position)"
        if aggregatedBookOffersUpdate.direction == .buy {
            _aggregatedBook[index] = AggregatedBookOffer(buy: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate), sell: _aggregatedBook[index]?.sell)
        } else if aggregatedBookOffersUpdate.direction == .sell {
            _aggregatedBook[index] = AggregatedBookOffer(buy: _aggregatedBook[index]?.buy, sell: AggregatedBookOffersAdd(aggregatedBookOffersUpdate: aggregatedBookOffersUpdate))
        }
        delegateProxy(didReceived: Array(_aggregatedBook.values), contentType: .offersUpdate)
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
        delegateProxy(didReceived: Array(_aggregatedBook.values), contentType: .offersCancel)
    }
    
    func aggregatedBookEndOfInitialMessages(didReceived aggregatedBookEndOfInitialMessages: AggregatedBookEndOfInitialMessages) {
        delegateProxy(didReceived: Array(_aggregatedBook.values), contentType: .endOfInitialMessages)
    }
}
