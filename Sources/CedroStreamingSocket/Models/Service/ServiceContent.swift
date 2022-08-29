import Foundation

public protocol ServiceContentTypeProtocol { }

public protocol ServiceContentProtocol {
    associatedtype ServiceContentTypeProtocol
    var contentType: ServiceContentTypeProtocol { get }
}
