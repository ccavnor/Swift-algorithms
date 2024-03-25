//
//  LinkedList.swift
//
//
//  Created by Christopher Charles Cavnor on 4/10/23.
//  Copyright © 2023 Christopher Cavnor. All rights reserved.

// MARK: Errors
fileprivate enum ListError: Error {
    case empty
    case outOfBounds(String)
}

// MARK: - LinkedListNode
/// LinkedList node type
open class LinkedListNode<T>: Equatable {
    public internal(set) var value: T
    public internal(set) var next: LinkedListNode?
    public internal(set) weak var previous: LinkedListNode?

    public init(value: T) {
        self.value = value
    }

    /// Equatable by reference
    public static func == (lhs: LinkedListNode<T>, rhs: LinkedListNode<T>) -> Bool {
        lhs === rhs
    }
}

// MARK: LinkedListNode - Extension to enable the standard conversion of a list to String
extension LinkedListNode: CustomStringConvertible {
    public var description: String {
        var s = ""
        let prev = previous?.value
        let next = next?.value

        if prev == nil {
            s = "."
        } else {
            s = "\(prev!)"
        }
        s += " <<< \(value) >>> "
        if next == nil {
            s += "."
        } else {
            s += "\(next!)"
        }
        return s
    }
}

/// A Doubly Linked List Implementation
public final class LinkedList<T> where T: Comparable {
    public typealias Node = LinkedListNode<T>

    /// Check if list is empty
    public var isEmpty: Bool {
        return head == nil
    }

    /// First node of the list, if not empty
    public private(set) var head: Node?

    /// Last node of the list, if not empty
    public private(set) var tail: Node?

    /// The length of the list (number of nodes)
    /// - Complexity: O(n)
    public var size: Int {
        guard var node = head else {
            return 0
        }

        var count = 1
        while let next = node.next {
            node = next
            count += 1
        }
        return count
    }

    /// Default initializer
    public init() {}

    /// Subscript function to return the node value at a specific index
    ///
    /// - Parameter index: Integer value of the requested value's index
    public subscript(index: Int) -> T? {
        let node = try? self.node(at: index)
        return node?.value
    }

    // MARK: - Contains
    /// Check if an element exists in the list.
    ///
    /// - Parameters:
    ///   - value: The element to check for
    /// - Returns: True if the element exists in the list, false otherwise.
    /// - Complexity: O(n)
    public func contains(value: T) -> Bool {
        let match = filter(predicate: { $0 == value })
        return match.size == 0 ? false : true
    }

    // MARK: - Insertion operations

    /// Function to return the node at a specific index. Throws on index range exceptions.
    /// (Exposing this as public is dangerous - users could change pointer values)
    ///
    /// - Parameter index: Integer value of the node's index to be returned
    /// - Returns: LinkedListNode
    /// - Throws: ListError on index range exceptions
    /// - Complexity: O(n)
    internal func node(at index: Int) throws -> Node {
        guard head != nil else {
            throw(ListError.empty)
        }
        guard index >= 0 else {
            throw(ListError.outOfBounds("index must be greater or equal to 0"))
        }

        if index == 0 {
            return head!
        } else {
            var node = head!.next
            for _ in 1..<index {
                node = node?.next
                if node == nil {
                    throw(ListError.outOfBounds("index is out of bounds."))
                }
            }
            return node!
        }
    }

    /// Append by value to the end of the list.
    ///
    /// - Parameter value: The data value to be appended.
    /// - Complexity: O(1)
    public func append(_ value: T) {
        let newNode = Node(value: value)
        append(newNode)
    }

    /// Append a copy of a LinkedListNode to the end of the list.
    ///
    /// - Parameter node: The node containing the value to be appended.
    /// - Complexity: O(1)
    public func append(_ node: Node) {
        let newNode = node
        if let lastNode = tail {
            newNode.previous = lastNode
            lastNode.next = newNode
            tail = newNode
        } else {
            head = newNode
            tail = head
        }
    }

