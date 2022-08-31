import Foundation

final class StreamingSocket: NSObject {
    private var authentication: SocketAuthenticationProtocol
    private var endpoint: SocketEndpointProtocol
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    public var isOpen: Bool = false
    
    weak var delegate: StreamingSocketDelegate?
    
    init(authentication: SocketAuthenticationProtocol, endpoint: SocketEndpointProtocol, delegate: StreamingSocketDelegate) {
        self.authentication = authentication
        self.endpoint = endpoint
        self.delegate = delegate
        super.init()
    }
    
    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            endpoint.host as CFString,
            UInt32(endpoint.port),
            &readStream,
            &writeStream
        )
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        inputStream.open()
        outputStream.open()
    }
    
    func disconnect() {
        inputStream.close()
        outputStream.close()
        isOpen = false
    }
    
    func write(string: String) {
        writeToOutputStream(string: string)
    }
}

// MARK: - StreamDelegate
extension StreamingSocket: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            autoreleasepool { [weak self] in
                guard let self = self else { return }
                let data = readDataFrom(stream: aStream as! InputStream, size: 1024 * 1024)
                if let string = data?.message {
                    self.delegate?.socketReceived(message: string)
                } else {
                    self.delegate?.receivedNil()
                }
            }
        case .endEncountered:
            isOpen = false
            print("[INFO] at \(Date())\nDisconnected to server on \(endpoint.host) : \(endpoint.port)")
        case .errorOccurred:
            print("error occured")
        case .hasSpaceAvailable:
            print("has space available")
        case .openCompleted:
            isOpen = true
            print("[INFO] at \(Date())\nConnected to server on \(endpoint.host) : \(endpoint.port)")
        default:
            print("StreamDelegate event")
        }
    }
    
    private func getBufferFrom(stream: InputStream, size: Int) -> UnsafeMutablePointer<UInt8> {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        
        while (stream.hasBytesAvailable) {
            let numberOfBytesRead = self.inputStream.read(buffer, maxLength: size)
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            if numberOfBytesRead == 0 { break }
        }
        return buffer
    }
    
    private func readDataFrom(stream: InputStream, size: Int) -> Data? {
        let buffer = getBufferFrom(stream: stream, size: size)
        let data = Data(bytes: buffer, count: size)
        buffer.deallocate()
        return data
    }
    
    private func writeToOutputStream(string: String){
        let data = string.data(using: .utf8)!
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else {
                print("Error joining")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
}
