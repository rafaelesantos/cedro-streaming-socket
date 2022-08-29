import XCTest
@testable import CedroStreamingSocket

final class CedroStreamingSocketTests: XCTestCase {
    let expectation = XCTestExpectation()
    let authentication = SocketAuthentication(username: "", password: "")
    let endpoint = SocketEndpoint(host: "", port: 00)
    
    func testBookQuote() throws {
        _ = try BookQuoteStreamingSocket(authentication: authentication, endpoint: endpoint, asset: "petr4", delegate: self)
        wait(for: [expectation], timeout: 600)
    }
    
    func testPlayers() throws {
        _ = try PlayerStreamingSocket(authentication: authentication, endpoint: endpoint, market: .bovespa, delegate: self)
        wait(for: [expectation], timeout: 600)
    }
}

extension CedroStreamingSocketTests: BookQuoteStreamingSocketDelegate {
    func bookQuote(didReceived bookQuote: [BookQuoteOffersAdd], contentType: BookQuoteContentType) {
        if contentType == .endOfInitialMessages {
            print("\n[INFO] [Book Quote] at \(Date())\n*\tBook Content Type: \(contentType)\n*\tCount Book Items: \(bookQuote.count)\n*\tCount Book Buy Items Agrouped: \(bookQuote.buy.count)\n*\tCount Book Sell Items Agrouped: \(bookQuote.sell.count)")
        }
    }
}

extension CedroStreamingSocketTests: PlayerStreamingSocketDelegate {
    func players(didReceived players: [Player]) {
        print("\n[INFO] [Players] at \(Date())\n*\tCount Players: \(players.count)\n")
    }
}
