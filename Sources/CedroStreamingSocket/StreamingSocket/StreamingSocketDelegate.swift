import Foundation

protocol StreamingSocketDelegate: AnyObject {
    func socketDataReceived(result: Data?)
    func receivedNil()
}

extension StreamingSocketDelegate {
    func receivedNil() { }
}
