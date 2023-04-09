//
//  TimeTreeTests.swift
//  
//
//  Created by Christopher Charles Cavnor on 3/4/23.
//

import XCTest
import Foundation // for Date, DateTimeInterval
import DateHelper
import TreeProtocol
//import AVLTree
@testable import TimeIntervalTree

final class TimeTimeIntervalTreeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // ==============================
    // Test TimeInterval
    // ==============================

    func test_TimeInterval_init() {
        let now = Date()
        let then = now + 30

        let point = try? Interval<Date>(start: now, end: now)
        XCTAssertEqual(now, point?.start)
        XCTAssertEqual(now, point?.end)
        XCTAssertTrue(type(of: point!.start) == Date.self)
        XCTAssertTrue(type(of: point!.end) == Date.self)

        let interval0 = try? Interval<Date>(start: now, end: then)
        XCTAssertEqual(now, interval0?.start)
        XCTAssertEqual(then, interval0?.end)
        XCTAssertTrue(type(of: interval0!.start) == Date.self, "type is unchanged using dates")
        XCTAssertTrue(type(of: interval0!.end) == Date.self, "type is unchanged using dates")

        XCTAssertThrowsError(try Interval<Date>(start: then, end: now)) { error in
            XCTAssertEqual(error as! TreeError, TreeError.invalidInterval, "end of interval must be greater than start")
        }
    }

    func testCreateFromArray() {
        let date0 = Date.init(detectFromString: "today")!
        let date1 = Date.init(detectFromString: "tomorrow")!
        let date2 = Date.init(detectFromString: "yesterday")!
        let date3 = Date.init(detectFromString: "last Tuesday")!
        let date4 = Date.init(detectFromString: "next Tuesday")!

        let interval0 = try! Interval<Date>(start: date0, end: date0) // now
        let interval1 = try! Interval<Date>(start: date0, end: date1) // 1 day
        let interval2 = try! Interval<Date>(start: date3, end: date4) // one week
        let interval3 = try! Interval<Date>(start: date2, end: date1) // two days
        let tree = TimeIntervalTree<Date>(array: [interval0, interval1, interval2, interval3])
        tree.draw()
        XCTAssertEqual(tree.size, 4)
        XCTAssertEqual(tree.height(), 3)
        tree.display(node: tree.root!)

        let i0 = tree.search(value: interval0)!
        XCTAssertEqual(i0.value.start, date0)
        XCTAssertEqual(i0.value.end, date0)
        let i1 = tree.search(value: interval1)!
        XCTAssertEqual(i1.value.start, date0)
        XCTAssertEqual(i1.value.end, date1)
        let i2 = tree.search(value: interval2)!
        XCTAssertEqual(i2.value.start, date3)
        XCTAssertEqual(i2.value.end, date4)
        let i3 = tree.search(value: interval3)!
        XCTAssertEqual(i3.value.start, date2)
        XCTAssertEqual(i3.value.end, date1)
    }

    func testDateComparables() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        // equality
        XCTAssertTrue(today == today)
        XCTAssertFalse(today != today)

        // < and >
        XCTAssertTrue(today < tomorrow)
        XCTAssertFalse(tomorrow < today)
        XCTAssertTrue(yesterday < tomorrow)
        XCTAssertTrue(last_tues < next_tues)
        XCTAssertTrue(tomorrow > today)
        XCTAssertTrue(today > yesterday)

        // <= and >=
        XCTAssertTrue(today <= today)
        XCTAssertTrue(today >= today)
        XCTAssertFalse(tomorrow <= today)
        XCTAssertTrue(tomorrow >= today)
    }


    // test the AdditiveArithmetic extensions
    func testDateAdditiveArithmatic() {
        let now: Date = Date()
        let then: Date = now + 30 // add 30 seconds
        //let then: Date = now.adjust(second: 30)! // using DateHelper fails (filed bug report)

        print("NOW: \(now.toString(dateStyle: .full, timeStyle: .full)!)")
        print("THEN: \(then.toString(dateStyle: .full, timeStyle: .full)!)")

        // --- addition
        // using Date + Date -> Date
        let plus_now_now: Date = now + now
        let plus_now_then: Date = now + then
        let plus_then_now: Date = then + now
        print(now.timeIntervalSinceReferenceDate)
        print(plus_now_now.timeIntervalSinceReferenceDate)
        print(plus_now_then.timeIntervalSinceReferenceDate)
        print(plus_then_now.timeIntervalSinceReferenceDate)
        XCTAssertEqual(now, plus_now_now, "addition of same dates yields that date")
        XCTAssertEqual(then, plus_now_then, "addition of different dates yields later date")
        XCTAssertEqual(plus_now_then, plus_then_now, "addition is commutative")

        // using Date + Date -> TimeTimeInterval
        let plus_ti_now: TimeInterval = now.timeIntervalSinceReferenceDate
        let plus_ti_then: TimeInterval = then.timeIntervalSinceReferenceDate
        let plus_ti_now_now: TimeInterval = plus_ti_now
        let plus_ti_now_then: TimeInterval = plus_ti_then
        let plus_ti_then_now: TimeInterval = plus_ti_then

        XCTAssertEqual(plus_ti_now, plus_ti_now_now)
        XCTAssertEqual(plus_ti_then, plus_ti_now_then)
        XCTAssertEqual(plus_ti_now_then, plus_ti_then_now, "addition is commutative")
        //print((now + then).toString(dateStyle: .full, timeStyle: .full)!)

        // --- subtraction
        // using using Date - Date -> Date
        let minus_now_now: Date = now - now
        XCTAssertEqual(now, minus_now_now)
        let minus_now_then: Date = now - then // expect + 30 sec so now -> then
        let minus_then_now: Date = then - now // expect - 30 sec so then -> now
        XCTAssertEqual(then, minus_now_then)
        XCTAssertEqual(now, minus_then_now)
        XCTAssertNotEqual(minus_now_then, minus_then_now, "subtraction is not commutative")

        // using Date - Date -> TimeTimeInterval
        let minus_ti_now: TimeInterval = now.timeIntervalSinceReferenceDate
        let minus_ti_then: TimeInterval = then.timeIntervalSinceReferenceDate
        let minus_ti_now_now: TimeInterval = minus_ti_now
        let minus_ti_now_then: TimeInterval = minus_ti_then
        let minus_ti_then_now: TimeInterval = minus_ti_now

        XCTAssertEqual(minus_ti_now, minus_ti_now_now)
        XCTAssertEqual(minus_ti_then, minus_ti_now_then)
        XCTAssertNotEqual(minus_ti_now_then, minus_ti_then_now, "subtraction is not commutative")
    }

