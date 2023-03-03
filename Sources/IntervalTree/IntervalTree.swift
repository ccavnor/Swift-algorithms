//
//  IntervalTree.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//

import TreeProtocol
import BinarySearchTree
import AVLTree


// TODO: override BST search to use maxEnd instead of equality checks?

// MARK: - Interval
/// The value slot (T) for the IntervalTree
public final class Interval<T: Comparable & Numeric>: Comparable & Equatable {
    let start: T
    let end: T
    
    init(start: T, end: T) throws {
        if end < start { throw TreeError.invalidInterval }
        self.start = start
        self.end = end
    }
    
    // convert Numeric type to a Float
    private func f<T:Numeric>(_ i: T) -> Float {
        var f: Float = 0
        switch i {
        case let ii as Int:
            f = Float(ii)
        case let ii as Int32:
            f = Float(ii)
        case let ii as Double:
            f = Float(ii)
        case let ii as Float:
            f = ii
        default:
            fatalError("unable to convert value to float")
        }
        return f
    }
    
    /// Length of the interval - returns float to unsure accuracy of decimal intervals
    public func length() -> Float {
        return f(end - start)
    }
    
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
    /// reference interval must be to the right of test interval end
    public static func > (lhs: Interval, rhs: Interval) -> Bool {
        (lhs.start > rhs.end)
    }
    
    /// >=  (gte)
    /// reference interval must begin at or to the right of test interval end
    public static func >= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        return (lhs.start >= rhs.end)
    }
    
    /// < (lt)
    /// test interval must be to the right of reference interval end
    public static func < (lhs: Interval, rhs: Interval) -> Bool {
        return (rhs > lhs)
    }
    
    /// <= (lte)
    /// test interval must begin at or to the right of reference interval end
    public static func <= (lhs: Interval, rhs: Interval) -> Bool {
        if lhs == rhs { return true }
        return (rhs >= lhs)
    }
}

// For Numeric conformance of the Interval type
extension Interval: Numeric {
    public typealias IntegerLiteralType = Int
    public typealias Magnitude = T
    public var magnitude: T {
        return (end - start)
    }
    
    public convenience init(integerLiteral value: Int) {
        self.init(exactly: 0)!
    }
    
    public convenience init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(integerLiteral: 0)
    }
    
    public static func - (lhs: Interval<T>, rhs: Interval<T>) -> Self {
        return try! Self.init(start: (lhs.start - rhs.start), end: (lhs.end - rhs.end))
    }
    
    public static func * (lhs: Interval<T>, rhs: Interval<T>) -> Self {
        return try! Self.init(start: (lhs.start * rhs.start), end: (lhs.end * rhs.end))
    }
    
    public static func + (lhs: Interval<T>, rhs: Interval<T>) -> Self {
        return try! Self.init(start: (lhs.start + rhs.start), end: (lhs.end + rhs.end))
    }
    
    public static func *= (lhs: inout Interval<T>, rhs: Interval<T>) {
        lhs = lhs * rhs
    }
}


// MARK: - Interval Debugging
extension Interval: CustomDebugStringConvertible {
    var description: String {
        "[\(start), \(end)]"
    }
    public var debugDescription: String {
        "[\(start), \(end)]"
    }
}

// MARK: - IntervalNode
public class IntervalNode<T: Comparable & Numeric>: BinarySearchTreeNode<Interval<T>> {
    fileprivate var maxEnd: T
    
    init(interval: Interval<T>) {
        self.maxEnd = interval.end
        super.init(value: interval)
        self.value = interval
    }
    
    public func isOverlapping(node: IntervalNode) -> Bool {
        if node.value.start > value.end {
            return false
        } else if node.value.end < value.start {
            return false
        }
        return true
    }
    
    public func isWithin(node: IntervalNode) -> Bool {
        if node.value.start <= value.start && node.value.end >= value.end {
            return true
        }
        return false
    }
}

// MARK: - IntervalNode Debugging
extension IntervalNode: CustomDebugStringConvertible {
    var description: String {
        "[\(value.start), \(value.end)]:\(self.maxEnd)"
    }
    public var debugDescription: String {
        "[\(value.start), \(value.end)]:\(value.length())"
    }
}

// MARK: - IntervalTree

/// IntervalTree is a AVLTree (therefore a BST) that uses Interval objects as nodes. IntervalTree is constrained to Numeric types,
/// as operations such as length make little sense outside of numerical values.
open class IntervalTree<T: Comparable & Numeric>: AVLTree<Interval<T>> {
    public typealias iNode = IntervalNode<T>
    
    public init(intervalNode: iNode) {
        super.init(node: intervalNode)
    }
    
    public convenience init(array: [Interval<T>]) {
        precondition(array.count > 0)
        let inode = IntervalNode(interval: array.first!)
        self.init(intervalNode: inode)
        for i in array.dropFirst() {
            _ = try? insert(value: i)
        }
    }
    
    /// Returns intervals that overlap with the given interval.
    func overlaps(interval: Interval<T>) -> [Interval<T>] {
        var result: [Interval<T>] = []
        overlaps(node: root as? IntervalNode<T>, interval: interval, result: &result)
        return result
    }
    
