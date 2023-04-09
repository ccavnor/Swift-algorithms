//
//  TreeProtocol.swift
//  
//
//  Created by Christopher Charles Cavnor on 1/10/23.
//
import Foundation

// Notes for Foundation prototypes:
// Comparable :: <, <=, >=, and >
// AdditiveArithmatic :: +, +=, -, -=, zero
// Number: AdditiveArithmatic :: *, *= // not required?
// Bound (The type for which the expression describes a range): associatedtype Bound : Comparable
// Range (A half-open interval from a lower bound up to, but not including, an upper bound): RangeExpression :: ..<, ==, !==, ~=, overlaps
// ClosedRange (includes both bounds): RangeExpression :: ..., ==, !==, ~=, overlaps
// RangeExpression (A type that can be used to slice a collection) :: ~=
//      array[..<3] // PartialRangeUpTo<Int>
//      array[...3] // PartialRangeThrough<Int>
//      array[1...3] // ClosedRange<Int>
//      array[1...] // PartialRangeFrom<Int>


// MARK: Errors
public enum TreeError: Error {
    case notBalanced
    case invalidTree
    case invalidInterval
}

// MARK: Binary Search Tree Protocol
public protocol TreeValueP: AdditiveArithmetic & Comparable {
    associatedtype NodeValue: TreeValueP
}

// MARK: Interval
public struct Interval<T: IntervalTreeValueP>: IntervalTreeValueP {
    public typealias NodeValue = T

    public var start: T
    public var end: T

    public init(start: T, end: T) throws {
        if end < start { throw TreeError.invalidInterval }
        self.start = start
        self.end = end
    }
}

extension Interval: Comparable {
    /// == (equality)
    /// check that two intervals begin and end at same values
    public static func == (lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return (lhs.start == rhs.start) && (lhs.end == rhs.end)
    }

    /// != (non-equality)
    /// check that two intervals do not overlap
    public static func != (lhs: Interval<T>, rhs: Interval<T>) -> Bool {
        return !(lhs == rhs)
    }

    /// > (gt)
    /// true when a.start > b.start or a.start == b.start and a.end > b.end
    public static func > (lhs: Interval, rhs: Interval) -> Bool {
        if lhs.start > rhs.start { return true }
        else if ((lhs.start == rhs.start) && (lhs.end > rhs.end)) { return true }
        return false
    }

    /// >=  (gte)
    /// true when a.start > b.start or a.start == b.start but a.end > b.end or a == b
    public static func >= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        else if lhs.start == rhs.start { return lhs.end > rhs.end }
        else if (lhs.start >= rhs.start) { return true }
        return false
    }

    /// < (lt)
    /// true when a.start < b.start or a.start == b.start and a.end < b.end
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        if lhs.start < rhs.start { return true }
        else if ((lhs.start == rhs.start) && (lhs.end < rhs.end)) { return true }
        return false
    }

    /// <= (lte)
    /// true when a.start < b.start or a.start == b.start but a.end < b.end or a == b
    public static func <= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        else if lhs.start == rhs.start { return lhs.end < rhs.end }
        else if (lhs.start <= rhs.start) { return true }
        return false
    }
}

extension Interval: AdditiveArithmetic {
    public static var zero: Interval<T> {
        return try! self.init(start: 0 as! T, end: 0 as! T)
    }

    public static func - (lhs: Interval<T>, rhs: Interval<T>) -> Interval<T> {
        do {
            return try Self.init(start: (lhs.start - rhs.start), end: (lhs.end - rhs.end))
        } catch {
            return zero
        }
    }

    public static func + (lhs: Interval<T>, rhs: Interval<T>) -> Interval<T> {
        do {
            return try Self.init(start: (lhs.start + rhs.start), end: (lhs.end + rhs.end))
        } catch {
            return zero
        }
    }
}

public protocol TreeNodeP: AnyObject, Comparable {
    associatedtype NodeType: TreeNodeP
    associatedtype NodeValue: TreeValueP

    // MARK: - Tree information
    var isRoot: Bool { get }
    var isLeaf: Bool { get }
    var isLeftChild: Bool { get }
    var isRightChild: Bool { get }
    var hasLeftChild: Bool { get }
    var hasRightChild: Bool { get }
    var hasAnyChild: Bool { get }
    var hasBothChildren: Bool { get }
}

public protocol TreeP: AnyObject {
    associatedtype NodeType: TreeNodeP
    associatedtype NodeValue: TreeValueP

    // MARK: - Adding items
    // returns Self so cannot be implemented in protocol extension
    @discardableResult func insert(node: NodeType) throws -> NodeType

    // MARK: - Deleting items
    // returns Self so cannot be implemented in protocol extension
    @discardableResult func remove(value: NodeValue) -> NodeType?

    // MARK: - Searching
    func search(value: NodeValue) -> NodeType?
    func contains(value: NodeValue) -> Bool
    func minimum() -> NodeType?
    func maximum() -> NodeType?
    func predecessor(value: NodeValue) -> NodeValue?
    func successor(value: NodeValue) -> NodeValue?
    // NOTE: func subscript(key: NodeValue) -> NodeValue? should be here but its a keyword so cannot add without backticks

    // MARK: - Tree information
    func height() -> Int // distance from root to the lowest leaf
    func height(node: NodeType?) -> Int // distance from given node to the lowest leaf
    var size: Int { get }  // number of nodes in tree
    func inLeftTree(value: NodeValue) -> Bool
    func inRightTree(value: NodeValue) -> Bool

    // MARK: - Traversal
    func traverseInOrder(completion: (NodeValue) -> Void)
    func traversePreOrder(completion: (NodeValue) -> Void)
    func traversePostOrder(completion: (NodeValue) -> Void)
    func map(_ formula: (NodeValue) -> NodeValue) -> [NodeValue]

    // MARK: - output
    func toArray() -> [NodeValue]
    func draw()
}

// MARK: Interval Tree Protocol
public protocol IntervalTreeValueP: TreeValueP {
    var start: NodeValue { get set }
    var end: NodeValue { get set }
}

public protocol IntervalTreeNodeP: TreeNodeP {}


extension Int: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Int

    public var start: Int {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Int {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension UInt: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = UInt
    public var start: UInt {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: UInt {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
extension Float: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Float
    public var start: Float {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Float {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
extension Double: TreeValueP & IntervalTreeValueP {
    public typealias NodeValue = Double
    public var start: Double {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Double {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
