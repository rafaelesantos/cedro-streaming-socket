import Foundation

public struct AggregatedBookOffer: ServiceModelProtocol {
    public var buy: AggregatedBookOffersAdd?
    public var sell: AggregatedBookOffersAdd?
    
    public init(buy: AggregatedBookOffersAdd? = nil, sell: AggregatedBookOffersAdd? = nil) {
        self.buy = buy
        self.sell = sell
    }
}
