//
//  ValueBasedStack.swift
//
//
//  Created by Christopher Charles Cavnor on 5/6/22.
//

/// A Stack is a last-in-first-out (LIFO) data structure. This is a value-based implementation using an Enum as a container.
/// This implementation is purely functional. All of its operations involve traversals over a list of nodes and run in O(n) time.
public enum Stack<T: Comparable> {
    case empty
    case node(T)
    indirect case list(T, Stack)

    public init() {
        self = .empty
    }

    /// Check if stack has any elements.
    public var isEmpty: Bool {
        return size == 0
    }

    /// How many nodes are in this stack.
    public var size: Int {
        switch self {
        case .empty: return 0
        case .node: return 1
        case let .list(_, rest): return rest.size + 1
        }
    }

    /// Add a new element on the stack.
    /// Recursively calls itself to effectively reverse order of addition.
    public func push(_ element: T) -> Stack {
        switch self {
        case .empty:
            return .node(element)
        case .node:
            return .list(element, self)
        case let .list(n, ls):
            return .list(element, ls.push(n))
        }
    }

    /// Retrieve the last added element.
    /// Returns an optional tuple of two elements:
    /// - the first is the popped value
    /// - the second is the rest of the list (to maintain )
    public func pop() -> (T,Stack)? {
        if case let .list(v, rest) = self {
            return (v, rest)
        }
        if case let .node(v) = self {
            return (v, .empty)
        }
        return nil
    }

    /// Get the value of the next element to be popped.
    public func peek() -> (T)? {
        let (v, _) = pop()!
        return v
    }

    /// get an array of the stack elements, in their popped order.
    public var toArray: [T] {
        var stack = self
        var arr = [T]()
        while let (node, rest) = stack.pop() {
            arr.append(node)
            stack = rest
        }
        return arr
    }
}

extension Stack where T: Equatable {

    /// Check if an element exists in the Queue. This will take O(n) time.
    ///
    /// - Parameters:
    ///   - element: The element to check for
    /// - Returns: True if the element exists in the Queue, false otherwise.
    public func contains(_ element: T) -> Bool {
        var stack = self
        while let (node, rest) = stack.pop() {
            stack = rest
            if (node == element) {
                return true
            }
        }
        return false
    }
}

extension Stack: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .empty: return "."
        case .node(let value): return "\(value)"
        case .list(let value, let list):
            return "\(value) -> \(list.debugDescription)"
        }
    }
}
