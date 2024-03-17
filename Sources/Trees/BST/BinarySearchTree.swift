import TreeProtocol

/// A Binary Search Tree Node
open class BinarySearchTreeNode<T: TreeValueP>: TreeNodeP where T: Comparable {
    public typealias NodeType = BinarySearchTreeNode<T>
    public typealias NodeValue = T

    private var _left: BinarySearchTreeNode<T>?
    private var _right: BinarySearchTreeNode<T>?
    private var _parent: BinarySearchTreeNode<T>?

    open var left: BinarySearchTreeNode<T>? {
        get { return _left }
        set { _left = newValue }
    }
    open var right: BinarySearchTreeNode<T>? {
        get { return _right }
        set { _right = newValue }
    }
    open var parent: BinarySearchTreeNode<T>? {
        get { return _parent }
        set { _parent = newValue }
    }

    private var _value: T
    private var _is_root = false // toggled by tree for root node
    private var _height = 0

    open var value: T {
        get { return _value }
        set { _value = newValue }
    }
    open var height: Int {
        get { return _height }
        set { _height = newValue }
    }

    required public init(value: T) {
        _value = value
        _height = 1
    }

    public init(node: BinarySearchTreeNode<T>) {
        _value = node.value
        _height = 1
    }

    /// Set by tree for primary node only. Insert, Delete, and balancing routines are responsible for toggling this
    public var isRoot: Bool {
        get { return _is_root }
        set { _is_root = newValue }
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

    /// Calculates the height of the left subtree.
    public var leftHeight: Int { return left?.height ?? -1 }

    /// Calculates the height of the right subtree.
    public var rightHeight: Int { return right?.height ?? -1 }

    // For Comparable conformance
    public static func == (lhs: BinarySearchTreeNode<T>, rhs: BinarySearchTreeNode<T>) -> Bool {
        return lhs.value == rhs.value
    }

    // For Comparable conformance
    public static func < (lhs: BinarySearchTreeNode<T>, rhs: BinarySearchTreeNode<T>) -> Bool {
        return lhs.value < rhs.value
    }
}


/// A binary search tree (BST). Each node stores a value and up to two children.
/// As BSTs are utilized as classifications (or keys in a dictionary), they are not Bag data structures - meanding
/// that duplicate values are not allowed. 
/// This tree does not automatically balance itself. To make sure it is balanced, you should insert new values in
/// randomized order, not in sorted order.
open class BinarySearchTree<T: TreeValueP>: TreeP where T: Comparable {
    private var _root: BinarySearchTreeNode<T>?
    public var nodeCount: Int = 0

    open var root: BinarySearchTreeNode<T>? {
        get { return _root }
        set { _root = newValue }
    }

    //required public init(value: T) {
    public init(value: T) {
        _root = BinarySearchTreeNode<T>(value: value)
        _root?.isRoot = true
        nodeCount += 1
    }

    public init(node: some BinarySearchTreeNode<T>) {
        _root = node
        _root?.isRoot = true
        nodeCount += 1
    }

