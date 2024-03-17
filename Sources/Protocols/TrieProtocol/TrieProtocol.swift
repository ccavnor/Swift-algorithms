//
//  TrieProtocol.swift
//
//
//  Created by Christopher Charles Cavnor on 3/6/24.
//

public protocol TrieNodeP: AnyObject {
    associatedtype T: Hashable
    associatedtype NodeType: TrieNodeP

    // MARK: - TrieNode computed variables
    var value: T? { get }
    var parentNode: NodeType? { get }
    var children: [T: NodeType] { get }
    var isTerminating: Bool { get }
    var isLeaf: Bool { get }
    var isRoot: Bool { get }
    
    // MARK: - TrieNode operations
    func add(value: T) -> NodeType?
}

public protocol TrieP: AnyObject {
    associatedtype NodeType: TrieNodeP

    // MARK: - Trie computed variables
    var root: NodeType { get }
    var count: Int { get }
    var isEmpty: Bool { get }
    var words: [String] { get }

    // MARK: - Trie operations
    func insert(word: String)
    func contains(word: String) -> Bool
    func remove(word: String)

    // MARK: - Trie visualization
    func draw()
}
