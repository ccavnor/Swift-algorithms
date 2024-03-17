import TrieProtocol

/// A node in the trie: values must be hashable to allow for dictionary insertion
public class TrieNode<T: Hashable>: TrieNodeP {
    public var value: T?
    public weak var parentNode: TrieNode? // weak to prevent cycles
    public var children: [T: TrieNode] = [:]
    public var isTerminating = false // marks end of word
    public var isLeaf: Bool {
        return children.count == 0
    }
    public var isRoot: Bool {
        return parentNode == nil
    }

    /// Initializes a node.
    ///
    /// - Parameters:
    ///   - value: The value that goes into the node
    ///   - parentNode: A reference to this node's parent
    public init(value: T? = nil, parentNode: TrieNode? = nil) {
        self.value = value
        self.parentNode = parentNode
    }

    /// Adds a child node to self.  If the child is already present,
    /// do nothing.
    ///
    /// - Parameters:
    ///   - value: The value that goes into the node
    public func add(value: T) -> TrieNode? {
        guard children[value] == nil else {
            return nil
        }
        let node = TrieNode(value: value, parentNode: self)
        children[value] = node
        return node
    }
}

/// Pretty print a TrieNode
extension TrieNode: CustomDebugStringConvertible {
    public var debugDescription: String {
        if value == nil {
            return "(root) - \(self.children.keys)"
        }
        return "value: \(self.value!), children: \(self.children.keys)"
    }
}

/// A trie data structure containing words.  Each node's value is a single character of a word.
/// This trie is a multi-tree (as opposed to a right shifted binary tree) where each TrieNode's children is
/// a dictionary of [value: node] where the value is the first character of an inserted word
/// and node is a reference to the child TrieNode.
public class Trie: TrieP {
    public typealias Node = TrieNode<Character>
    fileprivate let trieRoot: Node
    fileprivate var wordCount: Int

    public var root: Node {
        return trieRoot
    }

    /// The number of words in the trie
    public var count: Int {
        return wordCount
    }
    /// Is the trie empty?
    public var isEmpty: Bool {
        return wordCount == 0
    }
    /// All words currently in the trie
    public var words: [String] {
        //return wordsInSubtrie(rootNode: trieRoot, partialWord: "")
        return getWords(node: trieRoot, segment: "")
    }

    /// Creates an empty trie.
    init() {
        trieRoot = Node()
        wordCount = 0
    }
}

// MARK: - Adds methods: insert, remove, contains, draw
extension Trie {

    /// Inserts a word into the trie.  If the word is already present,
    /// there is no change.
    ///
    /// - Parameter word: the word to be inserted.
    public func insert(word: String) {
        guard !word.isEmpty else {
            return
        }
        // root always contains an index of the first character as its immediate children
        var currentNode = trieRoot
        for character in word.lowercased() {
            if let childNode = currentNode.children[character] {
                currentNode = childNode // branch (first character) exists
            } else {
                // create a new branch below currentNode
                currentNode = currentNode.add(value: character)!
            }
        }
        guard !currentNode.isTerminating else {
            return
        }
        wordCount += 1
        currentNode.isTerminating = true
    }

    /// Collects a word into an list of TrieNode. Returns complete word or nil (partial words are ignored)
    ///
    /// - Parameters:
    ///   - word: the word to check for
    /// - Returns: a list of TrieNode if the word is present, else nil
    internal func getWord(word: String) -> [Node]? {
        var currentNode = trieRoot
        var nodes = [Node]()

        for character in word.lowercased() {
            guard let childNode = currentNode.children[character] else {
                break
            }
            nodes.append(childNode)
            currentNode = childNode
        }

        // protect against partial matches
        guard currentNode.isTerminating else {
            return nil
        }
        return nodes.isEmpty ? nil : nodes
    }

    /// Collects all words in the Trie and returns as a list of strings. Operates recursively.
    /// O(n) performance, where n is a character node. But because this Trie only branches
    /// when existing words diverge from ("cuter" and "cute" only create a new node for "r"),
    /// this is the upper bound.
    ///
    /// - Parameters:
    ///   - node: the current working node
    ///   - segment: a partial word (before encountering terminating node)
    /// - Returns: all words in the Trie as a list of strings, or nil if the Trie is empty
    private func getWords(node: Node, segment: String) -> [String] {
        var words = [String]()
        var partialWord = segment

        // root node holds no value
        if let value = node.value {
            // recursively passed as word segment
            partialWord.append(value)
        }
        // terminated node isa word
        if node.isTerminating {
            words.append(partialWord)
        }

        for childNode in node.children.values {
            words += getWords(node: childNode, segment: partialWord)
        }
        return words
    }

    /// Check to see if the word exists in the Trie. Partial matches (prefix) is
    /// not supported.
    ///
    /// - Parameter word: the word to search for
    /// - Returns: true if Trie contains the word, else false
    public func contains(word: String) -> Bool {
        guard getWord(word: word) != nil else {
            return false
        }
        return true
    }

    /// Deletes nodes from trie, starting with the terminal node and
    /// following the parent pointer to the first terminating node that is found.
    /// Called only when word to remove ends with leaf node.
    ///
    /// - Parameter from: the node representing the last node of a word
    private func cullWord(from: Node) {
        var lastNode = from
        var character = lastNode.value
        while let parentNode = lastNode.parentNode {
            lastNode = parentNode
            lastNode.children[character!] = nil
            character = lastNode.value
            if lastNode.isTerminating || lastNode.isRoot {
                break
            }
        }
    }

    /// Removes a word from the trie:
    ///     case: word has no nodes shared with other words;
    ///         cull the word up to its top node.
    ///     case: word shares nodes with suffix nodes;
    ///         mark its terminal node as isTerminal=false
    ///
    /// - Parameter word: the word to be removed
    public func remove(word: String) {
        guard !word.isEmpty else {
            return
        }
        guard let terminalNode = getWord(word: word)?.last else {
            return
        }

        if terminalNode.isLeaf {
            // remove word up to some parent's terminalNode
            cullWord(from: terminalNode)
        } else {
            // word is root of other branch(es)
            terminalNode.isTerminating = false
        }
        wordCount -= 1
    }

    /// Print a visual representation of the Trie, starting at the Trie root.
    public func draw() {
        print()
        print("\nDisplaying Trie: \n\t* indicates root\n\t. indicates termination of a word")
        print("---------------------------------------")
        draw(node: trieRoot)
    }

    /// Print a visual representation of the Trie.
    ///
    /// - Parameters:
    ///   - node: the starting node
    ///   - level: the current level of the tree (for recursive indentation)
    /// - Returns: the words in the subtrie that start with prefix
    private func draw(node: Node, level: Int=0) {
        // check each node's index for current value and follow its corresponding node.
        for c in node.children.keys {
            for _ in 0..<level {
                if level != 0 {
                    print("      ", terminator:  "|")
                }
            }
            if level == 0 {
                print("* --> \(c)")
            } else {
                let nchild = node.children[c]!
                if nchild.isTerminating {
                    print("===> \(c).")
                } else {
                    print("===> \(c)")
                }
            }

            if let node = node.children[c] {
                draw(node: node, level: level + 1)
            }
        }
    }
}
