//
//  Heap.swift
//
//
//  Created by Christopher Charles Cavnor on 3/17/24.
//

import IteratableListProtocol

/// A Heap Node
open class HeapNode<T: Comparable> {
    private var _left: HeapNode<T>?
    private var _right: HeapNode<T>?
    private var _parent: HeapNode<T>?

    open var left: HeapNode<T>? {
        get { return _left }
        set { _left = newValue }
    }
    open var right: HeapNode<T>? {
        get { return _right }
        set { _right = newValue }
    }
    open var parent: HeapNode<T>? {
        get { return _parent }
        set { _parent = newValue }
    }

    private var _value: T

    open var value: T {
        get { return _value }
        set { _value = newValue }
    }

    required public init(value: T) {
        _value = value
    }

    /// Returns true iff node is the top node
    public var isRoot: Bool {
        return self.parent == nil
    }

    /// Returns true iff node is a leaf node
    public var isLeaf: Bool {
        return left == nil && right == nil
    }

    /// Returns true iff node is left of its parent
    public var isLeftChild: Bool {
        return parent?.left === self
    }

    /// Returns true iff node is right of its parent
    public var isRightChild: Bool {
        return parent?.right === self
    }

    /// Returns true iff node has a left child
    public var hasLeftChild: Bool {
        return left != nil
    }

    /// Returns true iff node has a right child
    public var hasRightChild: Bool {
        return right != nil
    }

    /// Returns true if node has any children
    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }

    /// Returns true if node has both children
    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }

    // For Comparable conformance
    public static func == (lhs: HeapNode<T>, rhs: HeapNode<T>) -> Bool {
        return lhs.value == rhs.value
    }

    // For Comparable conformance
    public static func < (lhs: HeapNode<T>, rhs: HeapNode<T>) -> Bool {
        return lhs.value < rhs.value
    }
}

