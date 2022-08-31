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
    
    private func closeNetworkConnection() {
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
            let s = self.readStringFrom(stream: aStream as! InputStream)
            self.closeNetworkConnection()
            if let s = s {
                self.delegate?.socketDataReceived(result: Data(s.utf8))
            }else {
                self.delegate?.receivedNil()
            }
        case .endEncountered:
            print("end of inputStream")
        case .errorOccurred:
            print("error occured")
        case .hasSpaceAvailable:
            print("has space available")
        case .openCompleted:
            isOpen = true
            print("open completed")
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
        return Data(bytes: buffer, count: size)
    }
    
    private func readStringFrom(stream: InputStream, withSize: Int) -> String? {
        let d = readDataFrom(stream: stream, size: withSize)!
        return String(data: d, encoding: .utf8)
    }
    
    private func readStringFrom(stream: InputStream) -> String? {
        let len: Int = Int(Int32(readIntFrom(stream: inputStream)!))
        return readStringFrom(stream: stream, withSize: len)
    }
    
    private func readIntFrom(stream: InputStream) -> UInt32? {
        let buffer = getBufferFrom(stream: stream, size: 4)
        var int: UInt32 = 0
        let data = NSData(bytes: buffer, length: 4)
        data.getBytes(&int, length: 4)
        int = UInt32(bigEndian: int)
        buffer.deallocate()
        return int
    }
    
    private func readUInt8From(stream: InputStream) -> UInt8? {
        let buffer = getBufferFrom(stream: stream, size: 1)
        buffer.deallocate()
        return buffer.pointee
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
