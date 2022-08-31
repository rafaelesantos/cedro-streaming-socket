import Foundation

extension AggregatedBook {
    public var sortedByPosition: Self {
        return self.sorted(by: { sortValidation(prev: sortValidationPosition(at: $0), next: sortValidationPosition(at: $1)) })
    }
    
    private func sortValidationPosition(at value: AggregatedBookOffers) -> Int? {
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