// MARK: LinkedListNode - Extension to enable the standard conversion of a list to String
extension HeapNode: CustomStringConvertible {
    public var description: String {
        var s = ""
        let prev = left?.value
        let next = right?.value

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

/// A binary heap is a heap data structure that takes the form of a binary tree.
/// A binary heap has two constraints:
/// - completeness: it is a complete binary tree, with slots filled at the leaf nodes from left to right.
/// - the shape constraint: the value stored in each node is either greater than or equal to (for a max heap)
/// or less than or equal to (for a min heap) the values in the node's children. This is true
/// per level, but sibling nodes have no such sequence with regard to each other.
///
/// There are two kinds of heaps: min-heaps and max-heaps.
/// - Complexity: A  binary  tree  maintains O(log n) insertion and deletion times for a
/// heap of size n.
public class Heap<T: Comparable>: IteratableP, IteratorProtocol {
    typealias Node = HeapNode<T>

    /// The root (top) of the Heap
    private var root: Node?

    /// The number of elements in the Heap
    public var size: Int = 0

    /// Check if the Heap contains any elements
    public var isEmpty: Bool {
        size == 0
    }

    /// Navigates to the lowest, right-most node using the heap shape constraint:
    /// all levels must be filled (the heap is a complete tree) and the leafs
    /// are left filled. The binary representation of the size of the heap provides
    /// a map to the last node as follows: the leftmost digit is the root, then a
    /// 0 represents a left child and a 1 represents the right child.
    /// - Complexity: O(log n)
    var nextAvailableNode: Node? {
        guard let r = root else {
            return root
        }
        var bin = String(size, radix: 2)
        bin.removeFirst() // root
        var n = r
        for b in bin {
            if b == "0" { n = n.left! }
            else { n = n.right! }
        }
        return n
    }

    /// The order constraint for a Heap that determines how to compare two 
    /// nodes in the heap. Use '>' for a max-heap or '<' for a min-heap.
    private var orderCriteria: (T, T) -> Bool

    /// Creates an empty heap.
    /// The sort function determines whether this is a min-heap or max-heap.
    public init(sort: @escaping (T, T) -> Bool) {
        self.orderCriteria = sort
    }

    /// Called after a new node is added to the Heap. The node is added to the end
    /// of the Heap, and its value is traded with that of its parents recursively until
    /// the Heap shape constraint is met.
    private func bubbleUp() {
        guard let last = nextAvailableNode else {
            return
        }
        if size == 1 {
            root = last
            return
        }
        var node = last
        while node.parent != nil {
            if orderCriteria(node.value, node.parent!.value) {
                // swap by value
                let temp = node.parent!.value
                node.parent!.value = node.value
                node.value = temp
            }
            node = node.parent!
        }
    }

    /// Get the nearest ancestor (parent, grandparent, etc) that is a left child of its parent.
    /// - Parameters:
    ///     - from: the node to begin with
    /// - Returns:
    ///     - the target node
    private func getLeftChildAncestor(from node: Node) -> Node {
        var next = node
        var lca = root! // default leftmost

        while let p = next.parent {
            if p.isLeftChild {
                lca = p
                break
            }
            // ok, since we can't hit root
            next = next.parent!
        }
        return lca
    }

    /// Get the descendent node that has the first free left child slot.
    /// - Parameters:
    ///     - from: the node to begin with
    /// - Returns:
    ///     - the target node
    private func getDescendentLeftFreeSlot(from node: Node) -> Node {
        var node = node
        while node.hasLeftChild {
            node = node.left!
        }
        return node
    }

    /// Insert a new value into the Heap.
    /// The value is added as a HeapNode at the end of the Heap, then a bubble-up occurs.
    /// - Parameters:
    ///     - element: The value to insert.
    /// - Complexity: O(log n)
    public func push(_ element: T) {
        let nodeToInsert = Node(value: element)

        if nextAvailableNode == nil {
            root = nodeToInsert
        } else {
            if let last = nextAvailableNode {
                if last.isRoot {
                    root!.left = nodeToInsert
                    nodeToInsert.parent = root
                } else if last.isLeftChild {
                    last.parent!.right = nodeToInsert
                    nodeToInsert.parent = last.parent
                } else { // last_inserted_node is a right child
                    let tmlc = getLeftChildAncestor(from: last)
                    // get root node iff tmlc has no parent
                    let z = tmlc.parent?.right ?? root!
                    // the leftmost free slot
                    let free = getDescendentLeftFreeSlot(from: z)
                    free.left = nodeToInsert
                    nodeToInsert.parent = free
                }
            }
        }
        size += 1
        bubbleUp()
    }

    /// Calls bubbleDown() with the root node (top element).
    private func bubbleDown() {
        guard let top = root else {
            return
        }
        if !top.hasAnyChild {
            return
        }
        bubbleDown(from: top)
    }

    /// Takes the given node and pushes it down using the orderCriteria constraint.
    /// bubbleDown is called after a node extraction and  is finished when the shape
    /// constraint is re-established.
    /// - Parameters:
    ///     - node: the node to begin with
    /// - Complexity: O(log n)
    private func bubbleDown(from node: Node) {
        guard node.hasAnyChild else {
            return
        }

        // Get the smaller of children in a min-heap, larger of children in max-heap
        var target: Node
        if node.hasBothChildren {
            if orderCriteria(node.left!.value, node.right!.value) {
                target = node.left!
            } else {
                target = node.right!
            }
        } else { // safe, since nodes are left-first inserted
            target = node.left!
        }

        // only bubble down if orderCriteria violated between target and parent
        if !orderCriteria(node.value, target.value) {
            let tempv = node.value
            node.value = target.value
            target.value = tempv
            // bubble recursively
            bubbleDown(from: target)
        }
    }

    /// Remove the top of the heap and return its value. The top is replaced with
    /// the last inserted element, then we call bubbleDown to heapify.
    /// - Returns:
    ///     - the value at the top of the heap
    /// - Complexity: O(log n)
    public func pop() -> T? {
        guard let top = root else {
            return nil
        }

        let topv = top.value
        let next = nextAvailableNode

        if size == 1 { // root is last_inserted_node
            root = nil
        } else {
            // replace root value with last_inserted_node value and shiftDown to heapify
            top.value = next!.value

            // this will allow last to be collected
            if next!.isLeftChild {
                next!.parent?.left = nil
            } else {
                next!.parent?.right = nil
            }
            next!.parent = nil
        }
        size -= 1
        bubbleDown()
        return topv
    }

    /// Non-destructively returns the value at the top of the Heap.
    /// - Returns:
    ///     - the value at the top of the heap
    public func peek() -> T? {
        guard let top = root else {
            return nil
        }
        return top.value
    }

    /// Removes the elements of the Heap.
    public func removeAll() {
        root = nil
        size = 0
    }

    /// For conformance to Sequence protocol.
    /// Synonym for pop().
    public func next() -> T? {
        return pop()
    }

    /// Insert at the root and then extract (after heapify if required) in same operation.
    /// This is more effecient than a consecutive push, then pop, which would both
    /// require an O(n) operation (a bubble-up then a bubble-down).
    /// - Parameters:
    ///     - element: the value to push
    /// - Returns:
    ///     - the value of the root element after insertion (and potentially heapifying)
    /// - Complexity: O(log n) if heapify is required, else O(1)
    public func pushPop(_ element: T) -> T? {
        guard let top = self.root else {
            root = Node(value: element)
            size = 1
            return element
        }

        top.value = element
        // if the new element replaces root but violates shape
        // constriaint it must be bubbled down to heapify
        if !orderCriteria(element, top.value) {
            bubbleDown()
        }
        return top.value
    }

    /// Extract then insert in same operation (aka replace root element).
    /// Heap will heapify, if required, but the prior top element is returned.
    /// This is more effecient than a consecutive pop, then push, which would both
    /// require an O(n) operation (a bubble-down then a bubble-up).
    /// - Parameters:
    ///     - element: the value to push
    /// - Returns:
    ///     - the value of the root element before insertion
    /// - Complexity: O(log n) if heapify is required, else O(1)
    public func popPush(_ element: T) -> T? {
        guard let top = self.root else {
            root = Node(value: element)
            size = 1
            return nil
        }

        let prior = top.value
        top.value = element
        // if the new element replaces root but violates shape
        // constriaint it must be bubbled down to heapify
        if !orderCriteria(element, top.value) {
            bubbleDown()
        }
        return prior
    }
}

// MARK: - MinHeap and MaxHeap
/// Convenience initializers for a Min Heap
public final class MinHeap<T: Comparable>: Heap<T> {
    public required convenience init() {
        self.init(sort: <)
    }
}

/// Convenience initializers for a Max Heap
public final class MaxHeap<T: Comparable>: Heap<T> {
    public required convenience init() {
        self.init(sort: >)
    }
}

// MARK: - Extension to enable initialization from an Array
extension Heap {
    /// Convenience initializers for loading a Heap from an array.
    public convenience init(array: Array<T>, sort: @escaping (T, T) -> Bool) {
        self.init(sort: sort)
        array.forEach { push($0) }
    }
}

extension MinHeap {
    /// Convenience initializers for loading a Min Heap from an array.
    public convenience init(array: Array<T>) {
        self.init()
        array.forEach { push($0) }
    }
}

extension MaxHeap {
    /// Convenience initializers for loading a Max Heap from an array.
    public convenience init(array: Array<T>) {
        self.init()
        array.forEach { push($0) }
    }
}

// MARK: - Extension to enable initialization from an Array Literal
extension MinHeap: ExpressibleByArrayLiteral {
    /// Convenience initializers for loading a Min Heap from an array literal.
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        elements.forEach { push($0) }
    }
}

extension MaxHeap: ExpressibleByArrayLiteral {
    /// Convenience initializers for loading a Max Heap from an array literal.
    public convenience init(arrayLiteral elements: T...) {
        self.init()
        elements.forEach { push($0) }
    }
}


// MARK: - Graphically represent the heap
import Foundation
extension Heap: CustomStringConvertible {
    public var description: String {
        guard let top = root else {
            return "\n* heap is empty *\n"
        }
        let treeType = type(of: self)
        let report =
        """
        <<< [\(treeType)] root is \(top.value), size=\(size), last=\(nextAvailableNode!.value) >>>
        """
        return "\n\(report)\n" + treeString(top){("\($0.value)",$0.left,$0.right)} + "\n"
    }

