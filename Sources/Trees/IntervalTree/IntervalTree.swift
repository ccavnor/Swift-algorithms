//
//  IntervalTree.swift
//  
//
//  Created by Christopher Charles Cavnor on 4/28/22.
//

import TreeProtocol
import BinarySearchTree
import AVLTree

// MARK: - IntervalNode
open class IntervalTreeNode<T: IntervalTreeValueP>: AVLTreeNode<Interval<T>> where T: Comparable {
    public var maxEnd: T

    public init(node: IntervalTreeNode<T>) {
        self.maxEnd = node.value.end
        super.init(node: node)
        assert(height == 1)
        assert(self.value == node.value)
    }

    required public init(value: Interval<T>) {
        self.maxEnd = value.end
        super.init(value: value)
        assert(height == 1)
        assert(self.value == value)
    }

    public convenience init(start: T, end: T) {
        let i: Interval<T> = try! Interval(start: start, end: end)
        self.init(value: i)
    }

    /// Returns true iff self's interval is overlaps with the given interval. False otherwise.
    public func isOverlapping(node: IntervalTreeNode<T>) -> Bool {
        if node.value.start > value.end {
            return false
        } else if node.value.end < value.start {
            return false
        }
        return true
    }

    /// Returns true iff self's interval is within given interval. False otherwise.
    public func isWithin(node: IntervalTreeNode<T>) -> Bool {
        if node.value.start <= value.start && node.value.end >= value.end {
            return true
        }
        return false
    }

    // convert Numeric type to a Float
    public func f<T:AdditiveArithmetic>(_ i: T) -> Float {
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
    open var length: Float {
        return f(self.value.end - self.value.start)
    }
}

// MARK: - IntervalNode Debugging
extension IntervalTreeNode: CustomDebugStringConvertible {
    var description: String {
        "[\(value.start), \(value.end)]:\(self.maxEnd)"
    }
    public var debugDescription: String {
        "[\(value.start), \(value.end)]:\(self.length)"
    }
}

// MARK: - IntervalTree

/// IntervalTree is a AVLTree (therefore a BST) that uses Interval objects as nodes. IntervalTree is constrained to Numeric types,
/// as operations such as length make little sense outside of numerical values.
open class IntervalTree<T: IntervalTreeValueP>: AVLTree<Interval<T>> {

    public init(node: IntervalTreeNode<T>) {
        super.init(node: node)
        assert(nodeCount == 1)
        assert(root!.isRoot)
    }

    override public init(value: Interval<T>) {
        super.init(value: value)
        assert(nodeCount == 1)
        assert(root!.isRoot)
    }

    public convenience init(array: [Interval<T>]) {
        precondition(array.count > 0)
        self.init(node: IntervalTreeNode(value: array.first!))
        for v in array.dropFirst() {
            _ = try? insert(node: IntervalTreeNode(value: v))
        }
        if !balance() {
            updateHeightUpwards(node: minimum() as? IntervalTreeNode<T>)
            updateHeightUpwards(node: maximum() as? IntervalTreeNode<T>)
        }
    }

    /// Custom collection accessor for [] notation
    public subscript(key: Interval<T>) -> IntervalTreeNode<T>? {
        get { return search(value: key) }
        // subscript doesn't support throws as of now, so swallow the error
        set(newValue) {
            // if replacing a node (value)
            if let replace = newValue {
                remove(value: key)
                _ = try? insert(node: IntervalTreeNode<T>(value: replace.value))
            } else { // insert new node (value)
                _ = try? insert(node: IntervalTreeNode(value: key))
            }
            if !balance() {
                updateHeightUpwards(node: newValue)
            }
        }
    }

    /// Finds the node whose value preceedes our value in sorted order.
    public override func predecessor(value: Interval<T>) -> Interval<T>? {
        guard let node = search(value: value) else { return nil }
        var result = [Interval<T>]()
        traverseInOrder(completion: { if $0.start < node.value.start { result.append($0) }})
        return result.popLast()
    }

    /// Finds the node whose value succeeds our value in sorted order.
    public override func successor(value: Interval<T>) -> Interval<T>? {
        guard let node: IntervalTreeNode<T> = search(value: value) else { return nil }
        var result = [Interval<T>]()
        traverseInOrder(completion: { if $0.start > node.value.start { result.append($0) }})
        return result.first
    }

    /// Returns set of intervals that overlap with the given reference interval
    public func overlaps(interval: Interval<T>) -> [Interval<T>] {
        var result: [Interval<T>] = []
        overlaps(node: root as? IntervalTreeNode<T>, interval: interval, result: &result)
        return result
    }
    
    private func overlaps(node: IntervalTreeNode<T>?, interval: Interval<T>, result: inout [Interval<T>]) {
        guard let node = node else {
            return
        }
        let test = IntervalTreeNode(value: interval)
        
        if test.isOverlapping(node: node) {
            result.append(node.value)
        }
        
        if let left = node.left as? IntervalTreeNode<T>{
            if test.isOverlapping(node: left) {
                overlaps(node: left, interval: interval, result: &result)
            }
        }
        if let right = node.right as? IntervalTreeNode<T> {
            if test.isOverlapping(node: right) {
                overlaps(node: right, interval: interval, result: &result)
            }
        }
    }
    
