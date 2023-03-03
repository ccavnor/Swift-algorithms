import TreeProtocol
import BinarySearchTree

// TODO: AVLTree should probably use memoized properties on TreeNode for height via updateHeightUpwards()
open class TreeNode<T: Comparable>: BinarySearchTreeNode<T> {
    public typealias Node = TreeNode<T>
    
    public init(value: T, leftChild: Node?, rightChild: Node?, parent: Node?, height: Int) {
        super.init(value: value)
        self.left = leftChild
        self.right = rightChild
        self.parent = parent
    }
    
    public convenience override init(value: T) {
        self.init(value: value, leftChild: nil, rightChild: nil, parent: nil, height: 1)
    }
    
    public override init(node: BinarySearchTreeNode<T>) {
        super.init(node: node)
    }
}

// MARK: - The AVL tree

/// AVLTree is a BST that self balances iff the subtrees are more than one level of difference in height.
/// This implementation of AVLTree is constrained to Numeric types, but the BinarySearchTree that it extends
/// does not have this constraint.
open class AVLTree<T: Comparable & Numeric>: BinarySearchTree<T> {
    public typealias Node = BinarySearchTreeNode<T>
    
    // MARK: - Subscript access
    override public subscript(key: T) -> T? {
        get { return super[key] } // uses super implicitly
        set(newValue) {
            super[key] = newValue
            balance()
        }
    }
    
    // MARK: - Inserting new items
    @discardableResult override open func insert(value: T) throws -> Self {
        guard let root = self.root else {
            return self
        }
        do {
            try super.insert(value: value)
        } catch {
            throw TreeError.invalidTree
        }
        balance(node: root)
        return self
    }
    
    
    // MARK: - Delete node
    override public func remove(value: T) -> Self {
        let parent = search(value: value)?.parent ?? root
        super.remove(value: value)
        
        balance(node: parent)
        return self
    }
}


// MARK: - Balancing tree
extension AVLTree {
    /// Throws TreeError.notBalanced iff the tree is imbalanced
    public func inOrderCheckBalanced(_ node: Node?) throws {
        if let node = node {
            guard abs(height(node: node.left) - height(node: node.right)) <= 1 else {
                throw TreeError.notBalanced
            }
            //            try inOrderCheckBalanced(node.left)
            //            try inOrderCheckBalanced(node.right)
        }
    }
    
    fileprivate func updateHeightUpwards(node: Node?) {
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
    
    fileprivate func lrDifference(node: Node?) -> Int {
        let lHeight = height(node: node?.left)
        let rHeight = height(node: node?.right)
        return lHeight - rHeight
    }
    
    internal func balance() {
        balance(node: self.root)
    }
    
    fileprivate func balance(node: Node?) {
        guard let node = node else {
            return
        }
        
        //        updateHeightUpwards(node: node.left)
        //        updateHeightUpwards(node: node.right)
        
        var nodes = [Node?](repeating: nil, count: 3)
        var subtrees = [Node?](repeating: nil, count: 4)
        let nodeParent = node.parent
        
        let lrFactor = lrDifference(node: root)
        self.draw()
        
        if lrFactor > 1 {
            // left-left or left-right
            if lrDifference(node: node.left) > 0 {
                // LL Rotation
                nodes[0] = node
                nodes[2] = node.left
                nodes[1] = nodes[2]?.left
                
                subtrees[0] = nodes[1]?.left
                subtrees[1] = nodes[1]?.right
                subtrees[2] = nodes[2]?.right
                subtrees[3] = nodes[0]?.right
            } else {
                // LR Rotation
                nodes[0] = node
                nodes[1] = node.left
                nodes[2] = nodes[1]?.right
                
                subtrees[0] = nodes[1]?.left
                subtrees[1] = nodes[2]?.left
                subtrees[2] = nodes[2]?.right
                subtrees[3] = nodes[0]?.right
            }
        } else if lrFactor < -1 {
            // right-left or right-right
            if lrDifference(node: node.right) < 0 {
                // RR Rotation
                nodes[1] = node
                nodes[2] = node.right
                nodes[0] = nodes[2]?.right
                
                subtrees[0] = nodes[1]?.left
                subtrees[1] = nodes[2]?.left
                subtrees[2] = nodes[0]?.left
                subtrees[3] = nodes[0]?.right
            } else {
                // RL Rotation
                nodes[1] = node
                nodes[0] = node.right
                nodes[2] = nodes[0]?.left
                
                subtrees[0] = nodes[1]?.left
                subtrees[1] = nodes[2]?.left
                subtrees[2] = nodes[2]?.right
                subtrees[3] = nodes[0]?.right
            }
        } else {
            // Don't need to balance 'node', go for parent
            balance(node: node.parent)
            return
        }
        
        // nodes[2] is always the head
        
        if node.isRoot {
            root = nodes[2]
            root?.parent = nil
        } else if node.isLeftChild {
            nodeParent?.left = nodes[2]
            nodes[2]?.parent = nodeParent
        } else if node.isRightChild {
            nodeParent?.right = nodes[2]
            nodes[2]?.parent = nodeParent
        }
        
        nodes[2]?.left = nodes[1]
        nodes[1]?.parent = nodes[2]
        nodes[2]?.right = nodes[0]
        nodes[0]?.parent = nodes[2]
        
        nodes[1]?.left = subtrees[0]
        subtrees[0]?.parent = nodes[1]
        nodes[1]?.right = subtrees[1]
        subtrees[1]?.parent = nodes[1]
        
        nodes[0]?.left = subtrees[2]
        subtrees[2]?.parent = nodes[0]
        nodes[0]?.right = subtrees[3]
        subtrees[3]?.parent = nodes[0]
        
        //        updateHeightUpwards(node: nodes[1])    // Update height from left
        //        updateHeightUpwards(node: nodes[0])    // Update height from right
        
        balance(node: nodes[2]?.parent)
    }
}

// MARK: - Displaying tree
extension AVLTree {
    public func display(node: Node) {
        display(node: node, level: 0)
        print("")
    }
    
    fileprivate func display(node: Node?, level: Int) {
        if let node = node {
            display(node: node.right, level: level + 1)
            print("")
            if node.isRoot {
                print("Root -> ", terminator: "")
            }
            for _ in 0..<level {
                print("        ", terminator:  "")
            }
            print("(\(node.value):\(height(node: node))", terminator: "")
            display(node: node.left, level: level + 1)
        }
    }
}