    // Adapted from: https://stackoverflow.com/a/43903427
    private func treeString(_ node:Node, reversed:Bool=false, isTop:Bool=true, using nodeInfo:(Node)->(String,Node?,Node?)) -> String {
        // node value string and sub nodes
        let (stringValue, leftNode, rightNode) = nodeInfo(node)

        let stringValueWidth  = stringValue.count

        // recurse to sub nodes to obtain line blocks on left and right
        let leftTextBlock     = leftNode  == nil ? []
        : treeString(leftNode!,reversed:reversed,isTop:false,using:nodeInfo)
            .components(separatedBy:"\n") // requires import Foundation

        let rightTextBlock    = rightNode == nil ? []
        : treeString(rightNode!,reversed:reversed,isTop:false,using:nodeInfo)
            .components(separatedBy:"\n")

        // count common and maximum number of sub node lines
        let commonLines       = Swift.min(leftTextBlock.count,rightTextBlock.count)
        let subLevelLines     = Swift.max(rightTextBlock.count,leftTextBlock.count)

        // extend lines on shallower side to get same number of lines on both sides
        let leftSubLines      = leftTextBlock
        + Array(repeating:"", count: subLevelLines-leftTextBlock.count)
        let rightSubLines     = rightTextBlock
        + Array(repeating:"", count: subLevelLines-rightTextBlock.count)

        // compute location of value or link bar for all left and right sub nodes
        //   * left node's value ends at line's width
        //   * right node's value starts after initial spaces
        let leftLineWidths    = leftSubLines.map{$0.count}
        let rightLineIndents  = rightSubLines.map{$0.prefix{$0==" "}.count  }

        // top line value locations, will be used to determine position of current node & link bars
        let firstLeftWidth    = leftLineWidths.first   ?? 0
        let firstRightIndent  = rightLineIndents.first ?? 0


        // width of sub node link under node value (i.e. with slashes if any)
        // aims to center link bars under the value if value is wide enough
        //
        // ValueLine:    v     vv    vvvvvv   vvvvv
        // LinkLine:    / \   /  \    /  \     / \
        //
        let linkSpacing       = Swift.min(stringValueWidth, 2 - stringValueWidth % 2)
        let leftLinkBar       = leftNode  == nil ? 0 : 1
        let rightLinkBar      = rightNode == nil ? 0 : 1
        let minLinkWidth      = leftLinkBar + linkSpacing + rightLinkBar
        let valueOffset       = (stringValueWidth - linkSpacing) / 2

        // find optimal position for right side top node
        //   * must allow room for link bars above and between left and right top nodes
        //   * must not overlap lower level nodes on any given line (allow gap of minSpacing)
        //   * can be offset to the left if lower subNodes of right node
        //     have no overlap with subNodes of left node
        let minSpacing        = 2
        let rightNodePosition = zip(leftLineWidths,rightLineIndents[0..<commonLines])
            .reduce(firstLeftWidth + minLinkWidth)
        { Swift.max($0, $1.0 + minSpacing + firstRightIndent - $1.1) }


        // extend basic link bars (slashes) with underlines to reach left and right
        // top nodes.
        //
        //        vvvvv
        //       __/ \__
        //      L       R
        //
        let linkExtraWidth    = Swift.max(0, rightNodePosition - firstLeftWidth - minLinkWidth )
        let rightLinkExtra    = linkExtraWidth / 2
        let leftLinkExtra     = linkExtraWidth - rightLinkExtra

        // build value line taking into account left indent and link bar extension (on left side)
        let valueIndent       = Swift.max(0, firstLeftWidth + leftLinkExtra + leftLinkBar - valueOffset)
        let valueLine         = String(repeating:" ", count: Swift.max(0,valueIndent)) + stringValue
        let slash             = reversed ? "\\" : "/"
        let backSlash         = reversed ? "/"  : "\\"
        let uLine             = reversed ? "¯"  : "_"
        // build left side of link line
        let leftLink          = leftNode == nil ? ""
        : String(repeating: " ", count:firstLeftWidth)
        + String(repeating: uLine, count:leftLinkExtra)
        + slash

        // build right side of link line (includes blank spaces under top node value)
        let rightLinkOffset   = linkSpacing + valueOffset * (1 - leftLinkBar)
        let rightLink         = rightNode == nil ? ""
        : String(repeating:  " ", count:rightLinkOffset)
        + backSlash
        + String(repeating:  uLine, count:rightLinkExtra)

        // full link line (will be empty if there are no sub nodes)
        let linkLine          = leftLink + rightLink

        // will need to offset left side lines if right side sub nodes extend beyond left margin
        // can happen if left subtree is shorter (in height) than right side subtree
        let leftIndentWidth   = Swift.max(0,firstRightIndent - rightNodePosition)
        let leftIndent        = String(repeating:" ", count:leftIndentWidth)
        let indentedLeftLines = leftSubLines.map{ $0.isEmpty ? $0 : (leftIndent + $0) }

        // compute distance between left and right sublines based on their value position
        // can be negative if leading spaces need to be removed from right side
        let mergeOffsets      = indentedLeftLines
            .map{$0.count}
            .map{leftIndentWidth + rightNodePosition - firstRightIndent - $0 }
            .enumerated()
            .map{ rightSubLines[$0].isEmpty ? 0  : $1 }

        // combine left and right lines using computed offsets
        //   * indented left sub lines
        //   * spaces between left and right lines
        //   * right sub line with extra leading blanks removed.
        let mergedSubLines    = zip(mergeOffsets.enumerated(),indentedLeftLines)
            .map{ ( $0.0, $0.1, $1 + String(repeating:" ", count: Swift.max(0,$0.1)) ) }
            .map{ $2 + String(rightSubLines[$0].dropFirst(Swift.max(0,-$1))) }

        // Assemble final result combining
        //  * node value string
        //  * link line (if any)
        //  * merged lines from left and right sub trees (if any)
        let treeLines = [leftIndent + valueLine]
        + (linkLine.isEmpty ? [] : [leftIndent + linkLine])
        + mergedSubLines

        return (reversed && isTop ? treeLines.reversed(): treeLines)
            .joined(separator:"\n")
    }
}
