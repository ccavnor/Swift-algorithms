//
//  StackTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 5/6/22.
//

import XCTest
import ValueBasedStack

class StackTests: XCTestCase {

    let inserts: [Int] = [8,5,10,-1]
    func makeStack() -> ValueBasedStack<Int> {
        var stack: ValueBasedStack = ValueBasedStack<Int>()
        for i in inserts {
            stack = stack.push(i)
        }
        return stack
    }

    func test_empty() {
        var stack: ValueBasedStack = ValueBasedStack<Int>()
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(0, stack.size)
    }

    func test_ValueBasedStack_push_pop_peek() {
        var stack = makeStack()
        print(">>> \(stack)")
        XCTAssertEqual(4, stack.size)

        for i in inserts.reversed() {
            XCTAssertEqual(i, stack.peek())
            // pop returns the popped element and the rest of the stack
            var (element, rest) = stack.pop()!
            print(">>> next is \(element), rest is \(rest)")
            XCTAssertEqual(i, element)
            stack = rest
        }

        // empty
        XCTAssertTrue(stack.isEmpty)
        XCTAssertEqual(0, stack.size)
    }

    func test_contains() {
        var stack = makeStack()
        for i in inserts {
            XCTAssertTrue(stack.contains(i))
        }
        XCTAssertFalse(stack.contains(100))
    }

    func test_ValueBasedStack_toArray() {
        var stack: ValueBasedStack = ValueBasedStack<Int>()
        XCTAssertEqual(stack.toArray, [])
        stack = makeStack()
        XCTAssertEqual(stack.toArray, [-1,10,5,8])
    }

}
