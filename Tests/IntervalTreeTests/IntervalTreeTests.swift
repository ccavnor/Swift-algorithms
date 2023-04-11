import XCTest
import TreeProtocol
@testable import IntervalTree

// TODO: check that maxEnd is being updated with insertions and deletions
final class IntervalTreeTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // ==============================
    // Test Interval
    // ==============================
    func testIntervalCompare() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5) // a.end == b.start
        let interval2 = try! Interval(start: 6, end: 12) // spans interval0
        let interval3 = try! Interval(start: 7, end: 9) // within interval0
        let interval4 = try! Interval(start: 5, end: 15) // a.start == b.start but b.end > a.end (should be to right of interval0)

        // true when a.start > b.start or a.start == b.start and a.end > b.end
        XCTAssertFalse(interval0 > interval0)
        XCTAssertTrue(interval0 > interval1)
        XCTAssertFalse(interval0 > interval2)
        XCTAssertFalse(interval0 > interval3)
        XCTAssertFalse(interval0 > interval4)

        // true when a.start > b.start or a.start == b.start but a.end > b.end or a == b
        XCTAssertTrue(interval0 >= interval0)
        XCTAssertTrue(interval0 >= interval1)
        XCTAssertFalse(interval0 >= interval2)
        XCTAssertFalse(interval0 >= interval3)
        XCTAssertFalse(interval0 >= interval4)

        // true when a.start < b.start or a.start == b.start and a.end < b.end
        XCTAssertFalse(interval0 < interval0)
        XCTAssertFalse(interval0 < interval1)
        XCTAssertTrue(interval0 < interval2)
        XCTAssertTrue(interval0 < interval3)
        XCTAssertTrue(interval0 < interval4)

        // true when a.start < b.start or a.start == b.start but a.end < b.end or a == b
        XCTAssertTrue(interval0 <= interval0)
        XCTAssertFalse(interval0 <= interval1)
        XCTAssertTrue(interval0 <= interval2)
        XCTAssertTrue(interval0 <= interval3)
        XCTAssertTrue(interval0 <= interval4)

        // true when a.start == b.start and a.end == b.end
        XCTAssertTrue(interval0 == interval0)
        XCTAssertFalse(interval0 == interval1)
        XCTAssertFalse(interval0 == interval2)
        XCTAssertFalse(interval0 == interval3)
        XCTAssertFalse(interval0 == interval4)

        // true when a.start != b.start or a.end != b.end
        XCTAssertFalse(interval0 != interval0)
        XCTAssertTrue(interval0 != interval1)
        XCTAssertTrue(interval0 != interval2)
        XCTAssertTrue(interval0 != interval3)
        XCTAssertTrue(interval0 != interval4)
    }

    func testIntervalAdditiveArithmetic() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 0, end: 0)
        let interval3 = try! Interval(start: -5, end: 0)
        let interval4 = try! Interval(start: 0, end: 5)
        let interval5 = try! Interval(start: -15, end: -5)

        // test identity
        XCTAssertEqual(interval2, interval2 + interval2)
        XCTAssertEqual(interval2, interval2 - interval2)
        // test addition
        var result = try? Interval(start: 0, end: 15)
        XCTAssertEqual(result, (interval0 + interval1))
        result = try? Interval(start: -5, end: 5)
        XCTAssertEqual(result, (interval3 + interval4))
        XCTAssertEqual(interval1 + interval2, interval2 + interval1, "commutativity of addition")
        
        // test subtraction
        result = try? Interval(start: 5, end: 5)
        XCTAssertEqual(result, (interval0 - interval4))
        XCTAssertNotEqual(result, (interval4 - interval1), "subtraction is not commutative")
        result = try? Interval(start: 10, end: 10)
        XCTAssertEqual(result, (interval1 - interval5)) // {-5, 5} - {-15, -5}
        // cannot create interval where end < start
        XCTAssertEqual(interval2, (interval0 - interval1),
                       "intervals can only exist if end > start. Erroneous operations receive Interval {0,0}")
    }

    func test_Interval_init() {
        let point = try? Interval(start: 1, end: 1)
        XCTAssertEqual(1, point?.start)
        XCTAssertEqual(1, point?.end)
        XCTAssertTrue(type(of: point!.start) == Int.self, "type is unchanged using ints")
        XCTAssertTrue(type(of: point!.end) == Int.self, "type is unchanged using ints")

        let interval0 = try? Interval(start: 0, end: 1)
        XCTAssertEqual(0, interval0?.start)
        XCTAssertEqual(1, interval0?.end)
        XCTAssertTrue(type(of: interval0!.start) == Int.self, "type is unchanged using ints")
        XCTAssertTrue(type(of: interval0!.end) == Int.self, "type is unchanged using ints")

        let interval1 = try? Interval(start: 0.9, end: 1)
        XCTAssertEqual(0.9, interval1?.start)
        XCTAssertEqual(1.0, interval1?.end)
        XCTAssertTrue(type(of: interval1!.start) == Double.self, "type is upcast to double when mixed with int")
        XCTAssertTrue(type(of: interval1!.end) == Double.self, "type is upcast to double when mixed with int")

        let interval2 = try? Interval(start: 0.0000, end: 0.0001)
        XCTAssertEqual(0.0000, interval2?.start)
        XCTAssertEqual(0.0001, interval2?.end)
        XCTAssertTrue(type(of: interval2!.start) == Double.self)
        XCTAssertTrue(type(of: interval2!.end) == Double.self)

        let interval3 = try? Interval(start: -1, end: 1)
        XCTAssertEqual(-1, interval3?.start)
        XCTAssertEqual(1, interval3?.end)
        XCTAssertTrue(type(of: interval3!.start) == Int.self)
        XCTAssertTrue(type(of: interval3!.end) == Int.self)

        let interval4 = try? Interval(start: -4, end: -1)
        XCTAssertEqual(-4, interval4?.start)
        XCTAssertEqual(-1, interval4?.end)
        XCTAssertTrue(type(of: interval4!.start) == Int.self)
        XCTAssertTrue(type(of: interval4!.end) == Int.self)

        let interval5 = try? Interval(start: -4.2, end: 1.3)
        XCTAssertEqual(-4.2, interval5?.start)
        XCTAssertEqual(1.3, interval5?.end)
        XCTAssertTrue(type(of: interval5!.start) == Double.self)
        XCTAssertTrue(type(of: interval5!.end) == Double.self)

        XCTAssertThrowsError(try Interval(start: 10, end: 9)) { error in
            XCTAssertEqual(error as! TreeError, TreeError.invalidInterval, "end of interval must be greater than start")
        }
        XCTAssertThrowsError(try Interval(start: -1, end: -2)) { error in
            XCTAssertEqual(error as! TreeError, TreeError.invalidInterval, "end of interval must be greater than start")
        }
    }

    func testCreateFromArray() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 6, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        let i0 = tree.search(value: interval0)!
        XCTAssertEqual(i0.value.start, 5)
        XCTAssertEqual(i0.value.end, 10)
        let i1 = tree.search(value: interval1)!
        XCTAssertEqual(i1.value.start, -5)
        XCTAssertEqual(i1.value.end, 5)
        let i2 = tree.search(value: interval2)!
        XCTAssertEqual(i2.value.start, 6)
        XCTAssertEqual(i2.value.end, 12)
        let i3 = tree.search(value: interval3)!
        XCTAssertEqual(i3.value.start, 7)
        XCTAssertEqual(i3.value.end, 9)
        let i4 = tree.search(value: interval4)!
        XCTAssertEqual(i4.value.start, 12)
        XCTAssertEqual(i4.value.end, 15)
    }

    //----------------------------
    // Interval Comparables
    //----------------------------
    // Interval comparable rules:
    // ==: intervals begin and end at same values
    // !=: intervals strictly do not overlap
    // lt: true when a.start < b.start or a.start == b.start and a.end < b.end
    // lte: true when a.start < b.start or a.start == b.start but a.end < b.end or a == b
    // gt: true when a.start > b.start or a.start == b.start and a.end > b.end
    // gte: true when a.start > b.start or a.start == b.start but a.end > b.end or a == b


    // intervals that have a common start must be positioned in tree based on their end points (ie. interval length)
    func testOrderingOfIntervalsWithCommonStart() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: 5, end: 5)
        let interval2 = try! Interval(start: 5, end: 6)
        let interval3 = try! Interval(start: -5, end: 5)
        let interval4 = try! Interval(start: 0, end: 6)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.display(node: tree.root!)

        // equivalent to nodes in tree but not from tree
        let iNode0 = IntervalTreeNode(value: interval0)
        let iNode1 = IntervalTreeNode(value: interval1)
        let iNode2 = IntervalTreeNode(value: interval2)
        let iNode3 = IntervalTreeNode(value: interval3)
        let iNode4 = IntervalTreeNode(value: interval4)

        // check lengths
        XCTAssertEqual(5, iNode0.length)
        XCTAssertEqual(0, iNode1.length)
        XCTAssertEqual(1, iNode2.length)
        XCTAssertEqual(10, iNode3.length)
        XCTAssertEqual(6, iNode4.length)

        // check maxEnd
        XCTAssertEqual(10, iNode0.maxEnd)
        XCTAssertEqual(5, iNode1.maxEnd)
        XCTAssertEqual(6, iNode2.maxEnd)
        XCTAssertEqual(5, iNode3.maxEnd)
        XCTAssertEqual(6, iNode4.maxEnd)

        XCTAssertTrue(interval0 == interval0) // {5, 10} == {5, 10}
        XCTAssertFalse(interval0 != interval0) // {5, 10} != {5, 10}

        XCTAssertFalse(interval0 > interval0) // {5, 10} > {5, 10}
        XCTAssertTrue(interval0 > interval1) // {5, 10} > {5, 5}
        XCTAssertTrue(interval0 > interval2) // {5, 10} > {5, 6}
        XCTAssertTrue(interval0 > interval3) // {5, 10} > {-5, 5}
        XCTAssertTrue(interval0 > interval4) // {5, 10} > {0, 6}
        XCTAssertFalse(interval1 > interval2) // {5, 5} > {5, 6}
        XCTAssertTrue(interval2 > interval3) // {5, 6} > {-5, 5}
        XCTAssertFalse(interval3 > interval4) // {-5, 5} > {0, 6}

        XCTAssertFalse(interval0 < interval0) // {5, 10} < {5, 10}
        XCTAssertFalse(interval0 < interval1) // {5, 10} < {5, 5}
        XCTAssertFalse(interval0 < interval2) // {5, 10} < {5, 6}
        XCTAssertFalse(interval0 < interval3) // {5, 10} < {-5, 5}
        XCTAssertFalse(interval0 < interval4) // {5, 10} < {0, 6}
        XCTAssertTrue(interval1 < interval2) // {5, 5} < {5, 6}
        XCTAssertFalse(interval2 < interval3) // {5, 6} < {-5, 5}
        XCTAssertTrue(interval3 < interval4) // {-5, 5} < {0, 6}

        XCTAssertTrue(interval0 >= interval0) // {5, 10} >= {5, 10}
        XCTAssertTrue(interval0 >= interval1) // {5, 10} >= {5, 5}
        XCTAssertTrue(interval0 >= interval2) // {5, 10} >= {5, 6}
        XCTAssertTrue(interval0 >= interval3) // {5, 10} >= {-5, 5}
        XCTAssertTrue(interval0 >= interval4) // {5, 10} >= {0, 6}
        XCTAssertFalse(interval1 >= interval2) // {5, 5} >= {5, 6}
        XCTAssertTrue(interval2 >= interval3) // {5, 6} >= {-5, 5}
        XCTAssertFalse(interval3 >= interval4) // {-5, 5} >= {0, 6}

        XCTAssertTrue(interval0 <= interval0) // {5, 10} <= {5, 10}
        XCTAssertFalse(interval0 <= interval1) // {5, 10} <= {5, 5}
        XCTAssertFalse(interval0 <= interval2) // {5, 10} <= {5, 6}
        XCTAssertFalse(interval0 <= interval3) // {5, 10} <= {-5, 5}
        XCTAssertFalse(interval0 <= interval4) // {5, 10} <= {0, 6}
        XCTAssertTrue(interval1 <= interval2) // {5, 5} <= {5, 6}
        XCTAssertFalse(interval2 <= interval3) // {5, 6} <= {-5, 5}
        XCTAssertTrue(interval3 <= interval4) // {-5, 5} <= {0, 6}
    }

    // test comparable functions for positively valued intervals of type Int
    func test_IntervalComparable_positive_Int() {
        // Interval<Int> instances
        let interval0 = try! Interval(start: 14, end: 16)
        let interval1 = try! Interval(start: 10, end: 15)
        let interval2 = try! Interval(start: 15, end: 20)
        let interval3 = try! Interval(start: 10, end: 14)
        let interval4 = try! Interval(start: 16, end: 20)
        let interval5 = try! Interval(start: 14, end: 15)
        let interval6 = try! Interval(start: 15, end: 16)
        let interval7 = try! Interval(start: 14, end: 14)
        let interval8 = try! Interval(start: 15, end: 15)
        let interval9 = try! Interval(start: 16, end: 16)
        let interval10 = try! Interval(start: 10, end: 20)
        let interval11 = try! Interval(start: 17, end: 20)
        let interval12 = try! Interval(start: 10, end: 13)

        // --- equality
        let interval0_same = try! Interval(start: 14, end: 16)
        XCTAssertTrue(interval0 == interval0)
        XCTAssertTrue(interval0 == interval0_same)
        let interval0_start_same = try! Interval(start: 14, end: 20)
        let interval0_end_same = try! Interval(start: 10, end: 16)
        XCTAssertFalse(interval0 == interval0_start_same)
        XCTAssertFalse(interval0 == interval0_end_same)

        // --- non-equality
        XCTAssertFalse(interval0 != interval0)
        XCTAssertFalse(interval0 != interval0_same)
        XCTAssertTrue(interval0 != interval1)

        // --- gt: rue when a.start > b.start or a.start == b.start and a.end > b.end
        XCTAssertFalse(interval0 > interval0, "overlaps self")
        XCTAssertTrue(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertTrue(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertTrue(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertTrue(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertTrue(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: true when a.start > b.start or a.start == b.start but a.end > b.end or a == b
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertTrue(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertTrue(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertTrue(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: true when a.start < b.start or a.start == b.start and a.end < b.end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertTrue(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertTrue(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertTrue(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertTrue(interval0 < interval8, "within - single point in middle")
        XCTAssertTrue(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: true when a.start < b.start or a.start == b.start but a.end < b.end or a == b
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertTrue(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertTrue(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertTrue(interval0 <= interval8, "within - single point in middle")
        XCTAssertTrue(interval0 <= interval9, "within - single point on right")
        XCTAssertFalse(interval0 <= interval10, "spans left and right")
        XCTAssertTrue(interval0 <= interval11, "outside (right)")
        XCTAssertFalse(interval0 <= interval12, "outside (left)")
    }

    // test comparable functions for negatively valued intervals of type Int
    func test_IntervalComparable_negative_Int() {
        // Interval<Int> negative instances (to test Intervals that are negative or start negative and end positive)
        let interval0 = try! Interval(start: -3, end: -1)
        let interval1 = try! Interval(start: -4, end: -2)
        let interval2 = try! Interval(start: -2, end: 1)
        let interval3 = try! Interval(start: -5, end: -3)
        let interval4 = try! Interval(start: -1, end: 2)
        let interval5 = try! Interval(start: -3, end: -2)
        let interval6 = try! Interval(start: -2, end: -1)
        let interval7 = try! Interval(start: -3, end: -3)
        let interval8 = try! Interval(start: -2, end: -2)
        let interval9 = try! Interval(start: -1, end: -1)
        let interval10 = try! Interval(start: -5, end: 2)
        let interval11 = try! Interval(start: 0, end: 3)
        let interval12 = try! Interval(start: -7, end: -5)

        // --- equality
        let interval0_same = try! Interval(start: -3, end: -1)
        //XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        //XCTAssertFalse(interval0 === interval0_same)
        XCTAssertTrue(interval0 == interval0_same)
        let interval0_start_same = try! Interval(start: -3, end: 2)
        let interval0_end_same = try! Interval(start: -5, end: -1)
        XCTAssertFalse(interval0 == interval0_start_same)
        XCTAssertFalse(interval0 == interval0_end_same)

        // --- non-equality
        XCTAssertFalse(interval0 != interval0)
        XCTAssertFalse(interval0 != interval0_same)
        XCTAssertTrue(interval0 != interval1)

        // --- gt: reference interval must be to the right of test interval end
        XCTAssertFalse(interval0 > interval0, "overlaps self")
        XCTAssertTrue(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertTrue(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertTrue(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertTrue(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertTrue(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertTrue(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertTrue(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertTrue(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertTrue(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertTrue(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertTrue(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertTrue(interval0 < interval8, "within - single point in middle")
        XCTAssertTrue(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertTrue(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertTrue(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertTrue(interval0 <= interval8, "within - single point in middle")
        XCTAssertTrue(interval0 <= interval9, "within - single point on right")
        XCTAssertFalse(interval0 <= interval10, "spans left and right")
        XCTAssertTrue(interval0 <= interval11, "outside (right)")
        XCTAssertFalse(interval0 <= interval12, "outside (left)")
    }

    // test comparable functions for positively valued intervals of type Double
    func test_IntervalComparable_positive_Double() {
        // Interval<Double> instances
        let interval0 = try! Interval(start: 14.0, end: 16.0)
        let interval1 = try! Interval(start: 10, end: 14.01)
        let interval2 = try! Interval(start: 14.999, end: 20)
        let interval3 = try! Interval(start: 10, end: 14.0)
        let interval4 = try! Interval(start: 16.0, end: 20)
        let interval5 = try! Interval(start: 14.0, end: 14.00001)
        let interval6 = try! Interval(start: 15.9999, end: 16)
        let interval7 = try! Interval(start: 14.0, end: 14)
        let interval8 = try! Interval(start: 15.0, end: 15)
        let interval9 = try! Interval(start: 16.0, end: 16)
        let interval10 = try! Interval(start: 10.0, end: 20)
        let interval11 = try! Interval(start: 16.0001, end: 20)
        let interval12 = try! Interval(start: 10.0, end: 13)

        // --- equality
        let interval0_same = try! Interval(start: 14.0, end: 16.0)
        //XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        //XCTAssertFalse(interval0 === interval0_same)
        XCTAssertTrue(interval0 == interval0_same)
        let interval0_start_same = try! Interval(start: 14.0, end: 20.0)
        let interval0_end_same = try! Interval(start: 10.0, end: 16)
        XCTAssertFalse(interval0 == interval0_start_same)
        XCTAssertFalse(interval0 == interval0_end_same)

        // --- non-equality
        XCTAssertFalse(interval0 != interval0)
        XCTAssertFalse(interval0 != interval0_same)
        XCTAssertTrue(interval0 != interval1)

        // --- gt: reference interval must be to the right of test interval end
        XCTAssertFalse(interval0 > interval0, "overlaps self")
        XCTAssertTrue(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertTrue(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertTrue(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertTrue(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertTrue(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertTrue(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertTrue(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertTrue(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertTrue(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertTrue(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertTrue(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertTrue(interval0 < interval8, "within - single point in middle")
        XCTAssertTrue(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertTrue(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertTrue(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertTrue(interval0 <= interval8, "within - single point in middle")
        XCTAssertTrue(interval0 <= interval9, "within - single point on right")
        XCTAssertFalse(interval0 <= interval10, "spans left and right")
        XCTAssertTrue(interval0 <= interval11, "outside (right)")
        XCTAssertFalse(interval0 <= interval12, "outside (left)")
    }

    // test comparable functions for negatively valued intervals of type Double
    func test_IntervalComparable_negative_Double() {
        // Interval<Double> negative instances (to test Intervals that are negative or start negative and end positive)
        let interval0 = try! Interval(start: -3.0, end: -1.0)
        let interval1 = try! Interval(start: -4, end: -2.9999)
        let interval2 = try! Interval(start: -2, end: -1.01)
        let interval3 = try! Interval(start: -5, end: -3.0)
        let interval4 = try! Interval(start: -1, end: 2.0)
        let interval5 = try! Interval(start: -3, end: -2.9999)
        let interval6 = try! Interval(start: -2, end: -1.0)
        let interval7 = try! Interval(start: -3.0, end: -3)
        let interval8 = try! Interval(start: -2.0, end: -2)
        let interval9 = try! Interval(start: -1.0, end: -1)
        let interval10 = try! Interval(start: -5.0, end: 2)
        let interval11 = try! Interval(start: 0.0, end: 3)
        let interval12 = try! Interval(start: -7.0, end: -5)

        // --- equality
        let interval0_same = try! Interval(start: -3.0, end: -1.0)
        //XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        //XCTAssertFalse(interval0 === interval0_same)
        XCTAssertTrue(interval0 == interval0_same)
        let interval0_start_same = try! Interval(start: -3.000, end: 2.000)
        let interval0_end_same = try! Interval(start: -5.0, end: -1)
        XCTAssertFalse(interval0 == interval0_start_same)
        XCTAssertFalse(interval0 == interval0_end_same)

        // --- non-equality
        XCTAssertFalse(interval0 != interval0)
        XCTAssertFalse(interval0 != interval0_same)
        XCTAssertTrue(interval0 != interval1)

        // --- gt: reference interval must be to the right of test interval end
        XCTAssertFalse(interval0 > interval0, "overlaps self")
        XCTAssertTrue(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertTrue(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertTrue(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertTrue(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertTrue(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertTrue(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertTrue(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertTrue(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertTrue(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertTrue(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertTrue(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertTrue(interval0 < interval8, "within - single point in middle")
        XCTAssertTrue(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertTrue(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertTrue(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertTrue(interval0 <= interval8, "within - single point in middle")
        XCTAssertTrue(interval0 <= interval9, "within - single point on right")
        XCTAssertFalse(interval0 <= interval10, "spans left and right")
        XCTAssertTrue(interval0 <= interval11, "outside (right)")
        XCTAssertFalse(interval0 <= interval12, "outside (left)")
    }

    // ==============================
    // Test IntervalNode
    // ==============================
    func test_isOverlapping_positive () {
        // IntervalNode instances
        let intervalNode0 = IntervalTreeNode(start: 14, end: 16) // the test interval
        let intervalNode1 = IntervalTreeNode(start: 10, end: 15) // overlaps from left
        let intervalNode2 = IntervalTreeNode(start: 15, end: 20) // overlaps from right
        let intervalNode3 = IntervalTreeNode(start: 10, end: 14) // touches left
        let intervalNode4 = IntervalTreeNode(start: 16, end: 20) // touches right
        let intervalNode5 = IntervalTreeNode(start: 14, end: 15) // within - overlaps start
        let intervalNode6 = IntervalTreeNode(start: 15, end: 16) // within - overlaps end
        let intervalNode7 = IntervalTreeNode(start: 14, end: 14) // within - single point on left
        let intervalNode8 = IntervalTreeNode(start: 15, end: 15) // within - single point in middle
        let intervalNode9 = IntervalTreeNode(start: 16, end: 16) // within - single point on right
        let intervalNode10 = IntervalTreeNode(start: 10, end: 20) // spans (left and right)
        let intervalNode11 = IntervalTreeNode(start: 17, end: 20) // outside (right)
        let intervalNode12 = IntervalTreeNode(start: 10, end: 13) // outside (left)

        XCTAssertEqual(2, intervalNode0.length)
        XCTAssertEqual(5, intervalNode1.length)
        XCTAssertEqual(5, intervalNode2.length)
        XCTAssertEqual(4, intervalNode3.length)
        XCTAssertEqual(4, intervalNode4.length)
        XCTAssertEqual(1, intervalNode5.length)
        XCTAssertEqual(1, intervalNode6.length)
        XCTAssertEqual(0, intervalNode7.length, "intervals of zero length are allowed")

        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode0), "overlaps self")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode1), "overlaps from left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode2), "overlaps from right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode3), "touches left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode4), "touches right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode5), "within - overlaps start")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode6), "within - overlaps end")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode7), "within - single point on left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode8), "within - single point in middle")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode9), "within - single point on right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode10), "spans left and right")
        XCTAssertFalse(intervalNode0.isOverlapping(node: intervalNode11), "outside (right)")
        XCTAssertFalse(intervalNode0.isOverlapping(node: intervalNode12), "outside (left)")
    }

    func test_isOverlapping_negative () {
        // Interval<Double> negative instances (to test Intervals that are negative or start negative and end positive)
        let interval0 = try! Interval(start: -3.0, end: -1.0)
        let interval1 = try! Interval(start: -4, end: -2.9999)
        let interval2 = try! Interval(start: -2, end: -1.01)
        let interval3 = try! Interval(start: -5, end: -3.0)
        let interval4 = try! Interval(start: -1, end: 2.0)
        let interval5 = try! Interval(start: -3, end: -2.9999)
        let interval6 = try! Interval(start: -2, end: -1.0)
        let interval7 = try! Interval(start: -3.0, end: -3)
        let interval8 = try! Interval(start: -2.0, end: -2)
        let interval9 = try! Interval(start: -1.0, end: -1)
        let interval10 = try! Interval(start: -5.0, end: 2)
        let interval11 = try! Interval(start: 0.0, end: 3)
        let interval12 = try! Interval(start: -7.0, end: -5)

        // IntervalNode instances
        let intervalNode0 = IntervalTreeNode(value: interval0) // the test interval
        let intervalNode1 = IntervalTreeNode(value: interval1) // overlaps from left
        let intervalNode2 = IntervalTreeNode(value: interval2) // overlaps from right
        let intervalNode3 = IntervalTreeNode(value: interval3) // touches left
        let intervalNode4 = IntervalTreeNode(value: interval4) // touches right
        let intervalNode5 = IntervalTreeNode(value: interval5) // within - overlaps start
        let intervalNode6 = IntervalTreeNode(value: interval6) // within - overlaps end
        let intervalNode7 = IntervalTreeNode(value: interval7) // within - single point on left
        let intervalNode8 = IntervalTreeNode(value: interval8) // within - single point in middle
        let intervalNode9 = IntervalTreeNode(value: interval9) // within - single point on right
        let intervalNode10 = IntervalTreeNode(value: interval10) // spans (left and right)
        let intervalNode11 = IntervalTreeNode(value: interval11) // outside (right)
        let intervalNode12 = IntervalTreeNode(value: interval12) // outside (left)

        XCTAssertEqual(2.0, intervalNode0.length)
        XCTAssertEqual(1.0001, intervalNode1.length)
        XCTAssertEqual(0.99, intervalNode2.length)
        XCTAssertEqual(2, intervalNode3.length)
        XCTAssertEqual(3, intervalNode4.length)
        XCTAssertEqual(0.0001, intervalNode5.length)
        XCTAssertEqual(1, intervalNode6.length)
        XCTAssertEqual(0, intervalNode7.length, "intervals of zero length are allowed")

        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode0), "overlaps self")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode1), "overlaps from left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode2), "overlaps from right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode3), "touches left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode4), "touches right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode5), "within - overlaps start")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode6), "within - overlaps end")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode7), "within - single point on left")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode8), "within - single point in middle")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode9), "within - single point on right")
        XCTAssertTrue(intervalNode0.isOverlapping(node: intervalNode10), "spans left and right")
        XCTAssertFalse(intervalNode0.isOverlapping(node: intervalNode11), "outside (right)")
        XCTAssertFalse(intervalNode0.isOverlapping(node: intervalNode12), "outside (left)")
    }

    func test_isWithin_positive () {
        // Interval<Int> instances
        let interval0 = try! Interval(start: 14, end: 16)
        let interval1 = try! Interval(start: 10, end: 15)
        let interval2 = try! Interval(start: 15, end: 20)
        let interval3 = try! Interval(start: 10, end: 14)
        let interval4 = try! Interval(start: 16, end: 20)
        let interval5 = try! Interval(start: 14, end: 15)
        let interval6 = try! Interval(start: 15, end: 16)
        let interval7 = try! Interval(start: 14, end: 14)
        let interval8 = try! Interval(start: 15, end: 15)
        let interval9 = try! Interval(start: 16, end: 16)
        let interval10 = try! Interval(start: 10, end: 20)
        let interval11 = try! Interval(start: 17, end: 20)
        let interval12 = try! Interval(start: 10, end: 13)

        // IntervalNode instances
        let intervalNode0 = IntervalTreeNode(value: interval0) // the test interval
        let intervalNode1 = IntervalTreeNode(value: interval1) // overlaps from left
        let intervalNode2 = IntervalTreeNode(value: interval2) // overlaps from right
        let intervalNode3 = IntervalTreeNode(value: interval3) // touches left
        let intervalNode4 = IntervalTreeNode(value: interval4) // touches right
        let intervalNode5 = IntervalTreeNode(value: interval5) // within - overlaps start
        let intervalNode6 = IntervalTreeNode(value: interval6) // within - overlaps end
        let intervalNode7 = IntervalTreeNode(value: interval7) // within - single point on left
        let intervalNode8 = IntervalTreeNode(value: interval8) // within - single point in middle
        let intervalNode9 = IntervalTreeNode(value: interval9) // within - single point on right
        let intervalNode10 = IntervalTreeNode(value: interval10) // spans (left and right)
        let intervalNode11 = IntervalTreeNode(value: interval11) // outside (right)
        let intervalNode12 = IntervalTreeNode(value: interval12) // outside (left)

        // Intervals that intervalNode0 are within
        XCTAssertTrue(intervalNode0.isWithin(node: intervalNode0), "overlaps self")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode1), "overlaps from left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode2), "overlaps from right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode3), "touches left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode4), "touches right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode5), "within - overlaps start")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode6), "within - overlaps end")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode7), "within - single point on left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode8), "within - single point in middle")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode9), "within - single point on right")
        XCTAssertTrue(intervalNode0.isWithin(node: intervalNode10), "spans left and right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode11), "outside (right)")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode12), "outside (left)")
        // point intervals within intervalNode0
        XCTAssertTrue(intervalNode5.isWithin(node: intervalNode0), "within - overlaps start")
        XCTAssertTrue(intervalNode6.isWithin(node: intervalNode0), "within - overlaps end")
        XCTAssertTrue(intervalNode7.isWithin(node: intervalNode0), "within - single point on left")
        XCTAssertTrue(intervalNode8.isWithin(node: intervalNode0), "within - single point in middle")
        XCTAssertTrue(intervalNode9.isWithin(node: intervalNode0), "within - single point on right")
    }

    func test_isWithin_negative() {
        // Interval<Double> negative instances (to test Intervals that are negative or start negative and end positive)
        let interval0 = try! Interval(start: -3.0, end: -1.0)
        let interval1 = try! Interval(start: -4, end: -2.9999)
        let interval2 = try! Interval(start: -2, end: -1.01)
        let interval3 = try! Interval(start: -5, end: -3.0)
        let interval4 = try! Interval(start: -1, end: 2.0)
        let interval5 = try! Interval(start: -3, end: -2.9999)
        let interval6 = try! Interval(start: -2, end: -1.0)
        let interval7 = try! Interval(start: -3.0, end: -3)
        let interval8 = try! Interval(start: -2.0, end: -2)
        let interval9 = try! Interval(start: -1.0, end: -1)
        let interval10 = try! Interval(start: -5.0, end: 2)
        let interval11 = try! Interval(start: 0.0, end: 3)
        let interval12 = try! Interval(start: -7.0, end: -5)

        // IntervalNode instances
        let intervalNode0 = IntervalTreeNode(value: interval0) // the test interval
        let intervalNode1 = IntervalTreeNode(value: interval1) // overlaps from left
        let intervalNode2 = IntervalTreeNode(value: interval2) // overlaps from right
        let intervalNode3 = IntervalTreeNode(value: interval3) // touches left
        let intervalNode4 = IntervalTreeNode(value: interval4) // touches right
        let intervalNode5 = IntervalTreeNode(value: interval5) // within - overlaps start
        let intervalNode6 = IntervalTreeNode(value: interval6) // within - overlaps end
        let intervalNode7 = IntervalTreeNode(value: interval7) // within - single point on left
        let intervalNode8 = IntervalTreeNode(value: interval8) // within - single point in middle
        let intervalNode9 = IntervalTreeNode(value: interval9) // within - single point on right
        let intervalNode10 = IntervalTreeNode(value: interval10) // spans (left and right)
        let intervalNode11 = IntervalTreeNode(value: interval11) // outside (right)
        let intervalNode12 = IntervalTreeNode(value: interval12) // outside (left)

        // Intervals that intervalNode0 are within
        XCTAssertTrue(intervalNode0.isWithin(node: intervalNode0), "overlaps self")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode1), "overlaps from left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode2), "overlaps from right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode3), "touches left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode4), "touches right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode5), "within - overlaps start")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode6), "within - overlaps end")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode7), "within - single point on left")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode8), "within - single point in middle")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode9), "within - single point on right")
        XCTAssertTrue(intervalNode0.isWithin(node: intervalNode10), "spans left and right")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode11), "outside (right)")
        XCTAssertFalse(intervalNode0.isWithin(node: intervalNode12), "outside (left)")
        // point intervals within intervalNode0
        XCTAssertTrue(intervalNode5.isWithin(node: intervalNode0), "within - overlaps start")
        XCTAssertTrue(intervalNode6.isWithin(node: intervalNode0), "within - overlaps end")
        XCTAssertTrue(intervalNode7.isWithin(node: intervalNode0), "within - single point on left")
        XCTAssertTrue(intervalNode8.isWithin(node: intervalNode0), "within - single point in middle")
        XCTAssertTrue(intervalNode9.isWithin(node: intervalNode0), "within - single point on right")
    }

    // ==============================
    // Test IntervalTree
    // ==============================

    func testContains() {
        let interval0 = try! Interval(start: 5, end: 5)
        let interval1 = try! Interval(start: -5, end: 5) // overlaps interval0 on left (from neg)
        let interval2 = try! Interval(start: 4, end: 12) // interval0 is within
        let interval3 = try! Interval(start: 7, end: 9) // strictly right
        let interval4 = try! Interval(start: 0, end: 4) // strictly left
        let interval5 = try! Interval(start: 10, end: 12) // overlaps interval0 on right
        let interval6 = try! Interval(start: 1, end: 5) // overlaps interval0 on left
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4, interval5, interval6])
        let interval7 = try! Interval(start: 10, end: 20) // not inserted in tree

        XCTAssertTrue(tree.contains(value: interval0))
        XCTAssertTrue(tree.contains(value: interval1))
        XCTAssertTrue(tree.contains(value: interval2))
        XCTAssertTrue(tree.contains(value: interval3))
        XCTAssertTrue(tree.contains(value: interval4))
        XCTAssertTrue(tree.contains(value: interval5))
        XCTAssertTrue(tree.contains(value: interval6))
        XCTAssertFalse(tree.contains(value: interval7))
    }

    func testSearch() {
        let interval0 = try! Interval(start: 5, end: 5)
        let interval1 = try! Interval(start: -5, end: 5) // overlaps interval0 on left (from neg)
        let interval2 = try! Interval(start: 4, end: 12) // interval0 is within
        let interval3 = try! Interval(start: 7, end: 9) // strictly right
        let interval4 = try! Interval(start: 0, end: 4) // strictly left
        let interval5 = try! Interval(start: 10, end: 12) // overlaps interval0 on right
        let interval6 = try! Interval(start: 1, end: 5) // overlaps interval0 on left
        let interval7 = try! Interval(start: 5, end: 6) // overlaps interval0 on start (to test retrieval checks end)
        let interval8 = try! Interval(start: 5, end: 8) // overlaps interval0 on start (to test retrieval checks end)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4, interval5, interval6, interval7, interval8])
        let interval10 = try! Interval(start: 10, end: 20) // not inserted in tree
        XCTAssertEqual(tree.size, 9)
        XCTAssertEqual(tree.height(), 5)
        tree.draw()

        let i0 = tree.search(value: interval0)!
        let i1 = tree.search(value: interval1)!
        let i2 = tree.search(value: interval2)!
        let i3 = tree.search(value: interval3)!
        let i4 = tree.search(value: interval4)!
        let i5 = tree.search(value: interval5)!
        let i6 = tree.search(value: interval6)!
        let i7 = tree.search(value: interval7)!
        let i8 = tree.search(value: interval8)!
        let noI = tree.search(value: interval10)

        XCTAssertEqual(i0.value, interval0)
        XCTAssertEqual(i1.value, interval1)
        XCTAssertEqual(i2.value, interval2)
        XCTAssertEqual(i3.value, interval3)
        XCTAssertEqual(i4.value, interval4)
        XCTAssertEqual(i5.value, interval5)
        XCTAssertEqual(i6.value, interval6)
        XCTAssertEqual(i7.value, interval7)
        XCTAssertEqual(i8.value, interval8)
        // not in tree
        XCTAssertNil(noI)

        // search for entities that are not in tree
        let intervaln0 = try! Interval(start: 1, end: 3) // strictly left
        let intervaln1 = try! Interval(start: 4, end: 6) // interval0 is within
        let intervaln2 = try! Interval(start: 6, end: 9) // strictly right
        let intervaln3 = try! Interval(start: 3, end: 5) // overlaps left
        let intervaln4 = try! Interval(start: 5, end: 9) // overlaps right

        XCTAssertNil(tree.search(value: intervaln0))
        XCTAssertNil(tree.search(value: intervaln1))
        XCTAssertNil(tree.search(value: intervaln2))
        XCTAssertNil(tree.search(value: intervaln3))
        XCTAssertNil(tree.search(value: intervaln4))
    }

    // returns set of intervals that overlap with the given reference interval
    func testOverlaps() throws {
        let interval0 = try! Interval<Int>(start: 15, end: 20)
        let intervalNode0 = IntervalTreeNode(value: interval0) // root of tree

        let interval1 = try! Interval(start: 10, end: 16)
        let intervalNode1 = IntervalTreeNode(value: interval1) // the test interval

        let interval2 = try! Interval(start: 21, end: 23)
        let intervalNode2 = IntervalTreeNode(value: interval2) // the test interval

        //let tree = IntervalTree<Int>.init(intervalNode: intervalNode0)
        let tree = IntervalTree(node: intervalNode0)
        try! tree.insert(node: intervalNode1)
        try! tree.insert(node: intervalNode2)

        tree.draw()

        // Search for intervals that intersect with [14, 16]
        let overlaps: Interval<Int> = try! Interval(start: 14, end: 16)
        let result = tree.overlaps(interval: overlaps)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], interval0)
        XCTAssertEqual(result[1], interval1)
    }

    // returns set of intervals that the given interval is within
    func testWithin() throws {
        let interval0 = try! Interval(start: 15, end: 20)
        let intervalNode0 = IntervalTreeNode(value: interval0) // root of tree
        let tree = IntervalTree(node: intervalNode0)

        let interval1 = try! Interval(start: 10, end: 30)
        let interval2 = try! Interval(start: 16, end: 19)
        let interval3 = try! Interval(start: 5, end: 20)
        let interval4 = try! Interval(start: 12, end: 16)
        let interval5 = try! Interval(start: 30, end: 40)

        // Insert some intervals
        try! tree.insert(node: IntervalTreeNode(value: interval1)) // match
        try! tree.insert(node: IntervalTreeNode(value: interval2))
        try! tree.insert(node: IntervalTreeNode(value: interval3)) // match
        try! tree.insert(node: IntervalTreeNode(value: interval4)) // match
        try! tree.insert(node: IntervalTreeNode(value: interval5))
        tree.draw()

        // Search for intervals that intersect with [14, 16]
        let result = tree.within(interval: try! Interval(start: 14, end: 16))
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], interval1)
        XCTAssertEqual(result[1], interval3)
        XCTAssertEqual(result[2], interval4)
    }

    /*
     Returns the leftmost descendent of tree:
     */
    func test_min_tree() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, interval0)
        XCTAssertEqual(n0?.left?.value, interval1)
        XCTAssertEqual(n0?.right?.value, interval2)
        XCTAssertEqual(n0?.right?.left?.value, interval3)
        XCTAssertEqual(n0?.right?.right?.value, interval4)

        let tree_min = tree.minimum()?.value
        XCTAssertEqual(interval1, tree_min)
        XCTAssertEqual(interval1.start, -5)
        XCTAssertEqual(interval1.end, 5)
    }

    /*
     Returns the leftmost descendent of given node. O(h) time.
     */
    func test_min_node() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, interval0)
        XCTAssertEqual(n0?.left?.value, interval1)
        XCTAssertEqual(n0?.right?.value, interval2)
        XCTAssertEqual(n0?.right?.left?.value, interval3)
        XCTAssertEqual(n0?.right?.right?.value, interval4)

        // node not in tree
        let null_node = try! IntervalTreeNode(value: Interval(start: 0, end: 0))
        XCTAssertEqual(tree.minimum(node: null_node)?.value, null_node.value, "minimum of node that is not in tree is itself")

        // node in tree
        let root = tree.root!
        tree.draw()
        XCTAssertEqual(interval1, tree.minimum(node: root)?.value)
        XCTAssertEqual(interval3, tree.minimum(node: root.right!)?.value)
        XCTAssertEqual(interval1, tree.minimum(node: root.left!)?.value, "max of min leaf is self")
        XCTAssertEqual(interval3, tree.minimum(node: root.right!.left!)?.value, "max of right min leaf is self")
    }

    /*
     Returns the rightmost descendent of tree. O(h) time.
     */
    func test_max_tree() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, interval0)
        XCTAssertEqual(n0?.left?.value, interval1)
        XCTAssertEqual(n0?.right?.value, interval2)
        XCTAssertEqual(n0?.right?.left?.value, interval3)
        XCTAssertEqual(n0?.right?.right?.value, interval4)

        // tree max
        XCTAssertEqual(interval4, tree.maximum()?.value)
        XCTAssertEqual(interval4.start, 12)
        XCTAssertEqual(interval4.end, 15)
    }

    /*
     Returns the rightmost descendent of given node. O(h) time.
     */
    func test_max_node() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, interval0)
        XCTAssertEqual(n0?.left?.value, interval1)
        XCTAssertEqual(n0?.right?.value, interval2)
        XCTAssertEqual(n0?.right?.left?.value, interval3)
        XCTAssertEqual(n0?.right?.right?.value, interval4)

        // node not in tree
        let null_node = try! IntervalTreeNode(value: Interval(start: 0, end: 0))
        XCTAssertEqual(tree.maximum(node: null_node)?.value, null_node.value, "maximum of node that is not in tree is itself")

        // node in tree
        let root = tree.root!
        XCTAssertEqual(interval4, tree.maximum(node: root)?.value)
        XCTAssertEqual(interval4, tree.maximum(node: root.right!)?.value)
        XCTAssertEqual(interval1, tree.maximum(node: root.left!)?.value, "max of min leaf is self")
        XCTAssertEqual(interval3, tree.maximum(node: root.right!.left!)?.value, "max of right min leaf is self")
    }

    // map takes function: (BinarySearchTree) -> BinarySearchTree) and returns [BinarySearchTreeNode<T>]
    func testMap() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()

        // first, lets just pass through the node values
        let r0 = tree.map({$0})

        // XCTAssertEqual(r0, [[-5, 5], [5, 10], [7, 9], [8, 12], [12, 15]])
        XCTAssertEqual(r0, [interval1, interval0, interval3, interval2, interval4])

        // now let's apply a mutation function - using the BinarySearchTree class implementation of map
        let r1 = tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2) }
        let m_interval0 = try! Interval(start: 10, end: 20)
        let m_interval1 = try! Interval(start: -10, end: 10)
        let m_interval2 = try! Interval(start: 16, end: 24)
        let m_interval3 = try! Interval(start: 14, end: 18)
        let m_interval4 = try! Interval(start: 24, end: 30)
        XCTAssertEqual(r1, [m_interval1, m_interval0, m_interval3, m_interval2, m_interval4])

        // assert that tree has been updated
        XCTAssertEqual(tree.root?.value, m_interval0)
        XCTAssertEqual(tree.root?.left?.value, m_interval1)
        XCTAssertEqual(tree.root?.right?.value, m_interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, m_interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, m_interval4)
    }

    // flatMap is a shortcut for tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2) }
    func testFlatMap() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()

        // now let's apply a mutation function - using the BinarySearchTree class implementation of map
        let r1 = tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2) }
        let m_interval0 = try! Interval(start: 10, end: 20)
        let m_interval1 = try! Interval(start: -10, end: 10)
        let m_interval2 = try! Interval(start: 16, end: 24)
        let m_interval3 = try! Interval(start: 14, end: 18)
        let m_interval4 = try! Interval(start: 24, end: 30)
        XCTAssertEqual(r1, [m_interval1, m_interval0, m_interval3, m_interval2, m_interval4])

        // flatMap is the shorthand notation (starting values are after map applied above)
        let r2  = tree.flatMap({ 2 * $0 })
        let fm_interval0 = try! Interval(start: 20, end: 40)
        let fm_interval1 = try! Interval(start: -20, end: 20)
        let fm_interval2 = try! Interval(start: 32, end: 48)
        let fm_interval3 = try! Interval(start: 28, end: 36)
        let fm_interval4 = try! Interval(start: 48, end: 60)
        tree.draw()
        XCTAssertEqual(r2, [fm_interval1, fm_interval0, fm_interval3, fm_interval2, fm_interval4])

        // assert that tree has been updated
        XCTAssertEqual(tree.root?.value, fm_interval0)
        XCTAssertEqual(tree.root?.left?.value, fm_interval1)
        XCTAssertEqual(tree.root?.right?.value, fm_interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, fm_interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, fm_interval4)
    }

    func testPredecessor() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.traverseInOrder(completion: { print($0) })

        // assert tree structure
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertEqual(tree.root?.left?.value, interval1)
        XCTAssertEqual(tree.root?.right?.value, interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, interval4)

        // min has no predecessor
        let min = tree.minimum()
        XCTAssertEqual(min?.value, interval1)
        XCTAssertNil(tree.predecessor(value: min!.value))
        let max = tree.maximum()
        XCTAssertEqual(max?.value, interval4)
        XCTAssertEqual(tree.predecessor(value: max!.value), interval2)
    }

    func testSuccessor() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        tree.traverseInOrder(completion: { print($0) })

        // assert tree structure
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertEqual(tree.root?.left?.value, interval1)
        XCTAssertEqual(tree.root?.right?.value, interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, interval4)

        // max has no successor
        let max = tree.maximum()
        XCTAssertEqual(max?.value, interval4)
        XCTAssertNil(tree.successor(value: max!.value))
        // min has node successor
        let min = tree.minimum()
        XCTAssertEqual(min?.value, interval1)
        XCTAssertEqual(tree.successor(value: min!.value), interval0)
    }

    func testTraverseInOrder() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        var arr: [Interval<Int>] = [Interval<Int>]()
        tree.traverseInOrder(completion: { arr.append($0) })
        XCTAssertEqual(arr, [interval1, interval0, interval3, interval2, interval4])
    }

    func testSubscripting() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        let intervalNP = try! Interval(start: 5, end: 11) // not in tree
        tree.draw()

        // get values
        XCTAssertEqual(tree[interval0]?.value, interval0)
        XCTAssertEqual(tree[interval1]?.value, interval1)
        XCTAssertEqual(tree[interval2]?.value, interval2)
        XCTAssertEqual(tree[interval3]?.value, interval3)
        XCTAssertEqual(tree[interval4]?.value, interval4)
        XCTAssertEqual(tree[intervalNP]?.value, nil, "value not in tree")

        // change values using subscripts
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        tree[interval0]?.value = intervalNP // edit tree root
        XCTAssertNil(tree.search(value: interval0))
        XCTAssertNotNil(tree.search(value: intervalNP))
        XCTAssertEqual(tree.root?.value, intervalNP)
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        tree.draw()

        // edit root interval in place
        XCTAssertEqual(tree.root?.value, intervalNP)
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        tree[intervalNP]?.value.start = interval0.start
        tree[intervalNP]?.value.end = interval0.end
        tree.draw()
        XCTAssertNil(tree.search(value: intervalNP))
        XCTAssertNotNil(tree.search(value: interval0))
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        tree.draw()
        
        // insert new value (might cause tree imbalance)
        tree[intervalNP] = nil // assignment to nil is required else this is a get value
        XCTAssertNotNil(tree.search(value: intervalNP))
        XCTAssertTrue(tree.size == 6)
        XCTAssertTrue(tree.height() == 4)
        tree.draw()
    }

    // since we inherit from AVLTree, a deletion might rebalance tree
    func testDeleteIntervals() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree<Int>(array: [interval0, interval1, interval2, interval3, interval4])
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.size == tree.toArray().count)
        XCTAssertTrue(tree.height() == 3)

        // tree structure
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertEqual(tree.root?.parent, nil)
        XCTAssertEqual(tree.root?.left?.value, interval1)
        XCTAssertEqual(tree.root?.left?.parent?.value, interval0)
        XCTAssertEqual(tree.root?.right?.value, interval2)
        XCTAssertEqual(tree.root?.right?.parent?.value, interval0)
        XCTAssertEqual(tree.root?.right?.left?.value, interval3)
        XCTAssertEqual(tree.root?.right?.left?.parent?.value, interval2)
        XCTAssertEqual(tree.root?.right?.right?.value, interval4)
        XCTAssertEqual(tree.root?.right?.right?.parent?.value, interval2)
        tree.draw() // ([-5, 5]? <- [5, 10] -> ([7, 9]? <- [8, 12] -> [12, 15]?))

        // remove leaf - note autobalance
        let removedNode = tree.remove(value: interval1) // [-5, 5]
        tree.drawParents()
        XCTAssertFalse(removedNode!.hasAnyChild)
        XCTAssertNil(removedNode!.parent)

        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: interval1))
        // check structure
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.size == tree.toArray().count)
        XCTAssertTrue(tree.height() == 3)
        XCTAssertEqual(tree.root?.value, interval2)
        XCTAssertEqual(tree.root?.right?.value, interval4)
        XCTAssertEqual(tree.root?.left?.value, interval0)
        XCTAssertEqual(tree.root?.left?.right?.value, interval3)
        tree.draw() // (({5, 10}:10 -> {7, 9}:9?) <- {8, 12}*:12 -> {12, 15}:15?)
        // check parents
        XCTAssertNil(tree.root?.parent)
        XCTAssertEqual(tree.root?.right?.parent?.value, interval2)
        XCTAssertEqual(tree.root?.left?.parent?.value, interval2)
        XCTAssertEqual(tree.root?.left?.right?.parent?.value, interval0)

        // remove the root
        _ = tree.remove(value: tree.root!.value) // {8, 12}
        // regression test: this was failing after removal. A node ({7, 9}) was duplicated during remove:
        // (({5, 10}:10 -> {7, 9}:9?) <- {7, 9}:12 -> {12, 15}:15?)
        XCTAssertTrue(tree.size == tree.toArray().count)
        tree.draw() // ({5, 10}:10? <- {7, 9}*:12 -> {12, 15}:15?)
        // assert deleted values are not in tree
        XCTAssertNil(tree.search(value: interval1))
        // check structure
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.size == tree.toArray().count)
        XCTAssertTrue(tree.height() == 2)
        XCTAssertEqual(tree.root?.value, interval3)
        XCTAssertEqual(tree.root?.right?.value, interval4)
        XCTAssertEqual(tree.root?.left?.value, interval0)
        // check parents
        XCTAssertNil(tree.root?.parent)
        XCTAssertEqual(tree.root?.right?.parent?.value, interval3)
        XCTAssertEqual(tree.root?.left?.parent?.value, interval3)
    }

}
