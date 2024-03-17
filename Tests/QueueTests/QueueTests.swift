//
//  QueueTest.swift
//  
//
//  Created by Christopher Charles Cavnor on 3/7/24.
//

import XCTest
@testable import Queue

// for testing the Queuing of custom types
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

final class QueueTests: XCTestCase {
    
    // test empty queue
    func test_empty() {
        let q = Queue<Int>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        
        XCTAssertEqual(q.peek(), nil)
        XCTAssertEqual(q.pop(), nil)
        XCTAssertFalse(q.contains(-1))
    }

    func test_initFromArray() {
        let arr:[Int] = [8, 2, 10, 9, 7, 5, 2]
        let q = Queue<Int>(array: arr)
        XCTAssertTrue(q.size == 7)
        // compare value-wise: Not that this is LinkedList's iterator,
        // so shows values from head to tail, which is not how you
        // might perceive the internal "order" of a queue.
        _ = zip(q, [8, 2, 10, 9, 7, 5, 2]).map { XCTAssertEqual($0, $1)}
        print(q)
    }

    func test_initFromArrayLiteral() {
        let q: Queue<Int> = [8, 2, 10, 9, 7, 5, 2]
        XCTAssertTrue(q.size == 7)
        // compare value-wise: Not that this is LinkedList's iterator,
        // so shows values from head to tail, which is not how you
        // might perceive the internal "order" of a queue.
        _ = zip(q, [8, 2, 10, 9, 7, 5, 2]).map { XCTAssertEqual($0, $1)}
        print(q)
    }

    // Queues are FIFO - first element in is first one out
    func test_pushPop() throws {
        let q = Queue<Int>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        
        // push
        q.push(1)
        q.push(2)
        q.push(3)
        XCTAssertFalse(q.isEmpty)
        XCTAssertEqual(q.size, 3)
        
        // pop
        XCTAssertEqual(q.pop(), 1)
        XCTAssertEqual(q.size, 2)
        XCTAssertEqual(q.pop(), 2)
        XCTAssertEqual(q.size, 1)
        XCTAssertEqual(q.pop(), 3)
        XCTAssertEqual(q.size, 0)
        
        XCTAssertTrue(q.isEmpty)
    }
    
    func test_peek() {
        let q = Queue<String>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        q.push("this")
        q.push("that")
        XCTAssertEqual(q.size, 2)
        
        XCTAssertEqual(q.peek(), "this")
        XCTAssertEqual(q.size, 2, "peek is non-destructive (element remains in queue)")
    }
    
    func test_contains() {
        let q = Queue<Int>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        q.push(1)
        q.push(2)
        q.push(3)
        q.push(2)
        XCTAssertEqual(q.size, 4, "queues are Bag elements, duplicate values are allowed")
        
        XCTAssertTrue(q.contains(1))
        q.pop()
        XCTAssertFalse(q.contains(1))
        
        XCTAssertTrue(q.contains(2))
        q.pop()
        XCTAssertTrue(q.contains(2), "2 is in queue twice")
        
        XCTAssertTrue(q.contains(3))
        q.pop()
        XCTAssertFalse(q.contains(3))
        
        XCTAssertTrue(q.contains(2))
        q.pop()
        XCTAssertFalse(q.contains(2))
        
        XCTAssertTrue(q.isEmpty)
    }
    
    func test_removeAll() throws {
        var q = Queue<String>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        XCTAssertFalse(q.contains(""))
        
        // push
        q.push("this")
        q.push("that")
        q.push("another")
        XCTAssertFalse(q.isEmpty)
        XCTAssertEqual(q.size, 3)
        
        // removeAll
        q.removeAll()
        XCTAssertTrue(q.isEmpty)
        XCTAssertEqual(q.size, 0)
        XCTAssertFalse(q.contains("this"))
        XCTAssertFalse(q.contains("that"))
        XCTAssertFalse(q.contains("another"))
    }
    
    func test_customType() throws {
        var q = Queue<Thing<String>>()
        XCTAssertTrue(q.isEmpty)
        XCTAssertTrue(q.size == 0)
        
        let t0 = Thing(value: "this")
        let t1 = Thing(value: "that")
        let t2 = Thing(value: "another")
        
        q.push(t0)
        q.push(t1)
        q.push(t2)
        XCTAssertFalse(q.isEmpty)
        XCTAssertEqual(q.size, 3)
        
        XCTAssertTrue(q.contains(t0))
        XCTAssertTrue(q.contains(t1))
        XCTAssertTrue(q.contains(t2))
        
        XCTAssertEqual(q.pop()!.value(), "this")
        XCTAssertEqual(q.pop()!.value(), "that")
        XCTAssertEqual(q.pop()!.value(), "another")
        
        XCTAssertFalse(q.contains(t0))
        XCTAssertFalse(q.contains(t1))
        XCTAssertFalse(q.contains(t2))
        
        XCTAssertTrue(q.isEmpty)
    }
}