    private func overlaps(node: iNode?, interval: Interval<T>, result: inout [Interval<T>]) {
        guard let node = node else {
            return
        }
        let test = IntervalNode(interval: interval)
        
        if test.isOverlapping(node: node) {
            result.append(node.value)
        }
        
        if let left = node.left as? iNode {
            if test.isOverlapping(node: left) {
                overlaps(node: left, interval: interval, result: &result)
            }
        }
        if let right = node.right as? iNode {
            if test.isOverlapping(node: right) {
                overlaps(node: right, interval: interval, result: &result)
            }
        }
    }
    
    /// Returns intervals that are within the given interval.
    func within(interval: Interval<T>) -> [Interval<T>] {
        var result: [Interval<T>] = []
        within(node: root as? IntervalNode<T>, interval: interval, result: &result)
        return result
    }
    
    private func within(node: iNode?, interval: Interval<T>, result: inout [Interval<T>]) {
        guard let node = node else {
            return
        }
        let test = IntervalNode(interval: interval)
        
        // tests that the given interval is inside current IntervalNode
        if test.isWithin(node: node) {
            result.append(node.value)
        }
        
        if let left = node.left as? iNode {
            if test.isWithin(node: left) {
                within(node: left, interval: interval, result: &result)
            }
        }
        if let right = node.right as? iNode {
            if test.isWithin(node: right) {
                within(node: right, interval: interval, result: &result)
            }
        }
    }
    
    /// Insertion is based on start value of interval
    @discardableResult override public func insert(value: Interval<T>) throws -> Self {
        // in case root is not set
        guard let root = self.root else {
            throw TreeError.invalidTree
        }
        return insert(node: root, value: value, parent: nil)
    }
    
    @discardableResult private func insert(node: BinarySearchTreeNode<Interval<T>>,
                                           value: Interval<T>,
                                           parent: BinarySearchTreeNode<Interval<T>>?) -> Self {
        let node: BinarySearchTreeNode<Interval<T>> = node
        let parent = parent ?? root
        
        // insertion is based on start value of interval
        if value.start < node.value.start {
            if let left = node.left {
                insert(node: left, value: value, parent: left )
            } else {
                let temp = IntervalNode(interval: value)
                node.left = temp
                temp.parent = parent
                nodeCount += 1
            }
        } else {
            if let right = node.right {
                insert(node: right, value: value, parent: right)
            } else {
                let temp = IntervalNode(interval: value)
                node.right = temp
                temp.parent = parent
                nodeCount += 1
            }
        }
        
        // update maxEnd
        if let node = node as? IntervalNode {
            //print("** updating maxEnd from \(node.maxEnd) to \(max(node.maxEnd, value.end))")
            node.maxEnd = max(node.maxEnd, value.end)
        }
        
        return self
    }
    
    override public func draw() {
        guard let root = self.root else {
            print("* tree is empty *")
            return
        }
        print("\n") // newline
        print("<<< tree root is \(root.value), size=\(size), height=\(height(node: root)): leaf nodes are marked with ? >>>")
        draw(root)
        print("\n") // newline
    }
    
    /// Since insertion is based on start value of the interval, so too will search look at start value
    public override func search(value: Interval<T>) -> BinarySearchTreeNode<Interval<T>>? {
        guard let root = self.root else {
            return nil
        }
        var node: BinarySearchTreeNode<Interval<T>>? = root
        if root.value == value {
            return root
        }
        while let n = node as? IntervalNode<T> {
            if value.start < n.value.start {
                node = n.left
            } else if value.start > n.value.start {
                node = n.right
            } else {
                return n
            }
        }
        return node
    }
    
    /// This is an alternative to using map on the IntervalTree, which uses the BinarySearchTree implementation of map - requiring
    /// the syntax:
    /// code<tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2)}>
    /// versus doing the same with flatMap:
    /// code<tree.flatMap({ 2 * $0 })> 
    public func flatMap(_ formula: (T) -> T) -> [Interval<T>] {
        var result = [Interval<T>]()
        guard let root = self.root else {
            return result
        }
        flatMap(node: root, apply: formula, result: &result)
        return result
    }
    
    private func flatMap(node: BinarySearchTreeNode<Interval<T>>, apply: ((T) -> T), result: inout [Interval<T>]) {
        if let left = node.left { flatMap(node: left, apply: apply, result: &result) }
        
        let newInterval: Interval<T> = try! Interval(start: apply(node.value.start), end: apply(node.value.end))
        node.value = newInterval // update tree
        result.append(newInterval) // append to results (inorder)
        
        if let right = node.right { flatMap(node: right, apply: apply, result: &result) }
    }
}


extension IntervalTree {
    private func draw(_ node: BinarySearchTreeNode<Interval<T>>) {
        if let left = node.left { print("(", terminator: ""); draw(left); print(" <- ", terminator:""); }
        
        if let node = node as? IntervalNode {
            if node.hasBothChildren { print("\(node.value):\(node.maxEnd)", terminator:"")  }
            else if node.hasLeftChild { print("\(node.value):\(node.maxEnd)", terminator:")") }
            else if node.hasRightChild { print("(\(node.value):\(node.maxEnd)", terminator:"") }
            else { print("\(node.value):\(node.maxEnd)", terminator:"?") } // leaf
        }
        
        if let right = node.right { print(" -> ", terminator:""); draw(right); print("", terminator: ")") }
    }
}
