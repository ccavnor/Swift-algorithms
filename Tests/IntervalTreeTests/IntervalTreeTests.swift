import XCTest
import TreeProtocol
@testable import IntervalTree


// TODO: check that IntervalTree is constrained to numeric types - unlike BST: (maybe using T: IEquatable<T>)
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
    func test_Interval_init() {
        let point = try? Interval(start: 1, end: 1)
        XCTAssertEqual(1, point?.start)
        XCTAssertEqual(1, point?.end)
        XCTAssertTrue(type(of: point!.start) == Int.self, "type is unchanged using ints")
        XCTAssertTrue(type(of: point!.end) == Int.self, "type is unchanged using ints")
        XCTAssertEqual(0, point?.length(), "intervals of zero length are allowed")

        let interval0 = try? Interval(start: 0, end: 1)
        XCTAssertEqual(0, interval0?.start)
        XCTAssertEqual(1, interval0?.end)
        XCTAssertTrue(type(of: interval0!.start) == Int.self, "type is unchanged using ints")
        XCTAssertTrue(type(of: interval0!.end) == Int.self, "type is unchanged using ints")
        XCTAssertEqual(1, interval0?.length())

        let interval1 = try? Interval(start: 0.9, end: 1)
        XCTAssertEqual(0.9, interval1?.start)
        XCTAssertEqual(1.0, interval1?.end)
        XCTAssertTrue(type(of: interval1!.start) == Double.self, "type is upcast to double when mixed with int")
        XCTAssertTrue(type(of: interval1!.end) == Double.self, "type is upcast to double when mixed with int")
        XCTAssertEqual(0.1, interval1?.length())

        let interval2 = try? Interval(start: 0.0000, end: 0.0001)
        XCTAssertEqual(0.0000, interval2?.start)
        XCTAssertEqual(0.0001, interval2?.end)
        XCTAssertTrue(type(of: interval2!.start) == Double.self)
        XCTAssertTrue(type(of: interval2!.end) == Double.self)
        XCTAssertEqual(0.0001, interval2?.length(), "ensure that fractional magnitudes are reported correctly")

        let interval3 = try? Interval(start: -1, end: 1)
        XCTAssertEqual(-1, interval3?.start)
        XCTAssertEqual(1, interval3?.end)
        XCTAssertTrue(type(of: interval3!.start) == Int.self)
        XCTAssertTrue(type(of: interval3!.end) == Int.self)
        XCTAssertEqual(2, interval3?.length(), "interval can span from negative to positive")

        let interval4 = try? Interval(start: -4, end: -1)
        XCTAssertEqual(-4, interval4?.start)
        XCTAssertEqual(-1, interval4?.end)
        XCTAssertTrue(type(of: interval4!.start) == Int.self)
        XCTAssertTrue(type(of: interval4!.end) == Int.self)
        XCTAssertEqual(3, interval4?.length(), "interval can span from negative to positive (int)")

        let interval5 = try? Interval(start: -4.2, end: 1.3)
        XCTAssertEqual(-4.2, interval5?.start)
        XCTAssertEqual(1.3, interval5?.end)
        XCTAssertTrue(type(of: interval5!.start) == Double.self)
        XCTAssertTrue(type(of: interval5!.end) == Double.self)
        XCTAssertEqual(5.5, interval5?.length(), "interval can span from negative to positive (double)")

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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 4)

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
        XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        XCTAssertFalse(interval0 === interval0_same)
        XCTAssertTrue(interval0 == interval0_same)
        let interval0_start_same = try! Interval(start: 14, end: 20)
        let interval0_end_same = try! Interval(start: 10, end: 16)
        XCTAssertFalse(interval0 == interval0_start_same)
        XCTAssertFalse(interval0 == interval0_end_same)

        // --- non-equality
        XCTAssertFalse(interval0 != interval0)
        XCTAssertFalse(interval0 != interval0_same)
        XCTAssertTrue(interval0 != interval1)

        // --- gt: reference interval must be to the right of test interval end
        XCTAssertFalse(interval0 > interval0, "overlaps self")
        XCTAssertFalse(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertFalse(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertFalse(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertFalse(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertFalse(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertFalse(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertFalse(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertFalse(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertFalse(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertFalse(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertFalse(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertFalse(interval0 < interval8, "within - single point in middle")
        XCTAssertFalse(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertFalse(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertFalse(interval0 <= interval8, "within - single point in middle")
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
        XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        XCTAssertFalse(interval0 === interval0_same)
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
        XCTAssertFalse(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertFalse(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertFalse(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertFalse(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertFalse(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertFalse(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertFalse(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertFalse(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertFalse(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertFalse(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertFalse(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertFalse(interval0 < interval8, "within - single point in middle")
        XCTAssertFalse(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertFalse(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertFalse(interval0 <= interval8, "within - single point in middle")
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
        XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        XCTAssertFalse(interval0 === interval0_same)
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
        XCTAssertFalse(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertFalse(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertFalse(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertFalse(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertFalse(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertFalse(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertFalse(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertFalse(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertFalse(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertFalse(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertFalse(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertFalse(interval0 < interval8, "within - single point in middle")
        XCTAssertFalse(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertFalse(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertFalse(interval0 <= interval8, "within - single point in middle")
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
        XCTAssertTrue(interval0 === interval0)
        XCTAssertTrue(interval0 == interval0)
        XCTAssertFalse(interval0 === interval0_same)
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
        XCTAssertFalse(interval0 > interval1, "overlaps from left")
        XCTAssertFalse(interval0 > interval2, "overlaps from right")
        XCTAssertFalse(interval0 > interval3, "touches left")
        XCTAssertFalse(interval0 > interval4, "touches right")
        XCTAssertFalse(interval0 > interval5, "within - overlaps start")
        XCTAssertFalse(interval0 > interval6, "within - overlaps end")
        XCTAssertFalse(interval0 > interval7, "within - single point on left")
        XCTAssertFalse(interval0 > interval8, "within - single point in middle")
        XCTAssertFalse(interval0 > interval9, "within - single point on right")
        XCTAssertFalse(interval0 > interval10, "spans left and right")
        XCTAssertFalse(interval0 > interval11, "outside (right)")
        XCTAssertTrue(interval0 > interval12, "outside (left)")

        // --- gte: reference interval must begin at or to the right of test interval end
        XCTAssertTrue(interval0 >= interval0, "overlaps self")
        XCTAssertFalse(interval0 >= interval1, "overlaps from left")
        XCTAssertFalse(interval0 >= interval2, "overlaps from right")
        XCTAssertTrue(interval0 >= interval3, "touches left")
        XCTAssertFalse(interval0 >= interval4, "touches right")
        XCTAssertFalse(interval0 >= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 >= interval6, "within - overlaps end")
        XCTAssertTrue(interval0 >= interval7, "within - single point on left")
        XCTAssertFalse(interval0 >= interval8, "within - single point in middle")
        XCTAssertFalse(interval0 >= interval9, "within - single point on right")
        XCTAssertFalse(interval0 >= interval10, "spans left and right")
        XCTAssertFalse(interval0 >= interval11, "outside (right)")
        XCTAssertTrue(interval0 >= interval12, "outside (left)")

        // --- lt: test interval must be to the right of reference interval end
        XCTAssertFalse(interval0 < interval0, "overlaps self")
        XCTAssertFalse(interval0 < interval1, "overlaps from left")
        XCTAssertFalse(interval0 < interval2, "overlaps from right")
        XCTAssertFalse(interval0 < interval3, "touches left")
        XCTAssertFalse(interval0 < interval4, "touches right")
        XCTAssertFalse(interval0 < interval5, "within - overlaps start")
        XCTAssertFalse(interval0 < interval6, "within - overlaps end")
        XCTAssertFalse(interval0 < interval7, "within - single point on left")
        XCTAssertFalse(interval0 < interval8, "within - single point in middle")
        XCTAssertFalse(interval0 < interval9, "within - single point on right")
        XCTAssertFalse(interval0 < interval10, "spans left and right")
        XCTAssertTrue(interval0 < interval11, "outside (right)")
        XCTAssertFalse(interval0 < interval12, "outside (left)")

        // --- lte: test interval must begin at or to the right of reference interval end
        XCTAssertTrue(interval0 <= interval0, "overlaps self")
        XCTAssertFalse(interval0 <= interval1, "overlaps from left")
        XCTAssertFalse(interval0 <= interval2, "overlaps from right")
        XCTAssertFalse(interval0 <= interval3, "touches left")
        XCTAssertTrue(interval0 <= interval4, "touches right")
        XCTAssertFalse(interval0 <= interval5, "within - overlaps start")
        XCTAssertFalse(interval0 <= interval6, "within - overlaps end")
        XCTAssertFalse(interval0 <= interval7, "within - single point on left")
        XCTAssertFalse(interval0 <= interval8, "within - single point in middle")
        XCTAssertTrue(interval0 <= interval9, "within - single point on right")
        XCTAssertFalse(interval0 <= interval10, "spans left and right")
        XCTAssertTrue(interval0 <= interval11, "outside (right)")
        XCTAssertFalse(interval0 <= interval12, "outside (left)")
    }

// ==============================
// Test IntervalNode
// ==============================
    func test_isOverlapping_positive () {
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
        let intervalNode0 = IntervalNode(interval: interval0) // the test interval
        let intervalNode1 = IntervalNode(interval: interval1) // overlaps from left
        let intervalNode2 = IntervalNode(interval: interval2) // overlaps from right
        let intervalNode3 = IntervalNode(interval: interval3) // touches left
        let intervalNode4 = IntervalNode(interval: interval4) // touches right
        let intervalNode5 = IntervalNode(interval: interval5) // within - overlaps start
        let intervalNode6 = IntervalNode(interval: interval6) // within - overlaps end
        let intervalNode7 = IntervalNode(interval: interval7) // within - single point on left
        let intervalNode8 = IntervalNode(interval: interval8) // within - single point in middle
        let intervalNode9 = IntervalNode(interval: interval9) // within - single point on right
        let intervalNode10 = IntervalNode(interval: interval10) // spans (left and right)
        let intervalNode11 = IntervalNode(interval: interval11) // outside (right)
        let intervalNode12 = IntervalNode(interval: interval12) // outside (left)

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
        let intervalNode0 = IntervalNode(interval: interval0) // the test interval
        let intervalNode1 = IntervalNode(interval: interval1) // overlaps from left
        let intervalNode2 = IntervalNode(interval: interval2) // overlaps from right
        let intervalNode3 = IntervalNode(interval: interval3) // touches left
        let intervalNode4 = IntervalNode(interval: interval4) // touches right
        let intervalNode5 = IntervalNode(interval: interval5) // within - overlaps start
        let intervalNode6 = IntervalNode(interval: interval6) // within - overlaps end
        let intervalNode7 = IntervalNode(interval: interval7) // within - single point on left
        let intervalNode8 = IntervalNode(interval: interval8) // within - single point in middle
        let intervalNode9 = IntervalNode(interval: interval9) // within - single point on right
        let intervalNode10 = IntervalNode(interval: interval10) // spans (left and right)
        let intervalNode11 = IntervalNode(interval: interval11) // outside (right)
        let intervalNode12 = IntervalNode(interval: interval12) // outside (left)

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
        let intervalNode0 = IntervalNode(interval: interval0) // the test interval
        let intervalNode1 = IntervalNode(interval: interval1) // overlaps from left
        let intervalNode2 = IntervalNode(interval: interval2) // overlaps from right
        let intervalNode3 = IntervalNode(interval: interval3) // touches left
        let intervalNode4 = IntervalNode(interval: interval4) // touches right
        let intervalNode5 = IntervalNode(interval: interval5) // within - overlaps start
        let intervalNode6 = IntervalNode(interval: interval6) // within - overlaps end
        let intervalNode7 = IntervalNode(interval: interval7) // within - single point on left
        let intervalNode8 = IntervalNode(interval: interval8) // within - single point in middle
        let intervalNode9 = IntervalNode(interval: interval9) // within - single point on right
        let intervalNode10 = IntervalNode(interval: interval10) // spans (left and right)
        let intervalNode11 = IntervalNode(interval: interval11) // outside (right)
        let intervalNode12 = IntervalNode(interval: interval12) // outside (left)

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
        let intervalNode0 = IntervalNode(interval: interval0) // the test interval
        let intervalNode1 = IntervalNode(interval: interval1) // overlaps from left
        let intervalNode2 = IntervalNode(interval: interval2) // overlaps from right
        let intervalNode3 = IntervalNode(interval: interval3) // touches left
        let intervalNode4 = IntervalNode(interval: interval4) // touches right
        let intervalNode5 = IntervalNode(interval: interval5) // within - overlaps start
        let intervalNode6 = IntervalNode(interval: interval6) // within - overlaps end
        let intervalNode7 = IntervalNode(interval: interval7) // within - single point on left
        let intervalNode8 = IntervalNode(interval: interval8) // within - single point in middle
        let intervalNode9 = IntervalNode(interval: interval9) // within - single point on right
        let intervalNode10 = IntervalNode(interval: interval10) // spans (left and right)
        let intervalNode11 = IntervalNode(interval: interval11) // outside (right)
        let intervalNode12 = IntervalNode(interval: interval12) // outside (left)

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

    // overlap for tree returns set of overlapping intervals for the given reference interval
    func testOverlaps() throws {
        let interval0 = try! Interval(start: 15, end: 20)
        let intervalNode0 = IntervalNode(interval: interval0) // root of tree

        let interval1 = try! Interval(start: 10, end: 16)
        let intervalNode1 = IntervalNode(interval: interval1) // the test interval

        let interval2 = try! Interval(start: 21, end: 23)
        let intervalNode2 = IntervalNode(interval: interval2) // the test interval

        //let tree = IntervalTree<Int>.init(intervalNode: intervalNode0)
        let tree = IntervalTree(intervalNode: intervalNode0)
        try! tree.insert(value: intervalNode1.value)
        try! tree.insert(value: intervalNode2.value)

        tree.draw()

        // Search for intervals that intersect with [14, 16]
        let overlaps: Interval<Int> = try! Interval(start: 14, end: 16)
        let result = tree.overlaps(interval: overlaps)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].start, 15)
        XCTAssertEqual(result[0].end, 20)
        XCTAssertEqual(result[1].start, 10)
        XCTAssertEqual(result[1].end, 16)
    }

    /*
     * tree root is [15,20]*
     (([5,20] <- [10,30] -> [12,16]) <- [15,20] -> [16,19] -> [30,40]))
     */
    // with for tree returns set of intervals within the given reference interval
    func testWithin() throws {
        let interval0 = try! Interval(start: 15, end: 20)
        let intervalNode0 = IntervalNode(interval: interval0) // root of tree
        let tree = IntervalTree(intervalNode: intervalNode0)

        // Insert some intervals
        try! tree.insert(value: Interval(start: 15, end: 20))
        try! tree.insert(value: Interval(start: 10, end: 30)) // match
        try! tree.insert(value: Interval(start: 16, end: 19))
        try! tree.insert(value: Interval(start: 5, end: 20)) // match
        try! tree.insert(value: Interval(start: 12, end: 16)) // match
        try! tree.insert(value: Interval(start: 30, end: 40))
        tree.draw()

        // Search for intervals that intersect with [14, 16]
        let result = tree.within(interval: try! Interval(start: 14, end: 16))
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].start, 10)
        XCTAssertEqual(result[0].end, 30)
        XCTAssertEqual(result[1].start, 5)
        XCTAssertEqual(result[1].end, 20)
        XCTAssertEqual(result[2].start, 12)
        XCTAssertEqual(result[2].end, 16)
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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
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
        let null_node = try! IntervalNode(interval: Interval(start: 0, end: 0))
        XCTAssertNil(tree.minimum(node: null_node)?.value)

        // node in tree
        let root = tree.root!
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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
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
    //public func maximum(node: BinarySearchTreeNode<T>) -> BinarySearchTreeNode<T>?
    func test_max_node() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
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
        let null_node = try! IntervalNode(interval: Interval(start: 0, end: 0))
        XCTAssertNil(tree.maximum(node: null_node)?.value)

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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()

        // first, lets just pass through the node values
        let r0 = tree.map({$0})
   
        //XCTAssertEqual(r0, [[-5, 5], [5, 10], [7, 9], [8, 12], [12, 15]])
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
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
        tree.draw()

        // now let's apply a mutation function - using the BinarySearchTree class implementation of map
        //let r1 = tree.map { try! Interval(start: $0.start * 2, end: $0.end * 2) }
        let m_interval0 = try! Interval(start: 10, end: 20)
        let m_interval1 = try! Interval(start: -10, end: 10)
        let m_interval2 = try! Interval(start: 16, end: 24)
        let m_interval3 = try! Interval(start: 14, end: 18)
        let m_interval4 = try! Interval(start: 24, end: 30)
        //XCTAssertEqual(r1, [m_interval1, m_interval0, m_interval3, m_interval2, m_interval4])

        // this is using the shorthand notation
        let r2  = tree.flatMap({ 2 * $0 })
        tree.draw()
        XCTAssertEqual(r2, [m_interval1, m_interval0, m_interval3, m_interval2, m_interval4])

        // assert that tree has been updated
        XCTAssertEqual(tree.root?.value, m_interval0)
        XCTAssertEqual(tree.root?.left?.value, m_interval1)
        XCTAssertEqual(tree.root?.right?.value, m_interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, m_interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, m_interval4)
    }

    func testDeleteIntervals() {
        let interval0 = try! Interval(start: 5, end: 10)
        let interval1 = try! Interval(start: -5, end: 5)
        let interval2 = try! Interval(start: 8, end: 12)
        let interval3 = try! Interval(start: 7, end: 9)
        let interval4 = try! Interval(start: 12, end: 15)
        let tree = IntervalTree(array: [interval0, interval1, interval2, interval3, interval4])
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        XCTAssertEqual(tree.root?.value, interval0)
        XCTAssertEqual(tree.root?.left?.value, interval1)
        XCTAssertEqual(tree.root?.right?.value, interval2)
        XCTAssertEqual(tree.root?.right?.left?.value, interval3)
        XCTAssertEqual(tree.root?.right?.right?.value, interval4)
        tree.draw()

        // tree is now: ([-5, 5]:5? <- [5, 10]:15 -> ([7, 9]:9? <- [8, 12]:15 -> [12, 15]:15?))
        // remove leaf - note autobalance
        tree.remove(value: interval1) // [-5, 5]
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.height() == 3)
        XCTAssertEqual(tree.root?.value, interval3)
        XCTAssertEqual(tree.root?.left?.value, interval0)
        XCTAssertEqual(tree.root?.right?.value, interval2)
        XCTAssertNil(tree.root?.right?.left?.value)
        XCTAssertEqual(tree.root?.right?.right?.value, interval4)
        tree.draw()

        // tree is now: ([5, 10]:15 -> ([7, 9]:9? <- [8, 12]:15 -> [12, 15]:15?))
        // remove the root - note autobalance
        tree.remove(value: tree.root!.value) // [7,9]
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.height() == 2)
        XCTAssertEqual(tree.root?.value.start, 8) // [8,12]
        XCTAssertEqual(tree.root?.left?.value, interval0)
        XCTAssertEqual(tree.root?.right?.value, interval4)
        XCTAssertNil(tree.root?.right?.left?.value)
        XCTAssertNil(tree.root?.right?.right?.value)
        tree.draw()

        // tree is now: ([5, 10]:9? <- [8, 12]:15 -> [12, 15]:15?)
        // remove inner node (root, since tree rebalanced)
        tree.remove(value: tree.root!.value) // [8, 12]
        XCTAssertTrue(tree.size == 2)
        XCTAssertTrue(tree.height() == 2)
        XCTAssertNotEqual(tree.root?.value.start, 8)
        XCTAssertNil(tree.root?.left?.value)
        XCTAssertEqual(tree.root?.right?.value, interval4)
        tree.draw()
    }

}
