//
//  StackTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 5/6/22.
//

import XCTest
import ValueBasedStack

class StackTests: XCTestCase {

    func makeStack() -> ValueBasedStack<Int> {
        var stack: ValueBasedStack = ValueBasedStack<Int>()
        stack = stack.push(8)
        stack = stack.push(5)
        stack = stack.push(10)
        stack = stack.push(-1)
        return stack
    }

    func test_ValueBasedStack_push_pop() {
        var stack = makeStack()
        print(">>> \(stack)")
        XCTAssertEqual(4, stack.size)

        // pop returns the popped element and the rest of the stack
        while let (element, rest) = stack.pop() {
            print(">>> next is \(element)")
            stack = rest
        }
        XCTAssertEqual(0, stack.size, "stack is now empty")
    }

    func test_ValueBasedStack_first() {
        let stack = makeStack()
        XCTAssertEqual(4, stack.size)
        // get the first inserted element
        let first = stack.first()
        XCTAssertEqual(8, first, "first element in stack")
        XCTAssertEqual(4, stack.size, "stack size not changed")
    }

    func test_ValueBasedStack_toArray() {
        var stack: ValueBasedStack = ValueBasedStack<Int>()
        XCTAssertEqual(stack.toArray, [])
        stack = makeStack()
        XCTAssertEqual(stack.toArray, [-1,10,5,8])
    }

}
