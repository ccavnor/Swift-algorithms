//
//  HeapTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 3/17/24.
//

import XCTest
@testable import Heap

final class HeapTests: XCTestCase {

    func test_HeapNode() {
        let pNode = HeapNode(value: 1)
        let lNode = HeapNode(value: 2)
        let rNode = HeapNode(value: 3)

        pNode.left = lNode
        pNode.right = rNode
        lNode.parent = pNode
        rNode.parent = pNode

        // root node
        XCTAssertEqual(pNode.value, 1)
        XCTAssertEqual(pNode.left?.value, 2)
        XCTAssertEqual(pNode.right?.value, 3)
        XCTAssertTrue(pNode.isRoot)
        XCTAssertFalse(pNode.isLeaf)
        XCTAssertFalse(pNode.isLeftChild)
        XCTAssertFalse(pNode.isRightChild)
        XCTAssertTrue(pNode.hasAnyChild)
        XCTAssertTrue(pNode.hasBothChildren)
        XCTAssertTrue(pNode.hasLeftChild)
        XCTAssertTrue(pNode.hasRightChild)

        // left node
        XCTAssertEqual(lNode.value, 2)
        XCTAssertEqual(lNode.parent?.value, 1)
        XCTAssertFalse(lNode.isRoot)
        XCTAssertTrue(lNode.isLeaf)
        XCTAssertTrue(lNode.isLeftChild)
        XCTAssertFalse(lNode.isRightChild)
        XCTAssertFalse(lNode.hasAnyChild)
        XCTAssertFalse(lNode.hasBothChildren)
        XCTAssertFalse(lNode.hasLeftChild)
        XCTAssertFalse(lNode.hasRightChild)

        // right node
        XCTAssertEqual(rNode.value, 3)
        XCTAssertEqual(rNode.parent?.value, 1)
        XCTAssertFalse(rNode.isRoot)
        XCTAssertTrue(rNode.isLeaf)
        XCTAssertFalse(rNode.isLeftChild)
        XCTAssertTrue(rNode.isRightChild)
        XCTAssertFalse(rNode.hasAnyChild)
        XCTAssertFalse(rNode.hasBothChildren)
        XCTAssertFalse(rNode.hasLeftChild)
        XCTAssertFalse(rNode.hasRightChild)

        print(pNode)
    }

    // base class of Heap has init that requires a sort order func
    func testInitHeapByArray() {
        var arr = [Int]()
        arr.append(2)
        arr.append(1)
        arr.append(3)

        // init as min-heap
        let heapMin = Heap(array: arr, sort: <)
        XCTAssertEqual(heapMin.size, 3)
        XCTAssertEqual(heapMin.peek(), 1)

        let heapMax = Heap(array: arr, sort: >)
        XCTAssertEqual(heapMax.size, 3)
        XCTAssertEqual(heapMax.peek(), 3)
    }

    func testMinHeapInitFromArray() {
        var arr = [Int]()
        arr.append(2)
        arr.append(1)
        arr.append(3)

        // init as min-heap
        let heapMin = MinHeap(array: arr)
        XCTAssertEqual(heapMin.size, 3)
        XCTAssertEqual(heapMin.peek(), 1)
    }

    func testMaxHeapInitFromArray() {
        var arr = [Int]()
        arr.append(2)
        arr.append(1)
        arr.append(3)

        // init as max-heap
        let heapMax = MaxHeap(array: arr)
        XCTAssertEqual(heapMax.size, 3)
        XCTAssertEqual(heapMax.peek(), 3)
    }

    func testMinHeapInitFromArrayLiteral() {
        // init as min-heap
        let heapMin: MinHeap<Int> = [1, 2, 3, 4, 5, 2]
        XCTAssertEqual(heapMin.size, 6)
        XCTAssertEqual(heapMin.peek(), 1)
        print(heapMin)
    }

    func testMaxHeapInitFromArrayLiteral() {
        // init as max-heap
        let heapMax: MaxHeap<Int> = [1, 2, 3, 4, 5, 2]
        XCTAssertEqual(heapMax.size, 6)
        XCTAssertEqual(heapMax.peek(), 5)
        print(heapMax)
    }

