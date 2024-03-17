//
//  LinkedListTests.swift
//
//
//  Created by Christopher Charles Cavnor on 4/10/23.
//

import XCTest
@testable import LinkedList

final class LinkedListTests: XCTestCase {

    let numbers = [8, 2, 10, 9, 7, 5, 2]

    // add numbers to list via append
    fileprivate func buildList() -> LinkedList<Int> {
        let list = LinkedList<Int>()
        for number in numbers {
            list.append(number)
        }
        return list
    }

    // MARK: LinkedListNode

    // test that weak ref of LinkedListNode is working
    func testNodeNotRetained() {
        let node0 = LinkedList.Node(value: 123)
        let node1 = LinkedList.Node(value: 500)

        node0.next = node1
        node1.previous = node0

        addTeardownBlock { [weak node0] in
            // nodes would not be deallocated unless weak ref was used
            // to break next <-> previous strong refs
            XCTAssertNil(node0)
            XCTAssertNotNil(node1)
        }
    }

    // MARK: LinkedList - Init
    func testInitEmpty() {
        let list = LinkedList<Int>()
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
    }

    func testInitArray() {
        let arr = [1.1, 2.2, 3.3, 0.4]
        let list = LinkedList(array: arr)

        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.size, 4)

        XCTAssertNotNil(list.head)
        XCTAssertNil(list.head!.previous)
        XCTAssertEqual(list.head!.value, 1.1)

