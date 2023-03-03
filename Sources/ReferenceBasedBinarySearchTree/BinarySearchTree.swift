import TreeProtocol

open class BinarySearchTreeNode<T: Comparable>: TreeNodeProtocol {
    public typealias Node = BinarySearchTreeNode<T>
    public var value: T
    public var left: Node?
    public var right: Node?
    public var parent: Node?

    public init(value: T) {
        self.value = value
    }

    public init(node: BinarySearchTreeNode<T>) {
        self.value = node.value
    }

    public var isRoot: Bool {
        return parent == nil
    }

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

    public var hasLeftChild: Bool {
        return left != nil
    }

    public var hasRightChild: Bool {
        return right != nil
    }

    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }

    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }

    // For Comparable conformance
    public static func == (lhs: BinarySearchTreeNode<T>, rhs: BinarySearchTreeNode<T>) -> Bool {
        return false
    }

    // For Comparable conformance
    public static func < (lhs: BinarySearchTreeNode<T>, rhs: BinarySearchTreeNode<T>) -> Bool {
        return false
    }
}


/// A binary search tree. Each node stores a value and up to two children. This tree ignores any inserted duplicate elements.
/// This tree does not automatically balance itself. To make sure it is balanced, you should insert new values in
/// randomized order, not in sorted order.
open class BinarySearchTree<T: Comparable>: TreeProtocol {
    public var root: BinarySearchTreeNode<T>?
    public var nodeCount: Int = 0 // keep public for classes that must override insert()

    public init(value: T) {
        root = BinarySearchTreeNode(value: value)
        nodeCount += 1
    }

    public init(node: BinarySearchTreeNode<T>) {
        root = node
        nodeCount += 1
    }