    // nextAvailableNode gets the rightmost slot of the leaf nodes
    // that will accept the next element. It's not simply the last
    // element added, since bubble-ups occur upon insertions that
    // maintain the heap constraint.
    func testPush() { // insert // [3,1,5,2,7,10,-3,14]
        let heap = Heap<Int>(sort: >) // max heap
        heap.push(3)
        XCTAssertEqual(heap.nextAvailableNode?.value, 3)
        XCTAssertEqual(heap.peek(), 3)

        heap.push(1)
        XCTAssertEqual(heap.nextAvailableNode?.value, 1)
        XCTAssertEqual(heap.peek(), 3)

        // bubble-up to set 3 as top of heap
        heap.push(5)
        XCTAssertEqual(heap.peek(), 5)
        XCTAssertEqual(heap.nextAvailableNode?.value, 3)

        heap.push(2)
        XCTAssertEqual(heap.peek(), 5)
        XCTAssertEqual(heap.nextAvailableNode?.value, 1)

        heap.push(7)
        XCTAssertEqual(heap.peek(), 7)
        XCTAssertEqual(heap.nextAvailableNode?.value, 2)

        heap.push(10)
        XCTAssertEqual(heap.peek(), 10)
        XCTAssertEqual(heap.nextAvailableNode?.value, 3)

        heap.push(-3)
        XCTAssertEqual(heap.peek(), 10)
        XCTAssertEqual(heap.nextAvailableNode?.value, -3)

        heap.push(14)
        XCTAssertEqual(heap.peek(), 14)
        XCTAssertEqual(heap.nextAvailableNode?.value, 1)

        print(heap)
    }

    func testPop() { // [3,1,5,2,7,10,-3,14]
        // base Heap as a max heap via individual pushes
        let heap = Heap<Int>(sort: >) // max heap
        heap.push(3)
        heap.push(1)
        heap.push(5)
        heap.push(2)
        heap.push(7)
        heap.push(10)
        heap.push(-3)
        heap.push(14)
        print(heap)

        XCTAssertEqual(heap.pop(), 14)
        XCTAssertEqual(heap.pop(), 10)
        XCTAssertEqual(heap.pop(), 7)
        XCTAssertEqual(heap.pop(), 5)
        XCTAssertEqual(heap.pop(), 3)
        XCTAssertEqual(heap.pop(), 2)
        XCTAssertEqual(heap.pop(), 1)
        XCTAssertEqual(heap.pop(), -3)
        XCTAssertTrue(heap.isEmpty)
        XCTAssertTrue(heap.size == 0)
        XCTAssertNil(heap.pop())

        // MaxHeap init via array literal
        let maxHeap: MaxHeap<Int> = [3,1,5,2,7,10,-3,14] // max heap
        print(maxHeap)

        XCTAssertEqual(maxHeap.pop(), 14)
        XCTAssertEqual(maxHeap.pop(), 10)
        XCTAssertEqual(maxHeap.pop(), 7)
        XCTAssertEqual(maxHeap.pop(), 5)
        XCTAssertEqual(maxHeap.pop(), 3)
        XCTAssertEqual(maxHeap.pop(), 2)
        XCTAssertEqual(maxHeap.pop(), 1)
        XCTAssertEqual(maxHeap.pop(), -3)
        XCTAssertTrue(maxHeap.isEmpty)
        XCTAssertTrue(maxHeap.size == 0)
        XCTAssertNil(maxHeap.pop())

        // MinHeap init via array literal
        let minHeap: MinHeap<Int> = [3,1,5,2,7,10,-3,14] // min heap
        print(minHeap)

        XCTAssertEqual(minHeap.pop(), -3)
        XCTAssertEqual(minHeap.pop(), 1)
        XCTAssertEqual(minHeap.pop(), 2)
        XCTAssertEqual(minHeap.pop(), 3)
        XCTAssertEqual(minHeap.pop(), 5)
        XCTAssertEqual(minHeap.pop(), 7)
        XCTAssertEqual(minHeap.pop(), 10)
        XCTAssertEqual(minHeap.pop(), 14)
        XCTAssertTrue(minHeap.isEmpty)
        XCTAssertTrue(minHeap.size == 0)
        XCTAssertNil(minHeap.pop())
    }

    func testInterdigitatedPushAndPop() {
        let maxHeap: MaxHeap<Int> = [3,1,5]
        print(maxHeap)
        XCTAssertEqual(maxHeap.pop(), 5)
        maxHeap.push(0)
        maxHeap.push(10)
        print(maxHeap)
        XCTAssertEqual(maxHeap.pop(), 10)
        print(maxHeap)
    }