        XCTAssertNotNil(list.tail)
        XCTAssertNotNil(list.tail!.previous)
        XCTAssertNil(list.tail!.next)
        XCTAssertEqual(list.tail!.value, 0.4)
    }

    func testArrayLiteralInitTypeInfer() {
        let arrayLiteralInitInfer: LinkedList = [1.0, 2.0, 3.0]

        XCTAssertEqual(arrayLiteralInitInfer.size, 3)
        XCTAssertEqual(arrayLiteralInitInfer.head?.value, 1.0)
        XCTAssertEqual(arrayLiteralInitInfer.tail?.value, 3.0)
        XCTAssertEqual(arrayLiteralInitInfer[1], 2.0)
    }

    func testArrayLiteralInitExplicit() {
        let arrayLiteralInitExplicit: LinkedList<Int> = [1, 2, 3]

        XCTAssertEqual(arrayLiteralInitExplicit.size, 3)
        XCTAssertEqual(arrayLiteralInitExplicit.head?.value, 1)
        XCTAssertEqual(arrayLiteralInitExplicit.tail?.value, 3)
        XCTAssertEqual(arrayLiteralInitExplicit[1], 2)
    }

    // MARK: LinkedList - Contains
    func testContains() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        for i in 0 ..< list.size {
            XCTAssertTrue(list.contains(value: numbers[i]))
        }
        // test non-existing value
        XCTAssertFalse(list.contains(value: 99))
    }

    // MARK: LinkedList - Subscript
    func testSubscript() {
        // fetch from empty list
        let empty = LinkedList<Int>()
        XCTAssertNil(empty[0])

        // test expected range
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        for i in 0 ..< list.size {
            XCTAssertEqual(list[i], numbers[i])
        }
        XCTAssertEqual(list[0], list.head!.value)
        XCTAssertEqual(list[6], list.tail!.value)

        // test index outside range
        XCTAssertNil(list[10])
    }

    // MARK: LinkedList - Append
    func testAppendByValue() {
        let list = LinkedList<Int>()
        list.append(123)
        list.append(456)

        XCTAssertEqual(list.size, 2)

        XCTAssertNotNil(list.head)
        XCTAssertEqual(list.head!.value, 123)

        XCTAssertNotNil(list.tail)
        XCTAssertEqual(list.tail!.value, 456)

        XCTAssertTrue(list.head !== list.tail)

        XCTAssertNil(list.head!.previous)
        XCTAssertTrue(list.head!.next === list.tail)
        XCTAssertTrue(list.tail!.previous === list.head)
        XCTAssertNil(list.tail!.next)
    }

    func testAppendByNode() {
        let list = LinkedList<Int>()
        list.append(LinkedListNode(value: 123))
        list.append(LinkedListNode(value: 456))

        XCTAssertEqual(list.size, 2)

        XCTAssertNotNil(list.head)
        XCTAssertEqual(list.head!.value, 123)

        XCTAssertNotNil(list.tail)
        XCTAssertEqual(list.tail!.value, 456)

        XCTAssertTrue(list.head !== list.tail)

        XCTAssertNil(list.head!.previous)
        XCTAssertTrue(list.head!.next === list.tail)
        XCTAssertTrue(list.tail!.previous === list.head)
        XCTAssertNil(list.tail!.next)
    }

    func testAppendList() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let list2 = LinkedList<Int>()
        list2.append(99)
        list2.append(102)
        list.append(list2)
        XCTAssertTrue(list.size == 9)
        XCTAssertEqual(list[5], 5)
        XCTAssertEqual(list[7], 99)
        XCTAssertEqual(list[8], 102)
        XCTAssertNil(list[9])
    }

    func testAppendListToEmptyList() {
        let list = LinkedList<Int>()
        let list2 = LinkedList<Int>()
        list2.append(5)
        list2.append(10)
        list.append(list2)
        XCTAssertTrue(list.size == 2)
        XCTAssertEqual(list[0], 5)
        XCTAssertEqual(list[1], 10)
        XCTAssertNil(list[2])
    }

    // MARK: LinkedList - INSERT
    func testInsertAtIndexInEmptyList() {
        let list = LinkedList<Int>()
        list.insert(123, at: 0)

        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.size, 1)

        let node = list.head
        XCTAssertNotNil(node)
        XCTAssertEqual(node!.value, 123)

        XCTAssertTrue(node === list.tail)
    }

    func testInsertAtInvalidIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        list.insert(123, at: 100)

        XCTAssertFalse(list.isEmpty)
        XCTAssertEqual(list.size, 7)
        XCTAssertFalse(list.contains(value: 123))

        let last = try! list.node(at: 6)
        XCTAssertTrue(last === list.tail)
    }

    func testInsertAtIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let prev = try! list.node(at: 2) // 10
        let next = try! list.node(at: 3) // 9
        let nodeCount = list.size

        list.insert(444, at: 3) // [8, 2, 10, 444, 9, 7, 5, 2]

        let node = try! list.node(at: 3) // 444
        XCTAssertNotNil(node)
        XCTAssertEqual(node.value, 444)
        XCTAssertEqual(nodeCount + 1, list.size)

        XCTAssertFalse(prev === node)
        XCTAssertFalse(next === node)
        XCTAssertTrue(prev.next === node)
        XCTAssertTrue(next.previous === node)

        XCTAssertFalse(node === list.tail)
        let last = try! list.node(at: 7)
        XCTAssertTrue(last === list.tail)
    }

    func testInsertAtTailIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let prev = try! list.node(at: 6) // 2
        let nodeCount = list.size
        XCTAssertEqual(nodeCount, 7)

        list.insert(444, at: 7) // [8, 2, 10, 9, 7, 5, 2, 444]
        let node = try! list.node(at: 7)
        XCTAssertNotNil(node)
        XCTAssertEqual(node.value, 444)
        XCTAssertEqual(nodeCount + 1, list.size)

        XCTAssertFalse(prev === node)
        XCTAssertNil(node.next)
        XCTAssertTrue(prev.next === node)
        XCTAssertTrue(node.previous === prev)
        XCTAssertTrue(node === list.tail)
    }

    func testInsertListAtIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let list2 = LinkedList<Int>()
        list2.append(99)
        list2.append(102)
        list.insert(list2, at: 2) // [8, 2, 99, 102, 10, 9, 7, 5, 2]
        XCTAssertTrue(list.size == 9)
        XCTAssertEqual(try! list.node(at: 1).value, 2)
        XCTAssertEqual(try! list.node(at: 2).value, 99)
        XCTAssertEqual(try! list.node(at: 3).value, 102)
        XCTAssertEqual(try! list.node(at: 4).value, 10)

        XCTAssertEqual(list.head!.value, 8)
        XCTAssertEqual(list.tail!.value, 2)

        print(list)
    }

    func testInsertListAtFirstIndex() {
        let list = buildList()
        let list2 = LinkedList<Int>()
        list2.append(99)
        list2.append(102)
        list.insert(list2, at: 0) // [99, 102, 8, 2, 10, 9, 7, 5, 2]
        print(list)
        XCTAssertTrue(list.size == 9)
        XCTAssertEqual(try! list.node(at: 0).value, 99)
        XCTAssertEqual(try! list.node(at: 1).value, 102)
        XCTAssertEqual(try! list.node(at: 2).value, 8)

        XCTAssertEqual(list.head!.value, 99)
        XCTAssertEqual(list.tail!.value, 2)
    }

    func testInsertListAtLastIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let list2 = LinkedList<Int>()
        list2.append(99)
        list2.append(102)
        list.insert(list2, at: list.size) // [8, 2, 10, 9, 7, 5, 2, 99, 102]
        XCTAssertTrue(list.size == 9)
        XCTAssertEqual(try! list.node(at: 6).value, 2)
        XCTAssertEqual(try! list.node(at: 7).value, 99)
        XCTAssertEqual(try! list.node(at: 8).value, 102)

        XCTAssertEqual(list.head!.value, 8)
        XCTAssertEqual(list.tail!.value, 102)
    }


    // MARK: LinkedList - REMOVE
    func testRemoveAtIndexOnEmptyList() {
        let list = LinkedList<Int>()
        XCTAssertEqual(list.head, list.tail)

        let value = list.remove(at: 0)
        XCTAssertNil(value)

        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
    }

    func testRemoveAtIndexOnListWithOneElement() {
        let list = LinkedList<Int>()
        list.append(123)
        XCTAssertEqual(list.head, list.tail)
        XCTAssertEqual(list.tail?.value, 123)

        let value = list.remove(at: 0)
        XCTAssertEqual(value, 123)

        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
    }

    func testRemoveAtIndex() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let prev = try! list.node(at: 2) // 10
        let next = try! list.node(at: 3) // 9
        let nodeCount = list.size

        list.insert(444, at: 3) // [8, 2, 10, 444, 9, 7, 5, 2]

        let value = list.remove(at: 3)
        XCTAssertEqual(value, 444)

        let node = try! list.node(at: 3)
        XCTAssertEqual(node.value, 9)
        XCTAssertTrue(next === node)
        XCTAssertTrue(prev.next === node)
        XCTAssertTrue(node.previous === prev)
        XCTAssertEqual(nodeCount, list.size)

        XCTAssertEqual(8, list.head?.value)
        XCTAssertEqual(2, list.tail?.value)
    }

    func testRemoveAtIndexHeadTail() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let head_next = try! list.node(at: 1) // 2
        let tail_prev = try! list.node(at: 5) // 5
        let nodeCount = list.size

        XCTAssertEqual(head_next.value, 2)
        XCTAssertEqual(tail_prev.value, 5)

        XCTAssertEqual(head_next.previous, list.head)
        XCTAssertEqual(tail_prev.next, list.tail)

        // remove head
        let headv = list.remove(at: 0)
        XCTAssertEqual(headv, 8)
        XCTAssertEqual(head_next, list.head)
        XCTAssertEqual(nodeCount-1, list.size)
        XCTAssertEqual(tail_prev.next, list.tail)

        // remove tail
        let tailv = list.remove(at: list.size-1)
        XCTAssertEqual(tailv, 2)
        XCTAssertEqual(tail_prev, list.tail)
        XCTAssertEqual(nodeCount-2, list.size)
    }

    func testRemoveLastOnEmptyList() {
        let list = LinkedList<Int>()

        let value = list.removeLast()
        XCTAssertNil(value)

        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
    }

    func testRemoveLastOnListWithOneElement() {
        let list = LinkedList<Int>()
        list.append(123)

        let value = list.removeLast()
        XCTAssertEqual(value, 123)

        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)
    }

    func testRemoveLast() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let last = list.tail
        let prev = last!.previous
        let nodeCount = list.size

        let value = list.removeLast() // 2: [8, 2, 10, 9, 7, 5]
        XCTAssertEqual(value, 2)

        XCTAssertNil(last!.previous)
        XCTAssertNil(last!.next)

        // prev is new tail
        XCTAssertNil(prev!.next)
        XCTAssertTrue(list.tail === prev)

        XCTAssertEqual(nodeCount - 1, list.size)
    }

    func testRemoveAll() {
        let list = buildList()
        weak var node = try! list.node(at: 3)
        XCTAssertNotNil(node, "used to test for held reference after removeAll")

        list.removeAll()
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(list.size, 0)
        XCTAssertNil(list.head)
        XCTAssertNil(list.tail)

        XCTAssertNil(node, "deferenced and collected after removeAll")
    }


    // MARK: LinkedList - COLLECTION CONFORMANCE
    func testAsCollectionEmpty() {
        let collection = LinkedList<Int>()

        // count and first are collection funcs
        XCTAssertEqual(collection.count, 0)
        XCTAssertEqual(collection.first, nil)
    }

    func testAsCollection() {
        let collection: LinkedList<Int> = [1, 2, 3, 4, 5, 2]
        let firsti = collection.index(collection.startIndex, offsetBy: 0)
        let lasti = collection.index(collection.startIndex, offsetBy: collection.count-1)
        let index2 = collection.index(collection.startIndex, offsetBy: 1)

        // count and first are collection funcs
        XCTAssertEqual(collection.count, 6)
        XCTAssertEqual(collection.first, 1)

        // indeces
        XCTAssertEqual(collection[firsti], 1)
        XCTAssertEqual(collection[lasti], 2)
        XCTAssertEqual(collection.firstIndex(of: 2), index2)
        XCTAssertNil(collection.firstIndex(of: 7), "not in collection")
        // this will halt program at Collection subscript function
        // XCTAssertThrowsError(collection[collection.index(after: lasti)])

        // other collection funcs
        XCTAssertTrue(collection.contains(value: 1))
        let d = collection.dropFirst()
        XCTAssertEqual(d.count, 5)
        XCTAssertFalse(d.contains(1))
    }

    // MARK: LinkedList - MAP & FILTER & REDUCE
    func testMap() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]
        let r = list.map(transform: { $0 * 2 }) // [16, 4, 20, 18, 14, 10, 4]
        _ = zip(list, r).map { XCTAssertEqual(2*$0, $1)}
    }

    func testFilter() {
        let list = buildList() // [8, 2, 10, 9, 7, 5, 2]

        // non-existing element
        let zed = list.filter(predicate: {$0 == 4})
        XCTAssertTrue(zed.isEmpty)
        // single match
        let one = list.filter(predicate: {$0 == 10})
        XCTAssertEqual(one.size, 1)
        XCTAssertEqual(one.head?.value, 10)
        // two matches
        let two = list.filter(predicate: {$0 == 2})
        XCTAssertEqual(two.size, 2)
        XCTAssertEqual(two.head?.value, 2)
        XCTAssertEqual(two.tail?.value, 2)

        // test string
        let list_string = LinkedList<String>()
        list_string.append("this")
        list_string.append("that")
        list_string.append("other")
        list_string.append("something")

        let s = list_string.filter(predicate: {$0 == "other"})
        XCTAssertEqual(s.count, 1)
        XCTAssertEqual(s.head?.value, "other")
    }

    func testReduce() {
        // test numeric
        let list = LinkedList<Int>()
        list.append(0)
        list.append(2)
        list.append(4)
        list.append(1)
        list.append(0)

        XCTAssertEqual(7, list.reduce(+))
        XCTAssertEqual(-7, list.reduce(-))
        XCTAssertEqual(0, list.reduce(min))
        XCTAssertEqual(4, list.reduce(max))

        // test string
        let list_string = LinkedList<String>()
        list_string.append("this")
        list_string.append("that")
        list_string.append("other")
        list_string.append("something")

        XCTAssertEqual("thisthatothersomething", list_string.reduce(+))
        // longest string
        XCTAssertEqual("something", list_string.reduce({
            current, element in
            if current.count > element.count {
                return current
            } else {
                return element
            }
        }))
    }

}
