//
//  StackTests.swift
//
//
//  Created by Christopher Charles Cavnor on 3/17/24.
//

import XCTest
@testable import Stack

// for testing the Stacking of custom types
fileprivate enum Thing<T: Comparable>: Comparable {
    case node(T)

    public init(value: T) {
        self = .node(value)
    }

    public func value() -> T? {
        var first: T?

        if case let .node(v) = self {
            first = v
        }
        return first
    }
}

final class StackTests: XCTestCase {

    // test empty queue
    func test_empty() {
        let s = Stack<Int>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)

        XCTAssertEqual(s.peek(), nil)
        XCTAssertEqual(s.pop(), nil)
        XCTAssertFalse(s.contains(-1))
    }

    func test_initFromArray() {
        let arr:[Int] = [8, 2, 10, 9, 7, 5, 2]
        let s = Stack<Int>(array: arr)
        XCTAssertTrue(s.size == 7)
        // compare value-wise: Not that this is LinkedList's iterator,
        // so shows values from head to tail, which is not how you
        // might perceive the internal "order" of a stack.
        _ = zip(s, arr).map { XCTAssertEqual($0, $1)}
        print(s)
    }

    func test_initFromArrayLiteral() {
        let s: Stack<Int> = [8, 2, 10, 9, 7, 5, 2]
        XCTAssertTrue(s.size == 7)
        // compare value-wise: Not that this is LinkedList's iterator,
        // so shows values from head to tail, which is not how you
        // might perceive the internal "order" of a stack.
        _ = zip(s, [8, 2, 10, 9, 7, 5, 2]).map { XCTAssertEqual($0, $1)}
        print(s)
    }

    // Stacks are LIFO - first element in is last one out
    func test_pushPop() throws {
        let s = Stack<Int>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)

        // push
        s.push(1)
        s.push(2)
        s.push(3)
        XCTAssertFalse(s.isEmpty)
        XCTAssertEqual(s.size, 3)

        // pop
        XCTAssertEqual(s.pop(), 3)
        XCTAssertEqual(s.size, 2)
        XCTAssertEqual(s.pop(), 2)
        XCTAssertEqual(s.size, 1)
        XCTAssertEqual(s.pop(), 1)
        XCTAssertEqual(s.size, 0)

        XCTAssertTrue(s.isEmpty)
    }

    func test_peek() {
        let s = Stack<String>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)
        s.push("this")
        s.push("that")
        XCTAssertEqual(s.size, 2)

        XCTAssertEqual(s.peek(), "that")
        XCTAssertEqual(s.size, 2, "peek is non-destructive (element remains in stack)")
    }

    func test_contains() {
        let s = Stack<Int>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)
        s.push(1)
        s.push(2)
        s.push(3)
        s.push(2)
        XCTAssertEqual(s.size, 4, "queues are Bag elements, duplicate values are allowed")

        XCTAssertTrue(s.contains(2))
        s.pop()
        XCTAssertTrue(s.contains(2), "2 is in queue twice")

        XCTAssertTrue(s.contains(3))
        s.pop()
        XCTAssertFalse(s.contains(3))

        XCTAssertTrue(s.contains(2))
        s.pop()
        XCTAssertFalse(s.contains(2))

        XCTAssertTrue(s.contains(1))
        s.pop()
        XCTAssertFalse(s.contains(1))

        XCTAssertTrue(s.isEmpty)
    }

    func test_removeAll() throws {
        let s = Stack<String>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)
        XCTAssertFalse(s.contains(""))

        // push
        s.push("this")
        s.push("that")
        s.push("another")
        XCTAssertFalse(s.isEmpty)
        XCTAssertEqual(s.size, 3)

        // removeAll
        s.removeAll()
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.size, 0)
        XCTAssertFalse(s.contains("this"))
        XCTAssertFalse(s.contains("that"))
        XCTAssertFalse(s.contains("another"))
    }

    func test_customType() throws {
        let s = Stack<Thing<String>>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertTrue(s.size == 0)

        let t0 = Thing(value: "this")
        let t1 = Thing(value: "that")
        let t2 = Thing(value: "another")

        s.push(t0)
        s.push(t1)
        s.push(t2)
        XCTAssertFalse(s.isEmpty)
        XCTAssertEqual(s.size, 3)

        XCTAssertTrue(s.contains(t0))
        XCTAssertTrue(s.contains(t1))
        XCTAssertTrue(s.contains(t2))

        XCTAssertEqual(s.pop()!.value(), "another")
        XCTAssertEqual(s.pop()!.value(), "that")
        XCTAssertEqual(s.pop()!.value(), "this")

        XCTAssertFalse(s.contains(t0))
        XCTAssertFalse(s.contains(t1))
        XCTAssertFalse(s.contains(t2))

        XCTAssertTrue(s.isEmpty)
    }

}