    // push a value to the heap and retreive the new top element (after heapify)
    func test_pushPop() {
        // from empty heap
        let heap = Heap<Int>(sort: >)
        XCTAssertTrue(heap.isEmpty)
        var r = heap.pushPop(0)
        XCTAssertEqual(r, 0)
        XCTAssertEqual(heap.peek(), 0)
        XCTAssertTrue(heap.size == 1)
        r = heap.pushPop(1)
        XCTAssertEqual(r, 1)
        XCTAssertEqual(heap.peek(), 1)
        XCTAssertTrue(heap.size == 1)
        print(heap)

        // ===== min heap =========
        let minHeap: MinHeap<Int> = [3,1,5,2,7,10,-3,14] // min heap
        print(minHeap)
        // test where element < root
        r = minHeap.pushPop(-5)
        XCTAssertEqual(r, -5)
        XCTAssertEqual(minHeap.peek(), -5, "pushed value < root in min-heap so no bubble down")
        print(minHeap)

        // test where element > root (will bubble down)
        r = minHeap.pushPop(22)
        XCTAssertEqual(r, 1)
        XCTAssertEqual(minHeap.peek(), 1, "pushed value > root in min-heap so will bubble down")
        print(minHeap)

        // ===== max heap =========
        let maxHeap: MaxHeap<Int> = [3,1,5,2,7,10,-3,14] // max heap
        print(maxHeap)
        // test where element > root
        r = maxHeap.pushPop(55)
        XCTAssertEqual(r, 55)
        XCTAssertEqual(maxHeap.peek(), 55, "pushed value > root in max-heap so no bubble down")
        print(maxHeap)

        // test where element < root (will bubble down)
        r = maxHeap.pushPop(2)
        XCTAssertEqual(r, 10)
        XCTAssertEqual(maxHeap.peek(), 10, "pushed value < root in max-heap so will bubble down")
        print(maxHeap)
    }

    // pop the top element from the heap and push a new value (will heapify for next call)
    func test_popPush() {
        // from empty heap
        let heap = Heap<Int>(sort: >)
        XCTAssertTrue(heap.isEmpty)
        var r = heap.popPush(0)
        XCTAssertEqual(r, nil)
        XCTAssertEqual(heap.peek(), 0)
        XCTAssertTrue(heap.size == 1)

        // replace 0 with 1
        r = heap.popPush(1)
        XCTAssertEqual(r, 0)
        XCTAssertEqual(heap.peek(), 1)
        XCTAssertTrue(heap.size == 1)
        print(heap)

        // ===== min heap =========
        let minHeap: MinHeap<Int> = [3,1,5,2,7,10,-3,14] // min heap
        // test where element < root
        r = minHeap.popPush(-5)
        XCTAssertEqual(r, -3)
        XCTAssertEqual(minHeap.peek(), -5, "pushed value < root in min-heap so no bubble down")

        // test where element > root (will bubble down)
        r = minHeap.popPush(22)
        XCTAssertEqual(r, -5)
        XCTAssertEqual(minHeap.peek(), 1, "pushed value > root in min-heap so will bubble down")

        // ===== max heap =========
        let maxHeap: MaxHeap<Int> = [3,1,5,2,7,10,-3,14] // max heap
        // test where element > root
        r = maxHeap.popPush(55)
        XCTAssertEqual(r, 14)
        XCTAssertEqual(maxHeap.peek(), 55, "pushed value > root in max-heap so no bubble down")

        // test where element < root (will bubble down)
        print(maxHeap)
        r = maxHeap.popPush(2)
        XCTAssertEqual(r, 55)
        XCTAssertEqual(maxHeap.peek(), 10, "pushed value < root in max-heap so will bubble down")
        print(maxHeap)
    }

    // test min/max heap for string values
    func test_alphaHeap2() {
        let minHeap: MinHeap<String> = ["here","is","a","few","words"] // min heap
        print(minHeap)
        XCTAssertEqual(minHeap.pop(), "a")
        XCTAssertEqual(minHeap.pop(), "few")
        XCTAssertEqual(minHeap.pop(), "here")
        XCTAssertEqual(minHeap.pop(), "is")
        XCTAssertEqual(minHeap.pop(), "words")

        let maxHeap: MaxHeap<String> = ["here","is","a","few","words"] // max heap
        print(maxHeap)
        XCTAssertEqual(maxHeap.pop(), "words")
        XCTAssertEqual(maxHeap.pop(), "is")
        XCTAssertEqual(maxHeap.pop(), "here")
        XCTAssertEqual(maxHeap.pop(), "few")
        XCTAssertEqual(maxHeap.pop(), "a")
    }

    func test_removeAll() {
        let heap = Heap<Int>(sort: >=) // max heap
        XCTAssertNil(heap.pop())

        heap.push(1)
        heap.push(2)
        heap.push(3)
        XCTAssertEqual(heap.size, 3)

        heap.removeAll()
        XCTAssertEqual(heap.size, 0)
        XCTAssertTrue(heap.isEmpty)
        XCTAssertNil(heap.peek())

        print(heap)
    }


}
