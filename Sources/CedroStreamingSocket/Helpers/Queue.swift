import Foundation

struct Queue<T> {
    var head: T? { return elements.first }
    var tail: T? { return elements.last }
    private var elements: [T] = []
    
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    mutating func dequeue() {
        guard !elements.isEmpty else { return }
        elements.removeFirst()
    }
}
