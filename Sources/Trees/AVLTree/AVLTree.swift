import TreeProtocol
import BinarySearchTree

open class AVLTreeNode<T: TreeValueP>: BinarySearchTreeNode<T> {
    required public init(value: T) {
        super.init(value: value)
        assert(height == 1)
        assert(self.value == value)
    }

    public init(node: AVLTreeNode<T>) {
        super.init(node: node)
        assert(height == 1)
        assert(self.value == node.value)
    }

    public var balanceFactor: Int {
        return (leftHeight - rightHeight)
    }
}

// MARK: - The AVL tree

/// AVLTree is a BST that self balances iff the subtrees are more than one level of difference in height.
/// Like the BST, the AVL tree is a classification, not a Bag data structure - so duplicate values are
/// not allowed.
open class AVLTree<T: TreeValueP>: BinarySearchTree<T> {
    private var _root: AVLTreeNode<T>?

    public override var root: BinarySearchTreeNode<T>? {
        get { return _root }
        set { _root = newValue as? AVLTreeNode<T> }
    }

    override public init(value: T) {
        super.init(value: value)
        _root = AVLTreeNode<T>(value: value)
        _root?.isRoot = true
        assert(nodeCount == 1)
        assert(root!.isRoot)
    }

    public init(node: AVLTreeNode<T>) {
        super.init(node: node)
        _root = node
        _root?.isRoot = true
        assert(self.root?.value == node.value)
        assert(nodeCount == 1)
        assert(root!.isRoot)
    }

    public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(node: AVLTreeNode(value: array.first!))
        for v in array.dropFirst() {
            _ = try? insert(node: AVLTreeNode(value: v))
        }
        if !balance() {
            updateHeightUpwards(node: minimum() as? AVLTreeNode<T>)
            updateHeightUpwards(node: maximum() as? AVLTreeNode<T>)
        }
    }
    // MARK: - Adding items
    /// Inserts a new element into the tree. Duplicate values are ignored, but this incurs a lookup penalty of O(h).
    /// Performance: runs in O(h) time, where h is the height of the tree, plus O(log(n)) time for balancing.
    @discardableResult open func insert(node: AVLTreeNode<T>) throws -> AVLTreeNode<T> {
        try! super.insert(node: node)
        // balance iff unbalanced
        if !balance() {
            updateHeightUpwards(node: node)
        }
        // balance might have changed root
        return self.root as! AVLTreeNode<T>
    }

    // MARK: - Subscript access
    // overridden to set AVLTreeNode as type for ancestors (since insert is typed)
    open override subscript(key: T) -> T? {
        get { return search(value: key)?.value }
        set(newValue) {
            // if given a value
            if let replace = newValue {
                // replace value with given
                if let node: AVLTreeNode<T> = search(value: key) as? AVLTreeNode<T> {
                    node.value = replace
                } else if key == replace {
                    try! self.insert(node: AVLTreeNode<T>(value: key))
                }
                if !balance() {
                    updateHeightUpwards(node: newValue as? AVLTreeNode<T>)
                }
            } else { // else we delete node
                remove(value: key)
            }
        }
    }

    // MARK: - Delete node
    @discardableResult open override func remove(value: T) -> AVLTreeNode<T>? {
        guard let node = search(value: value) as? AVLTreeNode else {
            return nil
        }
        if let rnode = try? super.deleteNode(node: node) {
            nodeCount -= 1
            // balance on original parent
            if !balance() {
                updateHeightUpwards(node: minimum() as? AVLTreeNode<T>)
            }
            return rnode as? AVLTreeNode<T>
        } else {
            return nil
        }
    }

    /// Returns true iff tree balancing occurs. Tree will only balance under set constraints. Rotations
    /// will take care of unmarking the previous root and marking the new one, if root changes during balancing.
    open func balance() -> Bool {
        guard let r = self.root else { return false }
        if balance(node: r as? AVLTreeNode<T>) {
            assert(self.root!.isRoot) // ensure that node knows its root
            return true
        }
        return false
    }

    /// This routine should ONLY be called by balance() or by itself, recurrsively. Otherwise updates to root note could fail.
    private func balance(node: AVLTreeNode<T>?) -> Bool {
        guard let node = node as? AVLTreeNode else {
            return false
        }
        var lrDifference = lrDifference(node: node)
        // normalize for switch cases
        if lrDifference < -2 { lrDifference = -2 }
        if lrDifference > 2 { lrDifference = 2 }

        switch lrDifference {
        case 2:
            if let leftChild = node.left as? AVLTreeNode<T>, leftChild.balanceFactor <= -1 {
                //print(">>>>>>> LR rotation")
                self.root = leftRightRotate(node)
            } else {
                //print(">>>>>>> RR rotation")
                self.root = rightRotate(node)
            }
        case -2:
            if let rightChild = node.right as? AVLTreeNode<T>, rightChild.balanceFactor >= 1 {
                //print(">>>>>>> RL rotation")
                self.root = rightLeftRotate(node)
            } else {
                //print(">>>>>>> LL rotation")
                self.root = leftRotate(node)
            }
        default:
            return false
        }
        updateHeightUpwards(node: minimum() as? AVLTreeNode<T>)
        updateHeightUpwards(node: maximum() as? AVLTreeNode<T>)
        return true
    }
}