// ==============================
// Test TimeIntervalNode
// ==============================

//    func test_TimeIntervalNode_math() {
//        fatalError("TBD")
//    }

    func test_TimeIntervalNode_init() {
        let now = Date()
        let then = now + 30

        let din0 = TimeIntervalNode<Date>(start: now, end: then)
        let tree = TimeIntervalTree<Date>(node: din0)
        XCTAssertTrue(din0.value.start == now)
        XCTAssertTrue(din0.value.end == then)
        XCTAssertEqual(din0.length, 30)

        XCTAssertTrue(tree.size == 1)
        XCTAssertTrue(tree.height() == 1)

        XCTAssertTrue(tree.contains(value: din0.value))
        XCTAssertTrue(tree.search(value: din0.value) == din0)
    }

    // Interval comparable rules:
    // ==: intervals begin and end at same values
    // !=: intervals strictly do not overlap
    // lt: true when a.start < b.start or a.start == b.start and a.end < b.end
    // lte: true when a.start < b.start or a.start == b.start but a.end < b.end or a == b
    // gt: true when a.start > b.start or a.start == b.start and a.end > b.end
    // gte: true when a.start > b.start or a.start == b.start but a.end > b.end or a == b
    func test_TimeIntervalNode_comparables() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = TimeIntervalNode<Date>(start: today, end: today)
        let today_tomorrow = TimeIntervalNode<Date>(start: today, end: tomorrow) // overlaps today on start
        let yesterday_today = TimeIntervalNode<Date>(start: yesterday, end: today) // overlaps today on right
        let yesterday_tomorrow = TimeIntervalNode<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = TimeIntervalNode<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = TimeIntervalNode<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = TimeIntervalNode<Date>(start: last_tues, end: yesterday) // strictly before today

        XCTAssertTrue(today_today == today_today)
        XCTAssertFalse(today_today != today_today)
        XCTAssertTrue(today_today < tomorrow_next_tues)
        XCTAssertFalse(tomorrow_next_tues < today_today)
        XCTAssertTrue(today_today < today_tomorrow)

        XCTAssertTrue(today_today <= today_today)
        XCTAssertTrue(today_today >= today_today)

        XCTAssertTrue(today_today <= today_tomorrow)
        XCTAssertFalse(today_today >= today_tomorrow)

        XCTAssertFalse(today_today > tomorrow_next_tues)
        XCTAssertTrue(lastTues_yesterday < today_today)
        XCTAssertTrue(tomorrow_next_tues > today_today)

        XCTAssertTrue(lastTues_yesterday < tomorrow_next_tues)
        XCTAssertTrue(tomorrow_next_tues > today_today)

        XCTAssertFalse(today_today < yesterday_tomorrow) // today is > yesterday, today < tomorrow
        XCTAssertFalse(today_today < lastTues_nextTues) //
        XCTAssertTrue(today_today > yesterday_tomorrow) //
        XCTAssertTrue(today_today > lastTues_nextTues) //
    }