    /// Append a copy of a LinkedList to the end of the list.
    ///
    /// - Parameter list: The list to be copied and appended.
    /// - Complexity: O(n)
    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        while let node = nodeToCopy {
            append(node.value)
            nodeToCopy = node.next
        }
    }

    /// Insert a value at a specific index. Does nothing if index is out of bounds.
    ///
    /// - Parameters:
    ///   - value: The data value to be inserted
    ///   - index: Integer value of the index to be insterted at
    /// - Complexity: O(n)
    public func insert(_ value: T, at index: Int) {
        let newNode = Node(value: value)
        insert(newNode, at: index)
    }

    /// Insert a copy of a node at a specific index. Does nothing if index is out of bounds.
    ///
    /// - Parameters:
    ///   - node: The node containing the value to be inserted
    ///   - index: Integer value of the index to be inserted at
    /// - Complexity: O(n)
    public func insert(_ newNode: Node, at index: Int) {
        if index == 0 {
            newNode.next = head
            head?.previous = newNode
            head = newNode
            tail = head
        } else {
            if let prev = try? node(at: index - 1) {
                let next = prev.next
                newNode.previous = prev
                newNode.next = next
                if newNode.next == nil { // this is the intitial tail
                    tail = newNode
                }
                next?.previous = newNode
                prev.next = newNode

            }
        }
    }

    /// Insert a copy of a LinkedList at a specific index. Does nothing if index is out of bounds.
    ///
    /// - Parameters:
    ///   - list: The LinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    /// - Complexity: O(n)
    public func insert(_ list: LinkedList, at index: Int) {
        guard !list.isEmpty else { return }

        if index == 0 {
            list.tail?.next = head
            head = list.head
        } else {
            if let prev = try? node(at: index - 1) {
                let next = prev.next

                if next == nil { // this is the intitial tail
                    tail = list.tail
                }

                prev.next = list.head
                list.head?.previous = prev

                list.tail?.next = next
                next?.previous = list.tail
            }
        }
    }

    // MARK: - Remove operations

    /// Function to remove all nodes/value from the list
    /// - Complexity: O(1)
    public func removeAll() {
        head = nil
        tail = nil
    }

    /// Function to remove a specific node.
    /// (Exposing this as public is dangerous - users could change pointer values)
    ///
    /// - Parameter node: The node to be deleted
    /// - Returns: The data value contained in the deleted node.
    /// - Complexity: O(1)
    @discardableResult internal func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            // case: internal node or tail is removed
            prev.next = next
        } else {
            // case: head is removed
            head = next
        }

        // case: head or internal node is removed
        next?.previous = prev

        // case: tail was removed
        if next == nil {
            tail = prev
        }

        // dereference removed node for collection
        node.previous = nil
        node.next = nil

        return node.value
    }

    /// Function to remove the last node/value in the list. 
    ///
    /// - Returns: The data value contained in the deleted node.
    /// - Complexity: O(1)
    @discardableResult public func removeLast() -> T? {
        guard !isEmpty else {
            return nil
        }
        return remove(node: tail!)
    }

    /// Function to remove a node/value at a specific index.
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node, if any
    /// - Complexity: O(n)
    @discardableResult public func remove(at index: Int) -> T? {
        let node = try? self.node(at: index)
        guard let node = node else {
            return nil
        }
        return remove(node: node)
    }
}

// MARK: - Extension to enable the standard conversion of a list to String
extension LinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while let nd = node {
            s += "\(nd.value)"
            node = nd.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

// MARK: - An extension with an implementation of 'map' & 'reduce' & 'filter' functions
extension LinkedList {

    /// Transform the list via the user-provided closure.
    ///
    /// - Parameters:
    ///   - transform: A function from T -> U
    /// - Returns: A copy of the transformed list
    /// - Complexity: O(n)
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        let result = LinkedList<U>()
        var node = head
        while let n = node {
            result.append(transform(n.value))
            node = n.next
        }
        return result
    }

    /// Reduce the list using a binary operation that returns a value of type Node.value.
    ///
    /// - Parameter f: A binary operation (+, _, etc.) to be applied across node values.
    /// - Returns: The aggregated value resulting from application of the operation.
    /// - Complexity: O(n)
    public func reduce(_ f: (T, T) -> T) -> T? {
        guard var node = self.head else {
            return nil
        }
        var result = head!.value
        while let next = node.next {
            node = next
            result = f(result, node.value)
        }
        return result
    }

    /// Return a copy of the list with elements that match the user-provided predicate.
    ///
    /// - Parameters:
    ///   - predicate: A function from T -> Bool
    /// - Returns: A copy of the filtered list
    /// - Complexity: O(n)
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        let result = LinkedList<T>()
        var node = head
        while let nd = node {
            if predicate(nd.value) {
                result.append(nd.value)
            }
            node = nd.next
        }
        return result
    }
}

// MARK: - Extension to enable initialization from an Array
extension LinkedList {
    convenience init(array: Array<T>) {
        self.init()

        array.forEach { append($0) }
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension LinkedList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: T...) {
        self.init()

        elements.forEach { append($0) }
    }
}

// MARK: - Give LinkList conformance to Swift Collection
extension LinkedList: Collection {
    public typealias Index = LinkedListIndex<T>

    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    /// - Complexity: O(1)
    public var startIndex: Index {
        get {
            return LinkedListIndex<T>(node: head, tag: 0)
        }
    }

    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    /// - Complexity: O(n), where n is the number of elements in the list. Indexing size would give O(1)
    public var endIndex: Index {
        get {
            return LinkedListIndex<T>(node: tail, tag: size)
        }
    }

    /// Required subscript, based on a dictionary index.
    /// NOTE: access beyond last index is an error.
    public subscript(position: Index) -> T {
        get {
            return position.node!.value
        }
    }

    /// Method that returns the next index when iterating
    public func index(after idx: Index) -> Index {
        return LinkedListIndex<T>(node: idx.node?.next, tag: idx.tag + 1)
    }
}

// MARK: - Collection Index
/// Custom index type that contains a reference to the node at index 'tag'
public struct LinkedListIndex<T>: Comparable {
    fileprivate let node: LinkedListNode<T>?
    fileprivate let tag: Int

    public static func == <U>(lhs: LinkedListIndex<U>, rhs: LinkedListIndex<U>) -> Bool {
        return (lhs.tag == rhs.tag)
    }

    public static func < <U>(lhs: LinkedListIndex<U>, rhs: LinkedListIndex<U>) -> Bool {
        return (lhs.tag < rhs.tag)
    }
}


