import XCTest
@testable import CedroStreamingSocket

final class CedroStreamingSocketTests: XCTestCase {
    let expectation = XCTestExpectation()
    let authentication = SocketAuthentication(username: "btgrafaelescaleira", password: "bupgy1-pixmud-Macqaz")
    let endpoint = SocketEndpoint(host: "datafeedcd3.cedrotech.com", port: 81)
    lazy var cedroStreamingSocket: CedroStreamingSocket = {
        return CedroStreamingSocket(authentication: authentication, endpoint: endpoint)
    }()
    
//    func testBookQuote() throws {
//        _ = try BookQuoteStreamingSocket(cedroStreamingSocket, self, asset: "winv22")
//        wait(for: [expectation], timeout: 600)
//    }
//
//    func testPlayers() throws {
//        _ = try PlayerStreamingSocket(cedroStreamingSocket, self, market: .bovespa)
//        wait(for: [expectation], timeout: 600)
//    }
    
    func testAggregatedBook() throws {
        let aggregatedBook = try AggregatedBookStreamingSocket(cedroStreamingSocket, self, asset: "winv22")
        _ = try PlayerStreamingSocket(cedroStreamingSocket, self, market: .bovespa)
        _ = try PlayerStreamingSocket(cedroStreamingSocket, self, market: .bmf)
        wait(for: [expectation], timeout: 600)
    }
}

extension CedroStreamingSocketTests: BookQuoteStreamingSocketDelegate {
    func bookQuote(didReceived bookQuote: [BookQuoteOffersAdd], contentType: BookQuoteContentType) {
        print("\n[INFO] [Book Quote] at \(Date())\n*\tBook Content Type: \(contentType)\n*\tCount Book Items: \(bookQuote.count)\n*\tSymbol: \(bookQuote.first?.asset)\n")
    }
}

extension CedroStreamingSocketTests: PlayerStreamingSocketDelegate {
    func players(didReceived players: [Player], contentType: PlayerContentType) {
        if contentType == .endOfInitialMessages {
            print("\n[INFO] [Players] at \(Date())\n*\tCount Players: \(players.count)\n*\tPlayers: \(players.prettyJson)\n")
        }
    }
}

extension CedroStreamingSocketTests: AggregatedBookStreamingSocketDelegate {
    func aggregatedBook(didReceived aggregatedBook: AggregatedBook, contentType: AggregatedBookContentType) {
        print("\n[INFO] [Aggregated Book Quote] at \(Date())\n*\tAggregated Book Content Type: \(contentType)\n*\tCount Aggregated Book Items: \(aggregatedBook.count)\n*\tSymbol: \(aggregatedBook.first?.buy?.asset ?? "")\n")
    }
}
