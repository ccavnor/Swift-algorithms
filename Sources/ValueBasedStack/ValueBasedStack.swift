//
//  File.swift
//  
//
//  Created by Christopher Charles Cavnor on 5/6/22.
//

public enum ValueBasedStack<T: Comparable> {
    case empty
    case node(T)
    indirect case list(T, ValueBasedStack)

    public init() {
        self = .empty
    }

    /* How many nodes are in this stack. Performance: O(n). */
    public var size: Int {
        switch self {
        case .empty: return 0
        case .node: return 1
        case let .list(_, rest): return rest.size + 1
        }
    }

    public func push(_ element: T) -> ValueBasedStack {
        switch self {
        case .empty:
            return .node(element)
        case .node:
            return .list(element, self)
        case let .list(n,ls):
            return .list(element, ls.push(n))
        }
    }

    // Returns an optional tuple of two elements:
    // - the first is the popped value
    // - the second is the rest of the list (to maintain )
    // If you throw away the second element of the tuple (the rest of the stack) rather than using it as the
    // new (post-popped) stack, then this func is essentially a peek instead of a pop.
    public func pop() -> (T,ValueBasedStack)? {
        if case let .list(v, rest) = self {
            return (v, rest)
        }
        if case let .node(v) = self {
            return (v, .empty)
        }
        return nil
    }

    // get the first added element (ie. the last element to be popped)
    public func first() -> T? {
        var temp = self
        var first: T?
        while case let .list(l, ls) = temp {
            (first, temp) = (l, ls)
        }
        if case let .node(v) = temp {
            first = v
        }
        return first
    }
    
    public var toArray: [T] {
        var stack = self
        var arr = [T]()
        while let (node, rest) = stack.pop() {
            arr.append(node)
            stack = rest
        }
        return arr
    }

    public var debugDescription: String {
        switch self {
        case .empty: return "."
        case .node(let value): return "\(value)"
        case .list(let value, let list):
            return "\(value) -> \(list.debugDescription)"
        }
    }

}

extension ValueBasedStack: CustomDebugStringConvertible {
//    public var toArray: [T] {
//        var stack = self
//        var arr = [T]()
//        while let (node, rest) = stack.pop() {
//            arr.append(node)
//            stack = rest
//        }
//        return arr
//    }
//
//    public var debugDescription: String {
//        switch self {
//        case .empty: return "."
//        case .node(let value): return "\(value)"
//        case .list(let value, let list):
//            return "\(value) -> \(list.debugDescription)"
//        }
//    }
}
