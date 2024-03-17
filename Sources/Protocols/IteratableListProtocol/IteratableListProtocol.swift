//
//  IteratableListProtocol.swift
//
//
//  Created by Christopher Charles Cavnor on 3/16/24.
//

/// Base protocol for iteratable list ADT implementations.

// All members of IteratableP are value-based operations.
// However, implementations are Bags (same-valued elements
// may appear two or more times). Therefore, implementations
// might include reference-based operations to underlying
// elements.
public protocol IteratableP: Sequence {
    associatedtype T: Comparable
    var size: Int { get }
    var isEmpty: Bool { get }

    func push(_ element: T)
    func pop() -> (T)?
    func peek() -> (T)?
    func contains(_ element: T) -> Bool

    func removeAll()
}

