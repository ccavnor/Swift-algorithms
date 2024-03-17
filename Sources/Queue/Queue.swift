//
//  Queue.swift
//  
//
//  Created by Christopher Charles Cavnor on 3/7/24.
//

import IteratableListProtocol
import LinkedList

/// A Queue is a first-in-first-out (FIFO) data structure.
/// This is  implementation uses a linked list as the underlying container. 
public final class Queue<T: Comparable>: IteratableP {
    private let list: LinkedList<T>

    /// Number of elements in Queue
    /// - Complexity: O(n)
    public var size: Int {
        return list.size
    }
    
    /// Check if the Queue is empty
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        return list.isEmpty
    }

    public init() {
        list = LinkedList<T>()
    }

    /// For conformance to Sequence protocol.
    /// NOTE: This uses LinkedList's iterator, which iterates from head to tail of list.
    public func makeIterator() -> IndexingIterator<LinkedList<T>> {
        return list.makeIterator()
    }

    /// Push (enqueue) an element onto Queue.
    ///
    /// - Parameters:
    ///   - element: The element to insert
    /// - Complexity: O(1)
    public func push(_ element: (T)) {
        list.append(element)
    }

    /// Pop (dequeue) an element from Queue and return it.
    ///
    /// - Returns: the next element of Queue
    public func pop() -> (T)? {
        return list.remove(at: 0)
    }

    /// Return the next element to be popped (without removing it from the Queue).
    ///
    /// - Returns: the next element of the Queue
    public func peek() -> (T)? {
        return list.first
    }
    
    /// Check if an element exists in the Queue. 
    ///
    /// - Parameters:
    ///   - element: The element to check for
    /// - Returns: True if the element exists in the Queue, false otherwise.
    /// - Complexity: O(n)
    public func contains(_ element: T) -> Bool {
        return list.contains(value: element)
    }
    
    /// Remove all elements of the Queue
    public func removeAll() {
        list.removeAll()
    }
}

// MARK: Extension to enable the standard conversion of a list to String
extension Queue: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = list.head
        while let nd = node {
            s += "\(nd.value)"
            node = nd.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

// MARK: - Extension to enable initialization from an Array
extension Queue {
    convenience init(array: Array<T>) {
        self.init()

        array.forEach { list.append($0) }
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension Queue: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()

        elements.forEach { list.append($0) }
    }
}

//===============================================================================================
// Below is an array-based Queue implementation that has no external dependencies.
// - just keeping it around until I decide where to move it.
//===============================================================================================
/////  A Queue is a first-in-first-out (FIFO) data structure. This is a value-based implementation using an array as internal container.
/////  Uses a pointer to keep track of head element so that underlying array is not reallocated unless the element count and
/////  popped elements cross a threshold.
//public struct Queue<T> {
//    // threshold of elements needed to clean up internal container
//    private let REALLOCATE_THRESHOLD = 50
//    private var container = [T]()
//    private var head = 0 // pointer to head element
//
//    /// Number of elements in Queue
//    public var size: Int {
//        // calculate using diff between head pointer and array size
//        return container.count - head
//    }
//    /// Check if the Queue is empty
//    public var isEmpty: Bool {
//        return size == 0
//    }
//
//    /// Push (insert) an element onto Queue.
//    ///
//    /// - Parameters:
//    ///   - element: The element to insert
//    public mutating func push(_ element: T) {
//        container.append(element)
//    }
//
//    /// Pop (remove) an element from Queue and return it. A Queue is FIFO, so the head element of the Queue is returned.
//    /// For efficiency, we only move the head pointer when an element is popped, unless the array has more than
//    /// REALLOCATE_THRESHOLD elements and it is sparse (more that 50% of elements were popped).
//    /// This keeps the array from having to reallocate too often.
//    ///
//    /// - Returns: the head element of Queue
//    public mutating func pop() -> T {
//        let element = container[head]
//        head += 1
//
//        // cleanup sparse array
//        if container.count > REALLOCATE_THRESHOLD && head * 2 > container.count {
//            container.removeFirst(head)
//            head = 0
//        }
//
//        return element
//    }
//
//    /// Return a copy of the head element of the Queue without removing it from the Queue.
//    ///
//    /// - Returns: the head element of the Queue
//    public func peek() -> T {
//        return container[head]
//    }
//
//    /// Remove all elements of the Queue
//    public mutating func removeAll() {
//        // removeAll on array is O(n), drop and reallocate might be faster:
//        container = [T]()
//        head = 0
//    }
//}
//
//extension Queue where T: Equatable {
//
//    /// Check if an element exists in the Queue. This will take O(n) time.
//    ///
//    /// - Parameters:
//    ///   - element: The element to check for
//    /// - Returns: True if the element exists in the Queue, false otherwise.
//    public func contains(_ element: T) -> Bool {
//        let content = container.dropFirst(head)
//        if content.firstIndex(of: element) != nil {
//            return true
//        }
//        return false
//    }
//}