// ==============================
// Test TimeIntervalTree
// ==============================

    func testTreeInsertion() {

        // implement using insert() and make sure that dates are ordered correctly


        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree = TimeIntervalTree<Date>(array: [today_today,
                                             today_tomorrow,
                                             yesterday_tomorrow,
                                             tomorrow_next_tues,
                                             lastTues_nextTues,
                                             lastTues_yesterday
                                            ])
        tree.draw()
        tree.display(node: tree.root!)
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 4)

        // ensure that nodes are in expected positions
        XCTAssertEqual(tree.root?.value, today_today)
        XCTAssertEqual(tree.root?.left?.value, yesterday_tomorrow)
        XCTAssertEqual(tree.root?.left?.left?.value, lastTues_nextTues)
        XCTAssertEqual(tree.root?.left?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(tree.root?.right?.value, today_tomorrow)
        XCTAssertEqual(tree.root?.right?.right?.value, tomorrow_next_tues)
    }

    func testAutoBalance() {
        // insert an inorder series of increasing, non-overlapping dates and check that they are balanced and not all right children
        let today = Date.init(detectFromString: "today")!
        let oneDay = TimeInterval(exactly: 60 * 60 * 24)
        let today_plus_24_hours = (today + oneDay!)
        let today_plus_48_hours = (today + 2*oneDay!)
        let today_plus_72_hours = (today + 3*oneDay!)
        let today_plus_96_hours = (today + 4*oneDay!)

        let today_today = try! Interval<Date>(start: today, end: today)
        let plus_24 = try! Interval<Date>(start: today_plus_24_hours, end: today_plus_24_hours)
        let plus_48 = try! Interval<Date>(start: today_plus_48_hours, end: today_plus_48_hours)
        let plus_72 = try! Interval<Date>(start: today_plus_72_hours, end: today_plus_72_hours)
        let plus_96 = try! Interval<Date>(start: today_plus_96_hours, end: today_plus_96_hours)

        var tree = TimeIntervalTree<Date>(array: [today_today,
                                                  plus_24,
                                                  plus_48,
                                                  plus_72,
                                                  plus_96
                                            ])
        tree.draw()
        XCTAssertEqual(tree.size, 5)
        XCTAssertEqual(tree.height(), 3, "height must be less than size if balancing occured")
        XCTAssertEqual(tree.minimum()?.value, today_today)
        XCTAssertEqual(tree.maximum()?.value, plus_96)
        tree.display(node: tree.root!)

        // ensure that nodes are balanced and height property updated
        XCTAssertEqual(tree.root?.value, plus_48)
        XCTAssertEqual(tree.root?.height, 3, "height property of root must match height of tree")

        XCTAssertEqual(tree.root?.left?.value, plus_24)
        XCTAssertEqual(tree.root?.left?.height, 2)
        XCTAssertEqual(tree.root?.left?.left?.value, today_today)
        XCTAssertEqual(tree.root?.left?.left?.height, 1)

        XCTAssertEqual(tree.root?.right?.value, plus_72)
        XCTAssertEqual(tree.root?.right?.height, 2)
        XCTAssertEqual(tree.root?.right?.right?.value, plus_96)
        XCTAssertEqual(tree.root?.right?.right?.height, 1)

        // insert an inorder series of decreasing, overlapping dates and check that they are balanced and not all left children
        let today_minus_24_hours = (today - oneDay!)
        let today_minus_48_hours = (today - 2*oneDay!)
        let today_minus_72_hours = (today - 3*oneDay!)
        let today_minus_96_hours = (today - 4*oneDay!)

        let today_minus_24 = try! Interval<Date>(start: today_minus_24_hours, end: today)
        let minus_48 = try! Interval<Date>(start: today_minus_48_hours, end: today)
        let minus_72 = try! Interval<Date>(start: today_minus_72_hours, end: today)
        let minus_96 = try! Interval<Date>(start: today_minus_96_hours, end: today)

        tree = TimeIntervalTree<Date>(array: [today_minus_24,
                                                  minus_48,
                                                  minus_72,
                                                  minus_96
                                            ])
        tree.draw()
        XCTAssertEqual(tree.size, 4)
        XCTAssertEqual(tree.height(), 3, "height must be less than size if balancing occured")
        XCTAssertEqual(tree.minimum()?.value, minus_96)
        XCTAssertEqual(tree.maximum()?.value, today_minus_24)
        tree.display(node: tree.root!)

        // ensure that nodes are balanced and height property updated
        XCTAssertEqual(tree.root?.value, minus_48)
        XCTAssertEqual(tree.root?.height, 3, "height property of root must match height of tree")

        XCTAssertEqual(tree.root?.left?.value, minus_72)
        XCTAssertEqual(tree.root?.left?.height, 2)
        XCTAssertEqual(tree.root?.left?.left?.value, minus_96)
        XCTAssertEqual(tree.root?.left?.left?.height, 1)

        XCTAssertEqual(tree.root?.right?.value, today_minus_24)
        XCTAssertEqual(tree.root?.right?.height, 1)
    }

    func testSearch() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree = TimeIntervalTree<Date>(array: [today_today,
                                             today_tomorrow,
                                             yesterday_tomorrow,
                                             tomorrow_next_tues,
                                             lastTues_nextTues,
                                             lastTues_yesterday
                                            ])
        tree.draw()
        tree.display(node: tree.root!)
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 4)

        // check tree structure
        XCTAssertEqual(tree.root?.value, today_today)
        XCTAssertEqual(tree.root?.left?.value, yesterday_tomorrow)
        XCTAssertEqual(tree.root?.left?.left?.value, lastTues_nextTues)
        XCTAssertEqual(tree.root?.left?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(tree.root?.right?.value, today_tomorrow)
        XCTAssertEqual(tree.root?.right?.right?.value, tomorrow_next_tues)

        // !!!!!! above tree tests correctly, but searching thinks that tree.root?.left?.left? is lastTues_nextTues
        let i0 = tree.search(value: today_today)!
        let i1 = tree.search(value: today_tomorrow)!
        let i2 = tree.search(value: yesterday_tomorrow)!
        let i3 = tree.search(value: tomorrow_next_tues)!
        let i4 = tree.search(value: lastTues_nextTues)!
        let i5 = tree.search(value: lastTues_yesterday)! // root left left

        XCTAssertEqual(i0.value, today_today)
        XCTAssertEqual(i1.value, today_tomorrow)
        XCTAssertEqual(i2.value, yesterday_tomorrow)
        XCTAssertEqual(i3.value, tomorrow_next_tues)
        XCTAssertEqual(i4.value, lastTues_nextTues)
        XCTAssertEqual(i5.value, lastTues_yesterday)

        // search for entities that are not in tree
        let last_thurs = Date.init(detectFromString: "last Thursday")!
        let next_thurs = Date.init(detectFromString: "next Thursday")!

        let intervaln0 = try! Interval<Date>(start: last_thurs, end: yesterday) // strictly left
        let intervaln1 = try! Interval<Date>(start: last_thurs, end: next_thurs) // interval0 is within
        let intervaln2 = try! Interval<Date>(start: tomorrow, end: next_thurs) // strictly right
        let intervaln3 = try! Interval<Date>(start: last_thurs, end: today) // overlaps left
        let intervaln4 = try! Interval<Date>(start: today, end: next_thurs) // overlaps right

        XCTAssertNil(tree.search(value: intervaln0) ?? nil)
        XCTAssertNil(tree.search(value: intervaln1) ?? nil)
        XCTAssertNil(tree.search(value: intervaln2) ?? nil)
        XCTAssertNil(tree.search(value: intervaln3) ?? nil)
        XCTAssertNil(tree.search(value: intervaln4) ?? nil)
    }

    // returns set of intervals overlapping with the given reference interval
    func testOverlaps() throws {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])

        tree.draw()

        // Search for intervals that intersect with today_today
        let result = tree.overlaps(interval: today_today)

        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0], today_today)
        XCTAssertEqual(result[1], yesterday_tomorrow)
        XCTAssertEqual(result[2], lastTues_nextTues)
        XCTAssertEqual(result[3], today_tomorrow)
    }


    // returns set of intervals that the given interval is within
    func testWithin() throws {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])

        tree.draw()

        // Search for intervals that intersect with today_today
        let reference_interval = try! Interval<Date>(start: yesterday, end: tomorrow)
        let result = tree.within(interval: reference_interval)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0], yesterday_tomorrow)
        XCTAssertEqual(result[1], lastTues_nextTues)
    }

    /*
     Returns the leftmost descendent of tree:
     */
    func test_min_tree() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])
        tree.display(node: tree.root!)
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 4)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, today_today)
        XCTAssertEqual(n0?.left?.value, yesterday_tomorrow)
        XCTAssertEqual(n0?.left?.left?.value, lastTues_nextTues)
        XCTAssertEqual(n0?.left?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(n0?.right?.value, today_tomorrow)
        XCTAssertEqual(n0?.right?.right?.value, tomorrow_next_tues)

        let tree_min = tree.minimum()?.value
        XCTAssertEqual(lastTues_yesterday, tree_min)
    }


    /*
     Returns the rightmost descendent of tree. O(h) time.
     */
    func test_max_tree() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])
        tree.display(node: tree.root!)
        XCTAssertEqual(tree.size, 6)
        XCTAssertEqual(tree.height(), 4)

        // verify structure
        let n0 = tree.root
        XCTAssertEqual(n0?.value, today_today)
        XCTAssertEqual(n0?.left?.value, yesterday_tomorrow)
        XCTAssertEqual(n0?.left?.left?.value, lastTues_nextTues)
        XCTAssertEqual(n0?.left?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(n0?.right?.value, today_tomorrow)
        XCTAssertEqual(n0?.right?.right?.value, tomorrow_next_tues)

        // tree max
        let tree_max = tree.maximum()?.value
        XCTAssertEqual(tomorrow_next_tues, tree_max)
    }


    // map takes function: (BinarySearchTree) -> BinarySearchTree) and returns [BinarySearchTreeNode<T>]
    func testMap() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])
        tree.draw()

        // first, lets just pass through the node values
        let r0 = tree.map({$0}) // no changes

        XCTAssertTrue(r0.contains(today_today))
        XCTAssertTrue(r0.contains(today_tomorrow))
        XCTAssertTrue(r0.contains(yesterday_tomorrow))
        XCTAssertTrue(r0.contains(tomorrow_next_tues))
        XCTAssertTrue(r0.contains(lastTues_nextTues))
        XCTAssertTrue(r0.contains(lastTues_yesterday))

        // now let's apply a mutation function - using the BinarySearchTree class implementation of map
        _ = tree.map { try! Interval<Date>(start: $0.start + 60, end: $0.end + 60) } // shift all dates by one minute

        let m_today_today = try! Interval<Date>(start: today + 60, end: today + 60)
        let m_today_tomorrow = try! Interval<Date>(start: today + 60, end: tomorrow + 60) // overlaps today on right
        let m_yesterday_tomorrow = try! Interval<Date>(start: yesterday + 60, end: tomorrow + 60) // overlaps today on left
        let m_tomorrow_next_tues = try! Interval<Date>(start: tomorrow + 60, end: next_tues + 60) // strictly after today
        let m_lastTues_nextTues = try! Interval<Date>(start: last_tues + 60, end: next_tues + 60) // today is within
        let m_lastTues_yesterday = try! Interval<Date>(start: last_tues + 60, end: yesterday + 60) // strictly before today

        // assert that tree has been updated
        XCTAssertFalse(tree.contains(value: today_today), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: today_tomorrow), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: yesterday_tomorrow), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: tomorrow_next_tues), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: lastTues_nextTues), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: lastTues_yesterday), "previous interval values have been updated")

        // new interval values
        XCTAssertTrue(tree.contains(value: m_today_today), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_today_tomorrow), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_yesterday_tomorrow), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_tomorrow_next_tues), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_lastTues_nextTues), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_lastTues_yesterday), "previous interval values have been updated")
    }

    // flatMap is a shortcut for tree.map { try! TimeInterval(start: $0.start * 2, end: $0.end * 2) }
    func testFlatMap() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])
        tree.draw()

        // perform map via flatMap
        _ = tree.flatMap({ $0 + 60 })

        let m_today_today = try! Interval<Date>(start: today + 60, end: today + 60)
        let m_today_tomorrow = try! Interval<Date>(start: today + 60, end: tomorrow + 60) // overlaps today on right
        let m_yesterday_tomorrow = try! Interval<Date>(start: yesterday + 60, end: tomorrow + 60) // overlaps today on left
        let m_tomorrow_next_tues = try! Interval<Date>(start: tomorrow + 60, end: next_tues + 60) // strictly after today
        let m_lastTues_nextTues = try! Interval<Date>(start: last_tues + 60, end: next_tues + 60) // today is within
        let m_lastTues_yesterday = try! Interval<Date>(start: last_tues + 60, end: yesterday + 60) // strictly before today

        // assert that tree has been updated
        XCTAssertFalse(tree.contains(value: today_today), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: today_tomorrow), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: yesterday_tomorrow), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: tomorrow_next_tues), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: lastTues_nextTues), "previous interval values have been updated")
        XCTAssertFalse(tree.contains(value: lastTues_yesterday), "previous interval values have been updated")

        // new interval values
        XCTAssertTrue(tree.contains(value: m_today_today), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_today_tomorrow), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_yesterday_tomorrow), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_tomorrow_next_tues), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_lastTues_nextTues), "previous interval values have been updated")
        XCTAssertTrue(tree.contains(value: m_lastTues_yesterday), "previous interval values have been updated")
    }

    // since we inherit from AVLTree, each deletion should rebalance tree
    func testDeleteTimeIntervals() {
        let today = Date.init(detectFromString: "today")!
        let tomorrow = Date.init(detectFromString: "tomorrow")!
        let yesterday = Date.init(detectFromString: "yesterday")!
        let last_tues = Date.init(detectFromString: "last Tuesday")!
        let next_tues = Date.init(detectFromString: "next Tuesday")!

        let today_today = try! Interval<Date>(start: today, end: today)
        let today_tomorrow = try! Interval<Date>(start: today, end: tomorrow) // overlaps today on right
        let yesterday_tomorrow = try! Interval<Date>(start: yesterday, end: tomorrow) // overlaps today on left
        let tomorrow_next_tues = try! Interval<Date>(start: tomorrow, end: next_tues) // strictly after today
        let lastTues_nextTues = try! Interval<Date>(start: last_tues, end: next_tues) // today is within
        let lastTues_yesterday = try! Interval<Date>(start: last_tues, end: yesterday) // strictly before today

        let tree: TimeIntervalTree = TimeIntervalTree<Date>(array: [today_today,
                                                             today_tomorrow,
                                                             yesterday_tomorrow,
                                                             tomorrow_next_tues,
                                                             lastTues_nextTues,
                                                             lastTues_yesterday
                                                            ])

        tree.draw()
        tree.display(node: tree.root!)
        // verify structure
        let n0 = tree.root
        XCTAssertTrue(tree.size == 6)
        XCTAssertTrue(tree.height() == 4)
        XCTAssertTrue(n0!.isRoot)
        XCTAssertEqual(n0?.value, today_today)
        XCTAssertEqual(n0?.left?.value, yesterday_tomorrow)
        XCTAssertEqual(n0?.left?.left?.value, lastTues_nextTues)
        XCTAssertEqual(n0?.left?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(n0?.right?.value, today_tomorrow)
        XCTAssertEqual(n0?.right?.right?.value, tomorrow_next_tues)

        // remove leaf - note autobalance
        tree.remove(value: tomorrow_next_tues)
        tree.draw()
        tree.display(node: tree.root!)
        XCTAssertTrue(tree.size == 5)
        XCTAssertTrue(tree.height() == 3)
        XCTAssertEqual(tree.root?.value, yesterday_tomorrow)
        XCTAssertEqual(tree.root?.left?.value, lastTues_nextTues)
        XCTAssertEqual(tree.root?.left?.left?.value, lastTues_yesterday)
        XCTAssertEqual(tree.root?.right?.value, today_today)
        XCTAssertEqual(tree.root?.right?.right?.value, today_tomorrow)

        // remove the root - note autobalance
        tree.remove(value: yesterday_tomorrow)
        tree.draw()
        tree.display(node: tree.root!)
        XCTAssertTrue(tree.size == 4)
        XCTAssertTrue(tree.height() == 3)
        XCTAssertNil(tree.root?.parent)
        XCTAssertEqual(tree.root?.value, lastTues_nextTues)
        XCTAssertEqual(tree.root?.left?.value, lastTues_yesterday)
        XCTAssertEqual(tree.root?.right?.value, today_today)
        XCTAssertEqual(tree.root?.right?.right?.value, today_tomorrow)

        // remove inner node (root, since tree rebalanced)
        tree.remove(value: tree.root!.value)
        XCTAssertTrue(tree.size == 3)
        XCTAssertTrue(tree.height() == 2)
        XCTAssertEqual(tree.root?.value, today_today)
        XCTAssertEqual(tree.root?.left?.value, lastTues_yesterday)
        XCTAssertEqual(tree.root?.right?.value, today_tomorrow)
        tree.draw()
        tree.display(node: tree.root!)
    }

}
