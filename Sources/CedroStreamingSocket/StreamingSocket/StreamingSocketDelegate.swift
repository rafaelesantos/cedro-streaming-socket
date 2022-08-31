import Foundation

protocol StreamingSocketDelegate: AnyObject {
    func socketReceived(message: String)
    func receivedNil()
}

extension StreamingSocketDelegate {
    func receivedNil() { }
}
