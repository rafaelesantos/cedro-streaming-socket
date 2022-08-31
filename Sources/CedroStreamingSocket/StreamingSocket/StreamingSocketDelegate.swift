import Foundation

protocol StreamingSocketDelegate: AnyObject {
    func didConnected()
    func socketReceived(message: String)
    func receivedNil()
}

extension StreamingSocketDelegate {
    func receivedNil() { }
}
