//
//  ImmutableSearchTree.swift
//
// A Binary Search Tree that is built using value types. It is immutable in the sense that any insertion, deletion,
// or rebalancing returns a new tree.
//
// Created by Christopher Charles Cavnor on 4/28/22.
//
import ValueBasedStack

/*
 A binary search tree.
 Each node stores a value and two children. The left child contains a smaller
 value; the right a larger (or equal) value.
 This tree allows duplicate elements.
 This tree does not automatically balance itself. To make sure it is balanced,
 you should insert new values in randomized order, not in sorted order.
 */
/// An immutable Binary Search Tree (BST) using Enum value type. Each insertion or deletion will create a new BST.
//public enum ValueBasedBinarySearchTree<T: Comparable>: Equatable, BinarySearchTreeProtocol {
public enum BinarySearchTree<T: Comparable>: Equatable {
    case empty
    case leaf(T)
    // use indirect keyword to tell compiler to allocate memory dynamically.
    indirect case node(BinarySearchTree, T, BinarySearchTree)

    public init() {
        self = .empty
    }

    // Build tree from the given array. Randomizes your input first, and extracts out a median
    // candidate to use as the root of the tree.
    // Performance: call to median costs O(n), plus insertion call for each element (O(n))
    public init(from array: [T]) {
        var elements = array
        self = .empty
        // get the median value to use as root, then remove from array so that it is not inserted twice
        let median = median(array)
        let mIndx = elements.firstIndex(of: median)!
        elements.remove(at: mIndx)
        self = self.insert(median)
        for x in elements {
            self = self.insert(x)
        }
    }

    // get the median value of an array.
    // Performance: O(n) because of sort
    public func median(_ arr: [T]) -> T {
        precondition(!arr.isEmpty)
        let arr = arr.sorted()
        let cnt = arr.count
        if cnt == 1 { return arr.first! }
        if cnt % 2 == 0 {
            return arr[cnt/2 - 1]
        } else {
            let f = Float(cnt/2).rounded(.down)
            return arr[Int(f)]
        }
    }

    // Returns an array of the tree corresponding to in-order traversal.
    // Performance: O(n)
    public func toArray() -> [T] {
        var collect: [T] = [T]()
        self.traverseInOrder(process: { collect.append($0) } )
        return collect
    }

    // Get root value of tree.
    // Performance: O(1)
    public var root: T? {
        return self.value
    }

    // Get left branch of tree.
    // Performance: O(1)
    public var left: BinarySearchTree? {
        if case let .node(left,_,_) = self {
            if left == .empty { return nil }
            return left
        }
        return nil
    }

    // Get left branch of tree.
    // Performance: O(1)
    public var right: BinarySearchTree? {
        if case let .node(_,_,right) = self {
            if right == .empty { return nil }
            return right
        }
        return nil
    }

    // Performance: O(1)
    public var isLeaf: Bool {
        return left == nil && right == nil
    }

    // value is optional to allow for checking of empty node
    // Performance: O(1)
    public func isLeftChild(_ value: T?) -> Bool {
        return left?.value == value
    }

    // value is optional to allow for checking of empty node
    // Performance: O(1)
    public func isRightChild(_ value: T?) -> Bool {
        return right?.value == value
    }

    // Performance: O(1)
    public var hasLeftChild: Bool {
        return left != nil
    }

    // Performance: O(1)
    public var hasRightChild: Bool {
        return right != nil
    }