    public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            _ = try? insert(value: v)
        }
    }

    // MARK: - Subscript access

    /// Custom collection accessor for [] notation
    open subscript(key: T) -> T? {
        get { return search(value: key)?.value }
        // subscript doesn't support throws as of now, so swallow the error
        set(newValue) {
            // if replacing a node (value)
            if let replace = newValue {
                remove(value: key)
                _ = try? insert(value: replace)
            } else { // insert new node (value)
                _ = try? insert(value: key)
            }
        }
    }

    // MARK: - Tree Structure

    /// How many nodes are in this tree. Performance: O(n).
    public var size: Int {
        return nodeCount
    }

    /// Calculates the height of the tree, i.e. the distance from root to the lowest leaf. A tree of one node has height == 1.
    /// Since this looks at all children of tree, performance is O(n).
    public func height() -> Int {
        guard let root = self.root else {
            return 0
        }
        return height(node: root)
    }

    public func height(node: NodeType?) -> Int {
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
        if value < root.value { return true }
        return false
    }

    /// Returns true iff node is in the right subtree of root
    public func inRightTree(value: T) -> Bool {
        // in case root is not set
        guard let root = self.root else { return false }
        // root is in neither subtree
        if value > root.value { return true }
        return false
    }

    // MARK: - Adding items
    /// Inserts a new element into the tree. You should randomly insert elements at the root, to make to sure this remains a valid
    /// binary tree! Duplicate values are ignored, but this incurs a lookup penalty.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult open func insert(value: T) throws -> Self {
        // in case root is not set
        guard let root = self.root else {
            throw TreeError.invalidTree
        }
        if self.contains(value: value) {
            return self
        }
        return insert(tree: root, value: value, parent: nil)
    }

    @discardableResult private func insert(tree: BinarySearchTreeNode<T>, value: T, parent: BinarySearchTreeNode<T>?) -> Self {
        let node: BinarySearchTreeNode<T> = tree
        let parent = parent ?? root

        if value < node.value {
            if let left = node.left {
                insert(tree: left, value: value, parent: left )
            } else {
                let temp = BinarySearchTreeNode(value: value)
                node.left = temp
                temp.parent = parent
                nodeCount += 1
            }
        } else {
            if let right = node.right {
                insert(tree: right, value: value, parent: right)
            } else {
                let temp = BinarySearchTreeNode(value: value)
                node.right = temp
                temp.parent = parent
                nodeCount += 1
            }
        }
        return self
    }

    // MARK: - Deleting items

    /// Deletes a node from the tree.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    @discardableResult open func remove(value: T) -> Self {
        guard let replace = search(value: value) else {
            return self
        }

        if nodeCount == 1 {
            root = nil
            nodeCount -= 1
        } else {
            do {
                try deleteNode(node: replace)
                nodeCount -= 1
            } catch {
                // not a fatal error - node might not exist
                print("!!! enable to remove node \(replace.value)")
            }
        }
        return self
    }

    private func deleteNode(node: BinarySearchTreeNode<T>) throws {
        if node.isLeaf {
            // Just remove and balance up
            if let parent = node.parent {
                guard node.isLeftChild || node.isRightChild else {
                    // just in case
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
            } else if let right = node.right {
                if let replacement = minimum(node: right), replacement !== node {
                    // give the deleted node its replacement's value
                    node.value = replacement.value
                    // then delete the replacement
                    try? deleteNode(node: replacement)
                }
            }
        }
    }

    // MARK: - Searching

    /// Finds the "highest" (in tree) node with the specified value.
    /// Performance: runs in O(h) time, where h is the height of the tree.
    open func search(value: T) -> BinarySearchTreeNode<T>? {
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

    public func contains(value: T) -> Bool {
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
        if !self.contains(value: n.value) { return nil }
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
        if !self.contains(value: n.value) { return nil }
        while let next = n.right {
            n = next
        }
        return n
    }

    /// Finds the node whose value preceedes our value in sorted order.
    public func predecessor(value: T) -> T? {
        guard let root = self.root else { return nil }
        guard let node = search(value: value) else { return nil }
        var result = [T]()
        traverseInOrder(node: root, completion: { if $0 < node.value { result.append($0) }})
        return result.popLast()
    }

    /// Finds the node whose value succeeds our value in sorted order.
    public func successor(value: T) -> T? {
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

    private func traversePreOrder(node: BinarySearchTreeNode<T>, completion: (T) -> Void) {
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

    /// Performs an in-order traversal, applying the given map function, and collects the values in an array.
    open func map(_ formula: (T) -> T) -> [T] {
        var result = [T]()
        guard let root = self.root else {
            return result
        }
        map(node: root, apply: formula, result: &result)
        return result
    }

    private func map(node: BinarySearchTreeNode<T>, apply: ((T) -> T), result: inout [T]) {
        if let left = node.left { map(node: left, apply: apply, result: &result) }

        let newValue = apply(node.value)
        node.value = newValue // update tree
        result.append(newValue) // append to results (inorder)
        
        if let right = node.right { map(node: right, apply: apply, result: &result) }
    }


    /// Draw the tree as a flattened structure. The implementation is in an extension so that derived classes can provide their own implementations.
    open func draw() {
        guard let root = self.root else {
            print("* tree is empty *")
            return
        }
        print("\n") // newline
        print("<<< tree root is \(root.value), size=\(size), height=\(height(node: root)): leaf nodes are marked with ? >>>")
        draw(root)
        print("\n") // newline
    }
}

// MARK: - Debugging
extension BinarySearchTree: CustomStringConvertible {
    public var description: String {
        var inOrder = [T]()
        traverseInOrder { inOrder.append($0) }
        return inOrder.description
    }

    // return an array of node values from an in-order traversal
    public func toArray() -> [T] {
        var inOrder = [T]()
        traverseInOrder { inOrder.append($0) }
        return inOrder
    }

    private func draw(_ node: BinarySearchTreeNode<T>) {
        if let left = node.left { print("(", terminator: ""); draw(left); print(" <- ", terminator:""); }

        if node.hasBothChildren { print("\(node.value)", terminator:"")  }
        else if node.hasLeftChild { print("\(node.value)", terminator:")") }
        else if node.hasRightChild { print("(\(node.value)", terminator:"") }
        else { print("\(node.value)", terminator:"?") } // leaf

        if let right = node.right { print(" -> ", terminator:""); draw(right); print("", terminator: ")") }
    }
}
