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
// TODO: provide search for value (within range) of an interval and return IntervalNode

// MARK: - IntervalNode
open class IntervalTreeNode<T: IntervalTreeValueP>: AVLTreeNode<Interval<T>> where T: Comparable {
    open var maxEnd: T

    required public init(node: BinarySearchTreeNode<Interval<T>>) {
        let v = node.value
        self.maxEnd = v.end
        super.init(node: node)
        self.value = v
    }

    public required convenience init(start: T, end: T) {
        let i: Interval<T> = try! Interval(start: start, end: end)
        self.init(value: i)
    }

    // T is Interval<T>
    public required init(value: Interval<T>) {
        self.maxEnd = value.end
        super.init(value: value)
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
    open override var length: Float {
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


// TODO: put AVLTree func in extension for use here
open class IntervalTree<T: IntervalTreeValueP>: AVLTree<Interval<T>> {

    public required init(node: BinarySearchTreeNode<Interval<T>>) {
        super.init(node: node)
        self.root = node
        nodeCount = 1
    }

    public required init(value: Interval<T>) {
        super.init(value: value)
        let node = IntervalTreeNode<T>(value: value)
        root = node
        nodeCount = 1
    }

    public required convenience init(array: [Interval<T>]) {
        precondition(array.count > 0)
        self.init(node: IntervalTreeNode(value: array.first!))
        for v in array.dropFirst() {
            _ = try? insert(node: IntervalTreeNode(value: v))
        }
    }

    public required convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(node: IntervalTreeNode(value: array.first! as! Interval<T>))
        for v in array.dropFirst() {
            _ = try? insert(node: IntervalTreeNode(value: v as! Interval<T>))
        }
    }

    /// return an array of node values from an in-order traversal
    public override func toArray() -> [Interval<T>] {
        var inOrder = [Interval<T>]()
        traverseInOrder { inOrder.append($0) }
        return inOrder
    }

    public override func height() -> Int {
        guard let root = self.root else {
            return 0
        }
        return height(node: root)
    }

    public func height(node: IntervalTreeNode<T>?) -> Int {
        guard let node = node, let _ = self.root else {
            return 0
        }
        let lHeight = height(node: node.left as? IntervalTreeNode<T>)
        let rHeight = height(node: node.right as? IntervalTreeNode<T>)
        return max(lHeight, rHeight) + 1
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
    /// Inserts a new element into the tree. You should randomly insert elements at the root, to make to sure this remains a valid
    /// binary tree! Duplicate values are ignored, but this incurs a lookup penalty.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult public func insert(node: IntervalTreeNode<T>) throws -> IntervalTreeNode<T> {
        // in case root is not set
        guard let root = self.root as? IntervalTreeNode<T> else {
            throw TreeError.invalidTree
        }
        let parent = node.parent ?? root // parent of replacement node
        balance(node: parent as? IntervalTreeNode<T>)

        return insert(tree: root, node: node, parent: nil)
    }

    @discardableResult private func insert(tree: IntervalTreeNode<T>,
                                           node: IntervalTreeNode<T>,
                                           parent: IntervalTreeNode<T>?) -> IntervalTreeNode<T> {
        let parent = parent ?? root as? IntervalTreeNode<T>

        // insertion is based on start value of interval
        if node.value.start < tree.value.start {
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

    // MARK: - Deleting items
    /// Deletes a node from the tree.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult public override func remove(value: Interval<T>) -> IntervalTreeNode<T>? {
        guard let replace = search(value: value) else {
            return nil
        }
        if nodeCount == 1 {
            root = nil
            nodeCount = 0
        } else {
            do {
                try deleteNode(node: replace)
                nodeCount -= 1
            } catch {
                // not a fatal error - node might not exist
                print("!!! unable to remove node \(replace.value)")
                return nil
            }
        }
        return replace
    }

    public func deleteNode(node: IntervalTreeNode<T>) throws {
        if node.isLeaf {
            // Just remove and balance up
            if let parent = node.parent {
                guard node.isLeftChild || node.isRightChild else {
                    throw TreeError.invalidTree
                }

                if node.isLeftChild {
                    parent.left = nil
                } else if node.isRightChild {
                    parent.right = nil
                }
            } else {
                // at root
                root = nil
            }
        } else {
            // Handle stem cases
            if let left = node.left {
                // replace with max valued node from left tree
                if let replacement = maximum(node: left) {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement
                    try? deleteNode(node: replacement)
                }
                // replace with min valued node from right tree
            } else if let right = node.right as? IntervalTreeNode<T> {
                if let replacement = minimum(node: right), replacement !== node {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement
                    try? deleteNode(node: replacement)
                }
            }
        }
    }

    open override func draw() {
        guard let root = self.root else {
            print("* tree is empty *")
            return
        }
        print("\n") // newline
        print("<<< tree root is \(root.value), size=\(size), height=\(height(node: root)): leaf nodes are marked with ? >>>")
        draw(root as? IntervalTreeNode<T>)
        print("\n") // newline
    }

    public override func contains(value: Interval<T>) -> Bool {
        return search(value: value) != nil
    }

    /// Since insertion is based on start value of the interval, so too will search look at start value
    open func search(value: Interval<T>) -> IntervalTreeNode<T>? {
        guard let root = self.root as? IntervalTreeNode<T> else {
            return nil
        }
        var node: IntervalTreeNode<T>? = root
        if root.value == value {
            return root
        }
        while let n = node {
            if value.start == n.value.start && value.end == n.value.end {
                return n
            }
            if value.start < n.value.start {
                node = n.left as? IntervalTreeNode<T>
            } else if value.start >= n.value.start {
                node = n.right as? IntervalTreeNode<T>
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


extension IntervalTree {
    private func draw(_ node: IntervalTreeNode<T>?) {
        if let left = node?.left as? IntervalTreeNode<T> {
            print("(", terminator: ""); draw(left); print(" <- ", terminator:"");
        }

        if let node = node {
            // differ in placement of parenthetical groupings
            if node.hasBothChildren { print("\(node.value):\(node.maxEnd)", terminator:"")  }
            else if node.hasLeftChild { print("\(node.value):\(node.maxEnd)", terminator:")") }
            else if node.hasRightChild { print("(\(node.value):\(node.maxEnd)", terminator:"") }
            else { print("\(node.value):\(node.maxEnd)", terminator:"?") } // leaf
        }

        if let right = node?.right as? IntervalTreeNode<T> {
            print(" -> ", terminator:""); draw(right); print("", terminator: ")")
        }
    }
}

// MARK: - Displaying tree
extension IntervalTree {
    public func display(node: IntervalTreeNode<T>) {
        print("\nDisplaying [node]: level in tree")
        print("---------------------------------------")
        display(node: node, level: 0)
        print("\n")
    }

    fileprivate func display(node: IntervalTreeNode<T>?, level: Int) {
        if let node = node {
            display(node: node.right as? IntervalTreeNode<T>, level: level + 1)
            print("")
            if node.isRoot {
                print("Root -> ", terminator: "")
            }
            for _ in 0..<level {
                print("        ", terminator:  "")
            }
            print("\(node.value):\(height(node: node))", terminator: "")
            display(node: node.left as? IntervalTreeNode<T>, level: level + 1)
        }
    }
}

