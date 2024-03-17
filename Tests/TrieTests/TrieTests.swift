//
//  TrieTests.swift
//  
//  Created by Christopher Cavnor on 4/9/23.
//  Copyright © 2023 Christopher Cavnor. All rights reserved.
//

import XCTest
@testable import Trie

class TrieTests: XCTestCase {
    /// Tests that a newly created trie has zero words.
    func testCreate() {
        let trie = Trie()
        XCTAssertEqual(trie.count, 0)
    }

    /// Tests the insert method
    func testInsert() {
        let trie = Trie()
        trie.insert(word: "cute")
        trie.insert(word: "cutie")
        trie.insert(word: "fred")
        XCTAssertTrue(trie.contains(word: "cute"))
        XCTAssertFalse(trie.contains(word: "cut"))
        trie.insert(word: "cut")
        XCTAssertTrue(trie.contains(word: "cut"))
        XCTAssertEqual(trie.count, 4)
    }

    func test_getWord() {
        let trie = Trie()

        // test fetch on empty tree
        let foo = trie.getWord(word: "foo") // not in trie
        XCTAssertNil(foo)

        trie.insert(word: "cute")
        trie.insert(word: "cutest")
        
        // test fetch empty word
        let bar = trie.getWord(word: "")
        XCTAssertNil(bar)

        // test on partial prefix
        let cu = trie.getWord(word: "cu")
        XCTAssertNil(cu)

        let cute = trie.getWord(word: "cute")!
        XCTAssertEqual(cute.count, 4)
        XCTAssertEqual(cute[0].value, "c")
        XCTAssertEqual(cute[1].value, "u")
        XCTAssertEqual(cute[2].value, "t")
        XCTAssertEqual(cute[3].value, "e")
        XCTAssertTrue(cute[3].isTerminating)
        XCTAssertFalse(cute[3].isLeaf)

        let cutest = trie.getWord(word: "cutest")!
        XCTAssertEqual(cutest.count, 6)
        XCTAssertEqual(cutest[0].value, "c")
        XCTAssertEqual(cutest[1].value, "u")
        XCTAssertEqual(cutest[2].value, "t")
        XCTAssertEqual(cutest[3].value, "e")
        XCTAssertEqual(cutest[4].value, "s")
        XCTAssertEqual(cutest[5].value, "t")
        XCTAssertTrue(cutest[5].isTerminating)
        XCTAssertTrue(cutest[5].isLeaf)
    }

    func test_contains() {
        let trie = Trie()
        trie.insert(word: "test")
        trie.insert(word: "another")
        trie.insert(word: "exam")
        let wordsNone = trie.contains(word: "")
        XCTAssertFalse(wordsNone)
        let words = trie.contains(word: "ex")
        XCTAssertFalse(words, "partial matches not supported")
        let noWords = trie.contains(word: "tee")
        XCTAssertFalse(noWords)

        trie.insert(word: "examination")
        let words2 = trie.contains(word: "exam")
        XCTAssertTrue(words2)

        // unicode
        let unicodeWord = "😬😎"
        trie.insert(word: unicodeWord)
        let wordsUnicodePartial = trie.contains(word: "😬")
        XCTAssertFalse(wordsUnicodePartial, "partial matches not supported")
        let wordsUnicode = trie.contains(word: "😬😎")
        XCTAssertTrue(wordsUnicode)

        // case insensitive
        trie.insert(word: "Team")
        let wordsLowerCase = trie.contains(word: "team")
        XCTAssertTrue(wordsLowerCase)
        let wordsUpperCase = trie.contains(word: "TeAm")
        XCTAssertTrue(wordsUpperCase)
    }

    /// Tests the remove method
    func testRemove() {
        let trie = Trie()
        trie.insert(word: "zoo")
        // these share a branch
        trie.insert(word: "cute")
        trie.insert(word: "cuter")
        trie.insert(word: "cutest")
        XCTAssertEqual(trie.count, 4)
        trie.draw()

        // remove empty
        trie.remove(word: "")
        XCTAssertEqual(trie.count, 4)

        // remove a non-existing word
        trie.remove(word: "foo")
        XCTAssertEqual(trie.count, 4)

        // remove by prefix
        trie.remove(word: "cut")
        XCTAssertEqual(trie.count, 4)

        // non-shared branch
        trie.remove(word: "zoo")
        XCTAssertNil(trie.getWord(word: "zoo"))
        XCTAssertFalse(trie.contains(word: "zoo"))
        XCTAssertEqual(trie.count, 3)
        trie.draw()

        // cute is the base for cuter and cutest so its nodes will remain
        // but the isTerminating property will be removed:
        let cute = trie.getWord(word: "cute")!
        let last = cute[3]
        XCTAssertEqual(last.value, "e")
        XCTAssertTrue(last.isTerminating)
        XCTAssertFalse(last.isLeaf, "cuter and cutest share branch")

        trie.remove(word: "cute")
        XCTAssertFalse(trie.contains(word: "cute"))
        XCTAssertTrue(trie.contains(word: "cuter"))
        XCTAssertTrue(trie.contains(word: "cutest"))
        XCTAssertEqual(trie.count, 2)
        XCTAssertNil(trie.getWord(word: "cute"))
        XCTAssertNotNil(trie.getWord(word: "cuter"))
        XCTAssertNotNil(trie.getWord(word: "cutest"))
        let e = trie.getWord(word: "cuter")![3]
        XCTAssertEqual(e.value, "e")
        XCTAssertFalse(e.isTerminating)
        XCTAssertFalse(e.isLeaf)

        trie.draw()
    }

    /// Tests the words property (returns a list of all words in Trie)
    func testWords() {
        let trie = Trie()
        XCTAssertEqual(trie.words.count, 0)

        let insertedWords = ["cute", "cuter", "cutest", "zoo", "zap", "top"]
        insertedWords.map( {trie.insert(word: $0)} )
        XCTAssertEqual(trie.words.count, 6)
        // compare word by word on sorted lists
        let r = zip(insertedWords.sorted(), trie.words.sorted()).allSatisfy({$0 == $1})
        XCTAssertTrue(r)
    }
}