    public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            _ = try? insert(node: NodeType(value: v))
        }
    }

    // MARK: - Subscript access
    /// Custom collection accessor for [] notation.
    /// To find out if a value is present in tree, use tree[value] - value will be returned if it exists.
    /// To replace an existing value, use tree[existing_value] = new_value.
    /// To remove a key from the tree, use tree[value] = nil.
    /// To add a new value to the tree, assign the value to itself: tree[value] = value.
    open subscript(key: T) -> T? {
        get { return search(value: key)?.value }
        set(newValue) {
            // if given a value
            if let replace = newValue {
                // replace value with given
                if let node: BinarySearchTreeNode<T> = search(value: key) {
                    node.value = replace
                } else if key == replace {
                    try! self.insert(node: BinarySearchTreeNode<T>(value: key))
                }
            } else { // else we delete node
                remove(value: key)
            }
        }
    }

    // MARK: - Tree Structure
    /// return an array of node values from an in-order traversal
    open func toArray() -> [T] {
        var inOrder = [T]()
        traverseInOrder { inOrder.append($0) }
        return inOrder
    }

    /// How many nodes are in this tree. Performance: O(n).
    public var size: Int {
        return nodeCount
    }

    /// Calculates the height of the tree, i.e. the distance from root to the lowest leaf. A tree of one node has height == 1.
    /// Since this looks at all children of tree, performance is O(n).
    open func height() -> Int {
        guard let root = self.root else {
            return 0
        }
        return height(node: root)
    }

    /// Calculates the height of a given node in tree. There is a dynamic cost to using this function
    /// over the height property of nodes, but the latter are only guaranteed to be accurate after balancing in AVL trees.
    public func height(node: BinarySearchTreeNode<T>?) -> Int {
        guard let node = node, let _ = self.root else {
            return 0
        }
        let lHeight = height(node: node.left)
        let rHeight = height(node: node.right)
        return max(lHeight, rHeight) + 1
    }

    /// Returns true iff node is in the left subtree of root
    public func inLeftTree(value: T) -> Bool {
        // in case root is not set
        guard let root = self.root else { return false }
        // root is in neither subtree
        var node = root.left
        while let n = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            }
            if node?.value == value {
                return true
            }
        }
        return false
    }

    /// Returns true iff node is in the right subtree of root
    public func inRightTree(value: T) -> Bool {
        // in case root is not set
        guard let root = self.root else { return false }
        // root is in neither subtree
        var node = root.right
        while let n = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            }
            if node?.value == value {
                return true
            }
        }
        return false
    }

    /// Check if tree contains value. Runs in search time.
    open func contains(value: T) -> Bool {
        return search(value: value) != nil
    }

    /// Returns the leftmost descendent of tree. O(h) time.
    open func minimum() -> BinarySearchTreeNode<T>? {
        var node = self.root
        while let next = node?.left {
            node = next
        }
        return node
    }

    /// Returns the leftmost descendent of given node. O(h) time.
    open func minimum(node: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T>? {
        var n = node
        while let next = n.left {
            n = next
        }
        return n
    }

    /// Returns the rightmost descendent of tree. O(h) time.
    public func maximum() -> BinarySearchTreeNode<T>? {
        var node = self.root
        while let next = node?.right {
            node = next
        }
        return node
    }

    /// Returns the rightmost descendent of given node. O(h) time.
    public func maximum(node: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T>? {
        var n = node
        while let next = n.right {
            n = next
        }
        return n
    }

    /// Finds the node whose value preceedes our value in sorted order.
    open func predecessor(value: T) -> T? {
        guard let root = self.root else { return nil }
        guard let node = search(value: value) else { return nil }
        var result = [T]()
        traverseInOrder(node: root, completion: { if $0 < node.value { result.append($0) }})
        return result.popLast()
    }

    /// Finds the node whose value succeeds our value in sorted order.
    open func successor(value: T) -> T? {
        guard let root = self.root else { return nil }
        guard let node = search(value: value) else { return nil }
        var result = [T]()
        traverseInOrder(node: root, completion: { if $0 > node.value { result.append($0) }})
        return result.first
    }

    // MARK: - Traversal

    /// In-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var inOrder = [Int]()
    /// tree.traverseInOrder { inOrder.append($0) }
    /// ```
    public func traverseInOrder(completion: (T) -> Void) {
        guard let root = self.root else { return }
        traverseInOrder(node: root, completion: completion)
    }

    private func traverseInOrder(node: BinarySearchTreeNode<T>, completion: (T) -> Void) {
        if let left = node.left { traverseInOrder(node: left, completion: completion) }
        completion(node.value)
        if let right = node.right { traverseInOrder(node: right, completion: completion) }
    }

    /// Pre-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var preOrder = [Int]()
    /// tree.traversePreOrder { preOrder.append($0) }
    /// ```
    public func traversePreOrder(completion: (T) -> Void) {
        guard let root = self.root else { return }
        traversePreOrder(node: root, completion: completion)
    }

    private func traversePreOrder(node: BinarySearchTreeNode<T>,
                                  completion: (T) -> Void) {
        completion(node.value)
        if let left = node.left { traversePreOrder(node: left, completion: completion) }
        if let right = node.right { traversePreOrder(node: right, completion: completion) }
    }

    /// Post-order traversal using given function as accumulator for node values.
    /// use like this:
    /// ```
    /// var postOrder = [Int]()
    /// tree.traversePostOrder { postOrder.append($0) }
    /// ```
    public func traversePostOrder(completion: (T) -> Void) {
        guard let root = self.root else { return }
        traversePostOrder(node: root, completion: completion)
    }

    private func traversePostOrder(node: BinarySearchTreeNode<T>, completion: (T) -> Void) {
        if let left = node.left { traversePostOrder(node: left, completion: completion) }
        if let right = node.right { traversePostOrder(node: right, completion: completion) }
        completion(node.value)
    }

    /// Performs an in-order traversal, applying the given map function, and collects the values in an array:
    /// (BinarySearchTree) -> BinarySearchTree) and returns [BinarySearchTreeNode<T>]
    /// - Parameters:
    ///   - formula: map takes function: (BinarySearchTree) -> BinarySearchTree)
    /// - Returns: [BinarySearchTreeNode<T>] of nodes after applying map function
    open func map(_ formula: (T) -> T) -> [T] {
        var result = [T]()
        guard let root = self.root else {
            return result
        }
        map(node: root, apply: formula, result: &result)
        return result
    }

    /// Recursively performs an in-order traversal, applying the given map function, and collects the values in an array.
    /// - Parameters:
    ///   - node: the node in which to begin traversal
    ///   - apply: map  function: ((BinarySearchTree) -> BinarySearchTree) -> [BinarySearchTreeNode<T>]
    ///   - result: inout reference to the collector
    /// - Returns: (implicitly returns result as inout reference)
    private func map(node: BinarySearchTreeNode<T>,
                     apply: ((T) -> T),
                     result: inout [T]) {
        if let left = node.left { map(node: left, apply: apply, result: &result) }

        let newValue = apply(node.value)
        node.value = newValue // update tree
        result.append(newValue) // append to results (inorder)
        
        if let right = node.right { map(node: right, apply: apply, result: &result) }
    }

    // MARK: - Searching
    /// Finds the "highest" (in tree) node with the specified value.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    open func search(value: T) ->  BinarySearchTreeNode<T>? {
        guard let root = self.root else {
            return nil
        }
        var node: BinarySearchTreeNode<T>? = root
        if root.value == value {
            return root
        }
        while let n = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            } else {
                return n
            }
        }
        return node
    }

    // MARK: - Adding items
    /// Inserts a new element into the tree. You should randomly insert elements at the root, to make to sure this remains a valid
    /// binary tree! Duplicate values are ignored, but this incurs a lookup penalty.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult open func insert(node: BinarySearchTreeNode<T>) throws -> BinarySearchTreeNode<T> {
        // in case root is not set
        guard let root = self.root else {
            throw TreeError.invalidTree
        }
        // TODO: reimplement contains as a hash for constant time lookup
        // used to prevent duplicate values being inserted into tree
        if self.contains(value: node.value) {
            return node
        }
        return insert(tree: root, node: node, parent: nil)
    }

    @discardableResult private func insert(tree: BinarySearchTreeNode<T>,
                                          node: BinarySearchTreeNode<T>,
                                          parent: BinarySearchTreeNode<T>?) -> BinarySearchTreeNode<T> {
        var insertionNode = node
        let parent = parent ?? root
        let nodeType = type(of: node) // for subclassing

        if node.value < tree.value {
            if let left = tree.left {
                insert(tree: left,
                       node: node,
                       parent: left)
            } else {
                let temp = nodeType.init(value: node.value)
                tree.left = temp
                temp.parent = parent
                insertionNode = temp
                nodeCount += 1
            }
        } else {
            if let right = tree.right {
                insert(tree: right,
                       node: node,
                       parent: right)
            } else {
                let temp = nodeType.init(value: node.value)
                tree.right = temp
                temp.parent = parent
                insertionNode = temp
                nodeCount += 1
            }
        }
        return insertionNode
    }

    // MARK: - Deleting items
    /// Deletes a node from the tree and returns its replacement, if any.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult open func remove(value: T) -> BinarySearchTreeNode<T>? {
        guard var replace = search(value: value) else {
            return nil
        }
        if nodeCount == 1 {
            root = nil
            nodeCount = 0
        } else {
            replace = try! deleteNode(node: replace)!
            nodeCount -= 1
        }
        return replace
    }

    /// Deletes the given node and returns its replacement, if any
    public func deleteNode(node: BinarySearchTreeNode<T>) throws -> BinarySearchTreeNode<T>? {
        if node.isLeaf {
            // Just remove node and set parent pointer to nil
            if let parent = node.parent {
                guard node.isLeftChild || node.isRightChild else {
                    throw TreeError.invalidTree
                }
                if node.isLeftChild {
                    parent.left = nil
                } else if node.isRightChild {
                    parent.right = nil
                }
                // remove all connections to tree so that memory can be reclaimed
                node.parent = nil
                node.left = nil
                node.right = nil
            } else { // must be root
                root = nil
            }
        } else {
            // Handle stem cases
            if let left = node.left {
                // replace with max valued node from left tree
                if let replacement = maximum(node: left) {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement or fail
                    _ = try deleteNode(node: replacement)
                }
                // replace with min valued node from right tree
            } else if let right = node.right {
                if let replacement = minimum(node: right), replacement !== node {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement or fail
                    _ = try deleteNode(node: replacement)
                }
                // deletion will throw by now iff not successful

            } else {
                throw TreeError.invalidTree
            }
        }
        // return replacement node (same node, but values have changed - this allows external references to root to remain valid)
        return node
    }

    /// Draw the tree as a flattened structure of node children. The implementation is in an extension so that derived classes can provide their own implementations.
    open func draw() {
        guard let root = self.root else {
            print("* tree is empty *")
            return
        }
        let treeType = type(of: self)
        print("\n") // newline
        let report =
        """
        <<< tree[\(treeType)] root is \(root.value), size=\(size), height=\(height(node: root)), lheight=\(height(node: root.left)), rheight=\(height(node: root.right)): leaf nodes are followed by ?, root node is followed by * >>>
        """
        print(report)
        draw(root)
        print("\n") // newline
    }

    /// Draw the tree as a flattened structure of node parents. The implementation is in an extension so that derived classes can provide their own implementations.
    open func drawParents() {
        guard let root = self.root else {
            print("* tree is empty *")
            return
        }
        let treeType = type(of: self)
        print("\n") // newline
        let report =
        """
        <<< tree[\(treeType)] root is \(root.value), size=\(size), height=\(height(node: root)), leaf nodes are marked with ?. Parents of nodes are indicated with "^" followed by the node's parent value or "x" if node is root of tree. Any nodes with invalid parents are marked with an "❌">>>
        """
        print(report)
        drawParents(of:root)
        print("\n") // newline
    }
}