// MARK: - Balancing tree
extension AVLTree {
    /// Throws TreeError.notBalanced iff the tree is imbalanced. Our threshold for inbalance is only a height
    /// difference of one between branches, where as auto balance uses a threshold of two nodes difference.
    public func inOrderCheckBalanced(_ node: AVLTreeNode<T>?) throws {
        if let node = node {
            guard abs(height(node: node.left) - height(node: node.right)) <= 1 else {
                throw TreeError.notBalanced
            }
            // use node height attribute when we can. Heights are calculated at
            // node insertion and deletion, and during auto balance.
            let nl = node.left?.height ?? height(node: node.left)
            let nr = node.right?.height ?? height(node: node.right)
            let diff = abs(nl - nr)
            guard diff <= 1 else {
                throw TreeError.notBalanced
            }
            try inOrderCheckBalanced(node.left as? AVLTreeNode<T>)
            try inOrderCheckBalanced(node.right as? AVLTreeNode<T>)
        }
    }

    /// Updates height property of AVLTreeNode, starting with the node and working up to root
    public func updateHeightUpwards(node: AVLTreeNode<T>?) {
        if let node = node {
            let lHeight = node.left?.height ?? height(node: node.left)
            let rHeight = node.right?.height ?? height(node: node.right)
            node.height = max(lHeight, rHeight) + 1
            updateHeightUpwards(node: node.parent as? AVLTreeNode<T>)
        }
    }

    public func lrDifference(node: AVLTreeNode<T>?) -> Int {
        let lHeight = height(node: node?.left)
        let rHeight = height(node: node?.right)
        return lHeight - rHeight
    }

    private func leftRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        // unmark current root
        node.isRoot = false
        // do rotation
        let pivot: AVLTreeNode = node.right! as! AVLTreeNode<T>
        node.right = pivot.left
        pivot.left = node
        // mark current root
        pivot.isRoot = true
        // adjust parents
        pivot.left?.parent = pivot
        pivot.right?.parent = pivot
        pivot.left?.right?.parent = pivot.left
        pivot.parent = nil

        return pivot
    }

    private func rightRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        // unmark current root
        node.isRoot = false
        // do rotation
        let pivot: AVLTreeNode = node.left! as! AVLTreeNode<T>
        node.left = pivot.right
        pivot.right = node
        // mark current root
        pivot.isRoot = true
        // adjust parents
        pivot.left?.parent = pivot
        pivot.right?.parent = pivot
        pivot.right?.left?.parent = pivot.right
        pivot.parent = nil

        return pivot
    }

    private func rightLeftRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        guard let rightChild = node.right else {
            return node
        }
        node.right = rightRotate(rightChild as! AVLTreeNode<T>)
        return leftRotate(node)
    }

    private func leftRightRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        guard let leftChild = node.left else {
            return node
        }
        node.left = leftRotate(leftChild as! AVLTreeNode<T>)
        return rightRotate(node)
    }
}

