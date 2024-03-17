//
//  Stack.swift
//
//
//  Created by Christopher Charles Cavnor on 3/17/24.
//

import IteratableListProtocol
import LinkedList

/// A Stack is a last-in-first-out (LIFO) data structure.
/// This is  implementation uses a linked list as the underlying container.
public final class Stack<T: Comparable>: IteratableP {
    private let list: LinkedList<T>

    /// Number of elements in Stack
    /// - Complexity: O(n)
    public var size: Int {
        return list.size
    }

    /// Check if the Stack is empty
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

    /// Push (enqueue) an element onto Stack.
    ///
    /// - Parameters:
    ///   - element: The element to insert
    /// - Complexity: O(1)
    public func push(_ element: (T)) {
        list.append(element)
    }

    /// Pop (dequeue) an element from Stack and return it.
    ///
    /// - Returns: the next element of Stack
    public func pop() -> (T)? {
        return list.remove(at: size-1)
    }

    /// Return the next element to be popped (without removing it from the Stack).
    ///
    /// - Returns: the next element of the Stack
    public func peek() -> (T)? {
        return list.tail?.value
    }

    /// Check if an element exists in the Stack.
    ///
    /// - Parameters:
    ///   - element: The element to check for
    /// - Returns: True if the element exists in the Stack, false otherwise.
    /// - Complexity: O(n)
    public func contains(_ element: T) -> Bool {
        return list.contains(value: element)
    }

    /// Remove all elements of the Stack
    public func removeAll() {
        list.removeAll()
    }
}

// MARK: Extension to enable the standard conversion of a list to String
extension Stack: CustomStringConvertible {
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
extension Stack {
    convenience init(array: Array<T>) {
        self.init()

        array.forEach { list.append($0) }
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension Stack: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()

        elements.forEach { list.append($0) }
    }
}

