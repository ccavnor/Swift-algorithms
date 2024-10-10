//
//  BiMapTests.swift
//  ccavnor-swift-collections
//
//  Created by Christopher Charles Cavnor on 10/10/24.
//

import XCTest
import SwiftUI
@testable import BiMap


final class BiMapTests: XCTestCase {

    // init(_ dict:[H:T] = [:])
    func testDictInit() {
        var bim = BiMap( [1:"A", 2:"B", 3:"C"] )
        XCTAssertEqual(bim.forward, [1: "A", 2: "B", 3: "C"])
        XCTAssertEqual(bim.backward, ["B": 2, "A": 1, "C": 3])
        XCTAssertTrue(bim.count == 3)
        XCTAssertEqual(bim[value: "C"], 3)
        XCTAssertEqual(bim[key: 3], "C")
    }

//    func testFoo() {
//        var bim = BiMap( [1:"A", 2:"B", 3:"C"] )
//        print(bim) // _backward is nil here
//        print(bim.forward)
//        print(bim) // _backward is nil here
//        print(bim.backward)
//        print(bim) // _backward is now set
//
//        // test symmetrical removal
//        bim[2] = nil
//        print(bim) // forward is correct, _backward is again nil
//        print(bim.backward) // correct
//    }

    // init(_ values:[(H,T)])
    func testValuesInit() {
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C")] )
        XCTAssertEqual(bim.forward, [1: "A", 3: "C", 2: "B"])
        XCTAssertEqual(bim.backward, ["B": 2, "A": 1, "C": 3])
        XCTAssertTrue(bim.count == 3)
        XCTAssertEqual(bim[value: "C"], 3)
        XCTAssertEqual(bim[key: 3], "C")
    }

    func testInitEmpty() {
        var bim = BiMap<Int, String>()
        XCTAssertTrue(bim.count == 0)
        XCTAssertEqual(bim.forward, [:])
        XCTAssertEqual(bim.backward, [:])

        bim[1] = "one"
        bim[2] = "two"
        bim[3] = "three"
        XCTAssertTrue(bim.count == 3)
        XCTAssertEqual(bim[value: "three"], 3)
        XCTAssertEqual(bim[key: 3], "three")
    }

    // BiMap will take the last key with a value that duplicates
    // a previous value
    func testNonDistinctValues() {
        // backward would create duplicate keys
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C"), (4, "C")] )
        XCTAssertTrue(bim.count == 4) // forward only values are duplicates
        // backwards --> ["A": 1, "B": 2, "C": 4]
        XCTAssertTrue(bim.backward.count == 3, "C would have been a duplicate key, so one is dropped")
        XCTAssertTrue(bim.forward.count == 4, "but forward preserves element")
    }

    func testForwardAccessors() {
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C")] )
        // get
        XCTAssertEqual(bim[key: 1], "A")
        XCTAssertEqual(bim[1], "A")
        XCTAssertNil(bim[key: 10], "non-existing element")
        XCTAssertNil(bim[10], "non-existing element")

        // set
        bim[4] = "D"
        XCTAssertEqual(bim[4], "D")

        bim[key: 5] = "foo"
        XCTAssertEqual(bim[5], "foo")

        // mutation
        bim[1] = "bar"
        XCTAssertEqual(bim[1], "bar")

        bim[key: 1] = "belt"
        XCTAssertEqual(bim[1], "belt")
    }

    func testBackwardAccessors() {
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C")] )
        // get
        XCTAssertEqual(bim[value: "A"], 1)
        XCTAssertEqual(bim["A"], 1)
        XCTAssertNil(bim[value: "Z"], "non-existing element")
        XCTAssertNil(bim["Z"], "non-existing element")

        // set
        bim["D"] = 4
        XCTAssertEqual(bim[4], "D")

        bim[value: "foo"] = 5
        XCTAssertEqual(bim[5], "foo")

        // mutation
        bim["A"] = 4
        XCTAssertEqual(bim[4], "A", "regression for duplicate key error")

        bim[value: "belt"] = 1
        XCTAssertEqual(bim[1], "belt", "regression for duplicate key error")
    }

    func testForwardRemovals() {
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C"), (4,"D")] )
        XCTAssertTrue(bim.count == 4)

        // setting to nil removes element from dict
        bim[3] = nil
        XCTAssertNil(bim[3])
        XCTAssertTrue(bim.count == 3)
        XCTAssertEqual(bim.forward,[4: "D", 1: "A", 2: "B"])
        XCTAssertEqual(bim.backward,["A": 1, "D": 4, "B": 2])

        bim[key: 4] = nil
        XCTAssertNil(bim[4])
        XCTAssertTrue(bim.count == 2)
        XCTAssertEqual(bim.forward,[1: "A", 2: "B"])
        XCTAssertEqual(bim.backward,["A": 1, "B": 2])

        bim.remove(1)
        XCTAssertNil(bim[1])
        XCTAssertTrue(bim.count == 1)
        XCTAssertEqual(bim.forward,[2: "B"])
        XCTAssertEqual(bim.backward,["B": 2])
    }

    func testBackwardRemovals() {
        var bim = BiMap( [(1,"A"), (2,"B"), (3,"C"), (4,"D")] )
        XCTAssertTrue(bim.count == 4)

        // setting to nil removes element from dict
        bim["C"] = nil
        XCTAssertNil(bim["C"])
        XCTAssertTrue(bim.count == 3)
        print(bim.forward)
        print(bim.backward)
        XCTAssertEqual(bim.forward,[4: "D", 2: "B", 1: "A"])
        XCTAssertEqual(bim.backward,["D": 4, "B": 2, "A": 1])

        bim[value: "D"] = nil
        XCTAssertNil(bim["D"])
        XCTAssertTrue(bim.count == 2)
        XCTAssertEqual(bim.forward,[2: "B", 1: "A"])
        XCTAssertEqual(bim.backward,["B": 2, "A": 1])

        bim.remove("A")
        XCTAssertNil(bim["A"])
        XCTAssertTrue(bim.count == 1)
        XCTAssertEqual(bim.forward,[2: "B"])
        XCTAssertEqual(bim.backward,["B": 2])
    }

    func testNotBijective() {

    }

}