    /// Returns set of intervals that the given interval is within
    public func within(interval: Interval<T>) -> [Interval<T>] {
        var result: [Interval<T>] = []
        within(node: root as? IntervalTreeNode<T>, interval: interval, result: &result)
        return result
    }
    
    private func within(node: IntervalTreeNode<T>?, interval: Interval<T>, result: inout [Interval<T>]) {
        guard let node = node else {
            return
        }
        let test = IntervalTreeNode(value: interval)
        
        // tests that the given interval is inside current IntervalNode
        if test.isWithin(node: node) {
            result.append(node.value)
        }
        
        if let left = node.left as? IntervalTreeNode<T> {
            if test.isWithin(node: left) {
                within(node: left, interval: interval, result: &result)
            }
        }
        if let right = node.right as? IntervalTreeNode<T> {
            if test.isWithin(node: right) {
                within(node: right, interval: interval, result: &result)
            }
        }
    }

    // MARK: - Adding items
    /// Inserts a new element into the tree. Duplicate values are ignored, but this incurs a lookup penalty of O(h).
    /// Performance: runs in O(h) time, where h is the height of the tree, plus O(log(n)) time for balancing.
    @discardableResult open func insert(node: IntervalTreeNode<T>) throws -> IntervalTreeNode<T> {
        // in case root is not set
        guard var root = self.root as? IntervalTreeNode<T> else {
            throw TreeError.invalidTree
        }

        // TODO: reimplement contains as a hash for constant time lookup
        // used to prevent duplicate values being inserted into tree
        if self.contains(value: node.value) {
            return node
        }
        // balance iff unbalanced
        if !balance() {
            updateHeightUpwards(node: node)
        }
        // balance might change root
        root = self.root as! IntervalTreeNode<T>
        return insert(tree: root, node: node, parent: nil)
    }

    @discardableResult private func insert(tree: IntervalTreeNode<T>,
                                           node: IntervalTreeNode<T>,
                                           parent: IntervalTreeNode<T>?) -> IntervalTreeNode<T> {
        let parent = parent ?? root as? IntervalTreeNode<T>

        // insertion is based on Comparable imple. See TreeProtocol.
        if node.value < tree.value {
            if let left = tree.left as? IntervalTreeNode<T> {
                insert(tree: left,
                       node: node,
                       parent: left)
            } else {
                let temp = IntervalTreeNode(value: node.value)
                tree.left = temp
                temp.parent = parent
                nodeCount += 1
            }
        } else {
            if let right = tree.right as? IntervalTreeNode<T> {
                insert(tree: right,
                       node: node,
                       parent: right)
            } else {
                let temp = IntervalTreeNode(value: node.value)
                tree.right = temp
                temp.parent = parent
                nodeCount += 1
            }
        }
        // update maxEnd
        node.maxEnd = max(node.maxEnd, tree.value.end)
        return tree
    }

    public override func contains(value: Interval<T>) -> Bool {
        return search(value: value) != nil
    }

    // MARK: - Searching
    /// Finds the "highest" (in tree) node with the specified value.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    open override func search(value: Interval<T>) -> IntervalTreeNode<T>? {
        guard let root = self.root as? IntervalTreeNode<T> else {
            return nil
        }
        var node: IntervalTreeNode<T>? = root
        if root.value == value {
            return root
        }
        while let n = node {
            if value == n.value {
                return n
            }
            // using Comparable impl for Interval
            if value < n.value {
                node = n.left as? IntervalTreeNode<T>
            } else if value >= n.value {
                node = n.right as? IntervalTreeNode<T>
            } else {
                return n
            }
        }
        // if here - value not found in tree
        return node
    }
    
    /// This is an alternative to using map on the IntervalTree, which uses the BinarySearchTree implementation of map - requiring
    /// the syntax:
    /// code<tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2)}>
    /// versus doing the same with flatMap:
    /// code<tree.flatMap({ $0 + $0 })>
    public func flatMap(_ formula: (T) -> T) -> [Interval<T>] {
        var result = [Interval<T>]()
        guard let root = self.root as? IntervalTreeNode<T> else {
            return result
        }
        flatMap(node: root, apply: formula, result: &result)
        return result
    }
    
    private func flatMap(node: IntervalTreeNode<T>, apply: ((T) -> T), result: inout [Interval<T>]) {
        if let left = node.left as? IntervalTreeNode<T> { flatMap(node: left, apply: apply, result: &result) }
        
        let newInterval: Interval<T> = try! Interval(start: apply(node.value.start), end: apply(node.value.end))
        node.value = newInterval // update tree
        result.append(newInterval) // append to results (inorder)
        
        if let right = node.right as? IntervalTreeNode<T> { flatMap(node: right, apply: apply, result: &result) }
    }
}

// MARK: Extension: Interval
extension Interval: CustomStringConvertible {
    public var description: String {
        return "{\(start), \(end)}"
    }
}
