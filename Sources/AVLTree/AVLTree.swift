import TreeProtocol
import BinarySearchTree

// TODO: AVLTree should probably use memoized properties on TreeNode for height via updateHeightUpwards()
open class AVLTreeNode<T: TreeValueP>: BinarySearchTreeNode<T> {

    public required init(value: T) {
        super.init(value: value)
        self.value = super.value
    }

    public required init(node: BinarySearchTreeNode<T>) {
        super.init(node: node)
        self.value = super.value
    }

    public var balanceFactor: Int {
        return (leftHeight - rightHeight)
    }
    public var leftHeight: Int {
      return left?.height ?? -1
    }
    public var rightHeight: Int {
      return right?.height ?? -1
    }
}

// MARK: - The AVL tree

/// AVLTree is a BST that self balances iff the subtrees are more than one level of difference in height.
/// This implementation of AVLTree is constrained to Numeric types, but the BinarySearchTree that it extends
/// does not have this constraint.
open class AVLTree<T: TreeValueP>: BinarySearchTree<T> {

    public required init(value: T) {
        super.init(value: value)
        self.root = AVLTreeNode<T>(value: value)
    }

    public required init(node: BinarySearchTreeNode<T>) {
        super.init(node: node)
    }

    public required convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(node: AVLTreeNode(value: array.first!))
        for v in array.dropFirst() {
            _ = try? insert(node: AVLTreeNode(value: v))
        }
    }

    @discardableResult public func insert(node: AVLTreeNode<T>) throws -> AVLTreeNode<T> {
        try! super.insert(node: node)
        let parent = node.parent ?? root // parent of replacement node
        balance(node: parent as? AVLTreeNode<T>)
        return self.root as! AVLTreeNode<T>
    }


    // MARK: - Subscript access
    override public subscript(key: T) -> T? {
        get { return super[key] } // uses super implicitly
        set(newValue) {
            super[key] = newValue
            balance()
        }
    }

    // MARK: - Delete node
    @discardableResult open func remove(value: T) -> AVLTreeNode<T>? {
        if let node = search(value: value) as? AVLTreeNode {
            try? super.deleteNode(node: node)
            nodeCount -= 1
            let parent = node.parent ?? root
            balance(node: parent as? AVLTreeNode<T>)
        }
        return self.root as? AVLTreeNode<T>
    }
}


// MARK: - Balancing tree
extension AVLTree {

    /// Throws TreeError.notBalanced iff the tree is imbalanced
    public func inOrderCheckBalanced(_ node: AVLTreeNode<T>?) throws {
        if let node = node {
            guard abs(height(node: node.left) - height(node: node.right)) <= 1 else {
                throw TreeError.notBalanced
            }
            //            try inOrderCheckBalanced(node.left)
            //            try inOrderCheckBalanced(node.right)
        }
    }
    
    fileprivate func updateHeightUpwards(node: AVLTreeNode<T>?) {
        //        if let node = node {
        ////            let lHeight = node.left?.height ?? 0
        ////            let rHeight = node.right?.height ?? 0
        ////            node.height = max(lHeight, rHeight) + 1
        //            let lHeight = height(node: node.left)
        //            let rHeight = height(node: node.right)
        //            //node.height = max(lHeight, rHeight) + 1
        //            updateHeightUpwards(node: node.parent)
        //        }
    }

    /// BF(X):=Height(LeftSubtree(X))−Height(RightSubtree(X))
    fileprivate func lrDifference(node: AVLTreeNode<T>?) -> Int {
        let lHeight = height(node: node?.left)
        let rHeight = height(node: node?.right)
        return lHeight - rHeight
    }

    private func leftRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        let pivot: AVLTreeNode = node.right! as! AVLTreeNode<T>
        node.right = pivot.left
        pivot.left = node
        // adjust parents
        pivot.left?.parent = pivot
        pivot.right?.parent = pivot
        pivot.parent = nil
        // update hights
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
        return pivot
    }

    private func rightRotate(_ node: AVLTreeNode<T>) -> AVLTreeNode<T> {
        let pivot: AVLTreeNode = node.left! as! AVLTreeNode<T>
        node.left = pivot.right
        pivot.right = node
        // adjust parents
        pivot.left?.parent = pivot
        pivot.right?.parent = pivot
        pivot.parent = nil
        // update hights
        node.height = max(node.leftHeight, node.rightHeight) + 1
        pivot.height = max(pivot.leftHeight, pivot.rightHeight) + 1
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

    public func balance() {
        guard let r = self.root else { return }
        balance(node: r as? AVLTreeNode<T> )
    }

    public func balance(node: AVLTreeNode<T>?) {
        guard let node = node as? AVLTreeNode else {
            return
        }
        var lrDifference = lrDifference(node: node)
        // normalize for switch cases
        if lrDifference < -2 { lrDifference = -2 }
        if lrDifference > 2 { lrDifference = 2 }
//        if lrDifference > 2 || lrDifference < -2 {
//            fatalError("!!! balance function is implemented to operate after each insert or remove operation. Cannot balance recursively !!!")
//        }

        let leftChild = node.left as? AVLTreeNode
        let rightChild = node.right as? AVLTreeNode

        switch lrDifference {
        case 2:
            if let leftChild = node.left as? AVLTreeNode, leftChild.balanceFactor == -1 {
                print(">>>>>>> LR rotation")
                self.root = leftRightRotate(node)
            } else {
                print(">>>>>>> RR rotation")
                self.root = rightRotate(node)
            }
        case -2:
            if let rightChild = node.right as? AVLTreeNode, rightChild.balanceFactor == 1 {
                print(">>>>>>> RL rotation")
                self.root = rightLeftRotate(node)
            } else {
                print(">>>>>>> LL rotation")
                self.root = leftRotate(node)
            }
        default:
            return
        }
    }
}

