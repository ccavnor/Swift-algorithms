import TreeProtocol


// TODO: insertion by type is forcing me to type convert for many operations, since insert is owned by
// BinarySearchTree, any values inserted are assumed to be of its type. By inserting nodes - the types
// will never be in question.

open class BinarySearchTreeNode<T: TreeValueP>: TreeNodeP where T: Comparable {
    public var value: T
    public var left: BinarySearchTreeNode<T>?
    public var right: BinarySearchTreeNode<T>?
    public var parent: BinarySearchTreeNode<T>?

    public var height = 0

    public required init(value: T) {
        self.value = value
    }

    public required init(node: BinarySearchTreeNode<T>) {
        self.value = node.value
    }

    open var length: Float {
        return 0
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
        return lhs.value == rhs.value
    }

    // For Comparable conformance
    public static func < (lhs: BinarySearchTreeNode<T>, rhs: BinarySearchTreeNode<T>) -> Bool {
        return lhs.value < rhs.value
    }
}


/// A binary search tree. Each node stores a value and up to two children. This tree ignores any inserted duplicate elements.
/// This tree does not automatically balance itself. To make sure it is balanced, you should insert new values in
/// randomized order, not in sorted order.
//open class BinarySearchTree<T: AdditiveArithmetic & Comparable>: TreeProtocol {
open class BinarySearchTree<T: TreeValueP>: TreeP where T: Comparable {
    public var root: BinarySearchTreeNode<T>?
    public var nodeCount: Int = 0

    public required init(value: T) {
        self.root = BinarySearchTreeNode<T>(value: value)
        nodeCount += 1
    }

    public required init(node: BinarySearchTreeNode<T>) {
        self.root = node
        nodeCount += 1
    }

    required public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            _ = try? insert(node: NodeType(value: v))
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
                _ = try? insert(node: NodeType(value: replace))
            } else { // insert new node (value)
                _ = try? insert(node: NodeType(value: key))
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
        // TODO: contains check only adds time complexity?
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
        // TODO: contains check only adds time complexity?
        if !self.contains(value: n.value) { return nil }
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

    /// Performs an in-order traversal, applying the given map function, and collects the values in an array.
    open func map(_ formula: (T) -> T) -> [T] {
        var result = [T]()
        guard let root = self.root else {
            return result
        }
        map(node: root, apply: formula, result: &result)
        return result
    }

    private func map(node: BinarySearchTreeNode<T>,
                     apply: ((T) -> T),
                     result: inout [T]) {
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
        let treeType = type(of: self)
        print("\n") // newline
        let report =
        """
        <<< tree[\(treeType)] root is \(root.value), size=\(size), height=\(height(node: root)), lheight=\(self.height(node: root.left)), rheight=\(self.height(node: root.right)): leaf nodes are marked with ? >>>
        """
        print(report)
        draw(root)
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

        if let right = node.right { print(" -> ", terminator:""); draw(right); print("", terminator: ")") }
    }

    // MARK: - Displaying tree
    public func display(node: BinarySearchTreeNode<T>) {
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
            print("\(node.value):\(height(node: node))", terminator: "")
            display(node: node.left, level: level + 1)
        }
    }
}