    // Performance: O(1)
    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }

    // Performance: O(1)
    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }

    // Get the value for current node.
    // Performance: O(1)
    public var value: T? {
        if case .leaf(let value) = self {
            return value
        }
        if case let .node(_,value,_) = self {
            return value
        }
        return nil
    }

    // Always matches the most top-level target (ignoring lower nodes with duplicate values). If
    // you need the parent of another node with the same value, use search to get the subtree
    // and pass in a node with distict values.
    // Performance: O(h), where h is height of tree
    public func parent(of target: T) -> BinarySearchTree? {
        var curr = self
        guard let root = root else { return nil }
        if target == root { return nil }
        if curr.isLeftChild(target) || curr.isRightChild(target) {
            return curr
        }
        if case let .node(left,node,right) = curr {
            if target < node {
                curr = left.parent(of: target) ?? .empty
            } else {
                curr = right.parent(of: target) ?? .empty
            }
        }
        return curr
    }

    /// Get a list of the target's parents from the root of the tree to the immediate parent.
    /// Always matches the most top-level target (ignoring lower nodes with duplicate values). If you need the parent of another node with the same value,
    /// use search to get the subtree  with  distict values and call parents on that.
    /// - Parameters:
    ///   - target: the value to backtrack from
    ///   - accumulator: (T) -> Void closure for storing parent values
    /// - Returns: a list of parent node values, from root to target in order, via accumulator
    /// - Performance:  O(h), where h is height of tree. Only one half of tree is ever traversed.
    public func parents(of target: T, using accumulator: (T) -> Void) {
        var target = target
        while let parent = parent(of: target) {
            if let value = parent.value {
                accumulator(value)
                target = value
            }
        }
    }

    // Performance: O(1)
    public func isRoot(_ element: T) -> Bool {
        return self.root == element
    }

    /* How many nodes are in this subtree. Performance: O(n). */
    // Performance: Since this looks at all children of tree, performance is O(n)
    public var count: Int {
        switch self {
        case .empty: return 0
        case .leaf: return 1
        case let .node(left, _, right): return left.count + 1 + right.count
        }
    }

    /*
     Calculates the height of the node as its distance to the lowest leaf.
     To get the height of subtree, search for the value and call this on the result.
     */
    // Performance: O(h), where h is height of tree.
    public var height: Int {
        switch self {
        case .empty: return 0
        case .leaf: return 0
        case let .node(left, _, right): return 1 + max(left.height, right.height)
        }
    }

    /*
     Calculates the depth of this node, i.e. the distance from the root.
     */
    // Performance: O(n), since parents must be calculated.
    public func depth(of target: T) -> Int {
        var accum = [T]()
        self.parents(of: target, using: { accum.append($0) } )
        return accum.count
    }

    // Insert a branch to the existing tree.
    // Performance: O(n), since we need to build a new tree with all elements.
    public func insert(_ node: BinarySearchTree) -> BinarySearchTree {
        let branch = node.toArray()
        var tree = self.toArray()
        tree.append(contentsOf: branch)
        return BinarySearchTree.init(from: tree)
    }

    /*
     Insert a new value into the tree.
     */
    // Performance: runs in O(n) time, since every element must be inserted.
    public func insert(_ newValue: T) -> BinarySearchTree {
        switch self {
        case .empty:
            return .leaf(newValue)
        case .leaf(let value):
            let leaf: BinarySearchTree = .leaf(newValue)
            if newValue < value {
                return .node(leaf, value, .empty)
            } else {
                return .node(.empty, value, leaf)
            }
        case .node(let left, let value, let right):
            if newValue < value {
                return .node(left.insert(newValue), value, right)
            } else {
                return .node(left, value, right.insert(newValue))
            }
        }
    }


    /*
     Finds the "highest" node with the specified value (ensures that duplicate values for searched value
     are returned too).
     */
    // Performance: runs in O(log n) time for average case, where n is the number of nodes. Runs in O(h) time,
    // where h is the height of the tree, for worst case (when tree is linear).
    public func search(value x: T) -> BinarySearchTree? {
        switch self {
        case .empty:
            return nil
        case .leaf(let y):
            return (x == y) ? self : nil
        case let .node(left, y, right):
            if x < y {
                return left.search(value: x)
            } else if y < x {
                return right.search(value: x)
            } else {
                return self
            }
        }
    }

    // Performance: runs in O(log n) time for average case
    public func contains(_ x: T) -> Bool {
        return search(value: x) != nil
    }

    /*
     Returns the leftmost descendent.
     */
    // Performance: runs in O(h) time, where h is height of tree.
    public var minimum: T? {
        var curr = self
        while case let .node(next, _, _) = curr {
            curr = next
        }
        if case .leaf = curr { return curr.value }
        return nil
    }

    /*
     Returns the rightmost descendent.
     */
    // Performance: runs in O(h) time, where h is height of tree.
    public var maximum: T? {
        var curr = self
        var prev = curr
        while case let .node(_, _, next) = curr {
            prev = curr
            curr = next
        }
        if case .leaf = curr { return curr.value }
        return prev.value
    }

    // In-order traversal of tree: visit left branch, then root, then right branch
    // Performance: runs in O(n) time.
    public func traverseInOrder(process: (T) -> Void) {
        switch self {
        case .empty: return
        case .leaf(let value): process(value)
        case .node(let left, let node, let right):
            left.traverseInOrder(process: process)
            process(node)
            right.traverseInOrder(process: process)
        }
    }

    // Pre-order traversal of tree: visit root, then left branch, then right branch.
    // Performance: runs in O(n) time.
    public func traversePreOrder(process: (T) -> Void) {
        switch self {
        case .empty: return
        case .leaf(let value): process(value)
        case .node(let left, let node, let right):
            process(node)
            left.traverseInOrder(process: process)
            right.traverseInOrder(process: process)
        }
    }

    // Post-order traversal of tree: visit left branch, then right branch, then root node.
    // Performance: runs in O(n) time.
    public func traversePostOrder(process: (T) -> Void) {
        switch self {
        case .empty: return
        case .leaf(let value): process(value)
        case .node(let left, let node, let right):
            left.traverseInOrder(process: process)
            right.traverseInOrder(process: process)
            process(node)
        }
    }

    // Remove by node type. Calls through to remove by value routine, since we are not dealing with
    // reference types this is just a convenience wrapper.
    public func remove(_ node: BinarySearchTree) -> BinarySearchTree {
        if let value = node.value {
            return remove(value)
        }
        return self
    }

    // Remove by value of node
    // Removal follows the following algorithm to ensure that the tree remains sorted:
    // 1) if the element to remove is a leaf, just delete it
    // 2) else replace the node with either its biggest child on the left or its smallest child on the right
    // Performance: O(n) to build traversal, then O(n)
    // Even using the standard algorithm for pruning and replacement, it would take an O(n) traversal to get parents.
    // This is on the order of twice as slow, but still O(n)
    public func remove(_ target: T) -> BinarySearchTree {
        if self.count == 1 {
            return BinarySearchTree.empty
        }
        if let _ = search(value: target) {
            // this works great - but costly because of both traversal to build array (O(n)) and rebuilding of tree O(n)
            var arr = self.toArray()
            let remIdx = arr.firstIndex(of: target)!
            arr.remove(at: remIdx)
            return BinarySearchTree.init(from: arr)
        }
        return self
    }

    // TODO: implement
    // randomize tree elements and rebuild in an effort to rebalance the tree. This is not guaranteed to give you
    // an optimally balanced tree, but will prune linear chains.
    public func shake() -> BinarySearchTree {
        return BinarySearchTree.init(from: self.toArray())
    }

    // Tree is balanced when left and right trees are at most one level different.
    // Performance: runs in O(h) time, where h is height of tree.
    public func isBalanced() -> Bool {
        let leftH = self.left?.height ?? 0
        let rightH = self.right?.height ?? 0
        if abs(leftH - rightH) <= 1 {
            return true
        }
        return false
    }

}

extension BinarySearchTree: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .empty: return "."
        case .leaf(let value): return "\(value)"
        case .node(let left, let value, let right):
            return "(\(left.debugDescription)  <- \(value) -> \(right.debugDescription))"
        }
    }
}