// MARK: - Displaying tree
extension BinarySearchTree: CustomStringConvertible {
    public var description: String {
        var inOrder = [T]()
        traverseInOrder { inOrder.append($0) }
        return inOrder.description
    }

    private func draw(_ node: BinarySearchTreeNode<T>) {
        if let left = node.left { print("(", terminator: ""); draw(left); print(" <- ", terminator:""); }

        if node.hasBothChildren { print("\(node.value)", terminator:"")  }
        else if node.hasLeftChild { print("\(node.value)", terminator:")") }
        else if node.hasRightChild { print("(\(node.value)", terminator:"") }
        else { print("\(node.value)", terminator:"?") } // leaf
        if node.isRoot { print("*", terminator:"")}

        if let right = node.right { print(" -> ", terminator:""); draw(right); print("", terminator: ")") }
    }

    private func drawParents(of node: BinarySearchTreeNode<T>?) {
        guard let node = node else {
            return
        }
        if let left = node.left { print("(", terminator: ""); drawParents(of: left); print(" -> ", terminator:""); }

        if let parent = node.parent {
            let entry = "\(node.value)^\(parent.value)"
            if node.hasBothChildren { print(entry, terminator:"")  }
            else if node.hasLeftChild { print(entry, terminator:")") }
            else if node.hasRightChild { print("(\(entry)", terminator:"") }
            else { print(entry, terminator:"?") } // leaf
        } else if node.isRoot {
                print("\(node.value)^x", terminator:"")
        } else {
            let entry = "\(node.value)^❌"
            if node.hasBothChildren { print(entry, terminator:"")  }
            else if node.hasLeftChild { print(entry, terminator:")") }
            else if node.hasRightChild { print("(\(entry)", terminator:"") }
            else { print(entry, terminator:"?") } // leaf
        }

        if let right = node.right { print(" <- ", terminator:""); drawParents(of: right); print("", terminator: ")") }
    }

    // MARK: - Displaying tree

    /// Display the tree in graphical fashion
    public func display(node: BinarySearchTreeNode<T>) {
        guard let _ = root else {
            print("* tree is empty *")
            return
        }
        print("\nDisplaying [node]: level in tree")
        print("---------------------------------------")
        display(node: node, level: 0)
        print("\n")
    }

    fileprivate func display(node: BinarySearchTreeNode<T>?, level: Int) {
        if let node = node {
            display(node: node.right, level: level + 1)
            print("")
            if node.isRoot {
                print("Root -> ", terminator: "")
            }
            for _ in 0..<level {
                print("        ", terminator:  "")
            }
            if node.isRoot {
                print("\(node.value):\(height(node: node))", terminator: "")
            } else {
                if node.isLeftChild {
                    print("\(node.value):\(height(node: node))", terminator: " L")
                } else {
                    print("\(node.value):\(height(node: node))", terminator: " R")
                }
            }
            display(node: node.left, level: level + 1)
        }
    }
}
