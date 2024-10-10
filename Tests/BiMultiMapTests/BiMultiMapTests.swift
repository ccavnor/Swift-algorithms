//
//  BiMultiMapTests.swift
//  ccavnor-swift-collections
//
//  Created by Christopher Charles Cavnor on 10/10/24.
//

import XCTest
@testable import BiMultiMap

final class BiMultiMapTests: XCTestCase {

    // init(_ dict:[H:T] = [:])
    func testDictInit() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["one", "two", "three"]] )
        XCTAssertEqual(mm.forward, [1:["A","B","C"], 2:["one", "two", "three"]])
        XCTAssertTrue(mm.count == 2)
    }

    // init(_ values:[(H,T)])
    func testValuesInit() {
        var mm = BiMultiMap([(1, ["A","B","C"]), (2, ["one", "two", "three"])])
        XCTAssertEqual(mm.forward, [1:["A","B","C"], 2:["one", "two", "three"]])
        XCTAssertTrue(mm.count == 2)
    }

    func testInitEmpty() {
        var mm = BiMultiMap<Int, String>()
        XCTAssertTrue(mm.count == 0)
        XCTAssertEqual(mm.forward, [:])
    }

    func testInitEmptyAndBuild() {
        var mm = BiMultiMap<Int, String>()
        XCTAssertTrue(mm.count == 0)
        XCTAssertEqual(mm.forward, [:])
        mm[0] = ["zero"]
        mm[1] = ["one", "uno"]
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm[0], ["zero"])
        XCTAssertEqual(mm[1], ["one", "uno"])
        XCTAssertEqual(mm.backward["zero"], [0])
        XCTAssertEqual(mm.backward["one"], [1])
        XCTAssertEqual(mm.backward["uno"], [1])
        XCTAssertTrue(mm.count == 3)
    }

    func testAddValuesToExistingKeysForward() {
        var mm = BiMultiMap<Int, String>()
        XCTAssertTrue(mm.count == 0)
        XCTAssertEqual(mm.forward, [:])

        mm[0] = ["zero"]
        XCTAssertTrue(mm.count == 1)
        XCTAssertEqual(mm[0], ["zero"])

        mm[0]! += ["one"]
        XCTAssertTrue(mm.count == 1)
        XCTAssertEqual(mm[0], ["zero", "one"])

        mm[0]! += ["two", "three"]
        XCTAssertTrue(mm.count == 1)
        XCTAssertEqual(mm[0], ["zero", "one", "two", "three"])

        XCTAssertEqual(mm.backward["zero"], [0])
        XCTAssertEqual(mm.backward["one"], [0])
        XCTAssertEqual(mm.backward["two"], [0])
        XCTAssertEqual(mm.backward["three"], [0])
        XCTAssertTrue(mm.count == 4)
    }

    func testAddValuesToExistingKeysBackward() {
        var mm = BiMultiMap<Int, String>()
        XCTAssertTrue(mm.count == 0)
        XCTAssertEqual(mm.forward, [:])

        mm[0] = ["zero"]
        mm[0]! += ["one"]
        XCTAssertEqual(mm[0], ["zero", "one"])
        XCTAssertTrue(mm.count == 1)
        mm[0]! += ["two", "three"]
        XCTAssertEqual(mm[0], ["zero", "one", "two", "three"])
    }

    func testForwardAccess() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["one", "two", "three"]] )
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm.forward, [1:["A","B","C"], 2:["one", "two", "three"]])
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm[1], ["A","B","C"])
        XCTAssertEqual(mm[1]![0], "A")
    }

    // backwards keys are distinct
    func testBackwardAccessDistinct() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["one", "two", "three"]] )
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm.backward, ["C": [1], "three": [2], "one": [2], "A": [1], "B": [1], "two": [2]])
        XCTAssertTrue(mm.count == 6)
        XCTAssertEqual(mm["C"], [1])
    }

    // backwards keys are common - value mappings (arrays) can be in any order
    func testBackwardAccess() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["A", "B", "C"]] )
        // mm.backward is ["A": [2, 1], "B": [2, 1], "C": [2, 1]] or ["A": [1, 2], "B": [1, 2], "C": [1, 2]]
        XCTAssertEqual(mm["C"]?.sorted(), [1, 2], "sorted value since order is not guaranteed")
        XCTAssertTrue(mm.count == 3)
    }

    func testForwardRemovalsWithNil() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["A","B","C"], 3:["A","B","C"]] )
        XCTAssertTrue(mm.count == 3)

        // forward removal via nil - should have: [1: ["A", "B", "C"], 3: ["A", "B", "C"]]
        mm[2] = nil
        XCTAssertNil(mm[2])
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm.forward,[1: ["A","B","C"], 3: ["A","B","C"]])

        // ensure backward checks out - ["A": [1, 3], "B": [1, 3], "C": [1, 3]]
        XCTAssertEqual(mm["A"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertEqual(mm["B"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertEqual(mm["C"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertTrue(mm.count == 3)
    }

    func testForwardRemovalsWithRemove() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["A","B","C"], 3:["A","B","C"]] )
        XCTAssertTrue(mm.count == 3)

        // forward removal via remove() - should have: [1:["A","B","C"], 3:["A","B","C"]]
        mm.remove(2)
        XCTAssertNil(mm[2])
        XCTAssertTrue(mm.count == 2)
        XCTAssertEqual(mm.forward,[1: ["A","B","C"], 3: ["A","B","C"]])

        // ensure backward checks out - ["A": [1, 3], "B": [1, 3], "C": [1, 3]]
        XCTAssertEqual(mm["A"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertEqual(mm["B"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertEqual(mm["C"]?.sorted(), [1,3], "sorted value since order is not guaranteed")
        XCTAssertTrue(mm.count == 3)
    }

    func testBackwardRemovalsViaNil() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["A", "B", "C"]] )
        XCTAssertTrue(mm.count == 2)
        XCTAssertTrue(mm.backward.count == 3) // ["A": [1, 2], "B": [1, 2], "C": [1, 2]]

        // backward removal via nil
        mm["A"] = nil

        // confirm backward - should be: ["C": [1, 2], "B": [1, 2]]
        XCTAssertNil(mm["A"])
        XCTAssertTrue(mm["B"]!.contains(1))
        XCTAssertTrue(mm["B"]!.contains(2))
        XCTAssertTrue(mm["C"]!.contains(1))
        XCTAssertTrue(mm["C"]!.contains(2))

        // confirm forward - should be: [1: ["C", "B"], 2: ["C", "B"]]
        XCTAssertFalse(mm[1]!.contains("A"))
        XCTAssertTrue(mm[1]!.contains("B"))
        XCTAssertTrue(mm[1]!.contains("C"))

        XCTAssertFalse(mm[2]!.contains("A"))
        XCTAssertTrue(mm[2]!.contains("B"))
        XCTAssertTrue(mm[2]!.contains("C"))
    }

    func testBackwardRemovalsViaRemove() {
        var mm = BiMultiMap( [1:["A","B","C"], 2:["A", "B", "C"]] )
        XCTAssertTrue(mm.count == 2)
        XCTAssertTrue(mm.backward.count == 3) // ["A": [1, 2], "B": [1, 2], "C": [1, 2]]

        // backward removal via nil
        mm.remove("A")

        // confirm backward - should be: ["C": [1, 2], "B": [1, 2]]
        XCTAssertNil(mm["A"])
        XCTAssertTrue(mm["B"]!.contains(1))
        XCTAssertTrue(mm["B"]!.contains(2))
        XCTAssertTrue(mm["C"]!.contains(1))
        XCTAssertTrue(mm["C"]!.contains(2))

        // confirm forward - should be: [1: ["C", "B"], 2: ["C", "B"]]
        XCTAssertFalse(mm[1]!.contains("A"))
        XCTAssertTrue(mm[1]!.contains("B"))
        XCTAssertTrue(mm[1]!.contains("C"))

        XCTAssertFalse(mm[2]!.contains("A"))
        XCTAssertTrue(mm[2]!.contains("B"))
        XCTAssertTrue(mm[2]!.contains("C"))
    }
}
