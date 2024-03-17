//
//  TimeIntervalTree.swift
//  
//
//  Created by Christopher Charles Cavnor on 3/4/23.
//

import TreeProtocol
import BinarySearchTree
import IntervalTree
import Foundation
//import DateHelper

// MARK: TimeIntervalNode
open class TimeIntervalNode<T: IntervalTreeValueP>: IntervalTreeNode<Date> {

    open override var length: Float {
        let start_date: Date = self.value.start
        let end_date: Date = self.value.end
        let start: Double = start_date.timeIntervalSinceReferenceDate
        let end: Double = end_date.timeIntervalSinceReferenceDate
        let delta = (end - start) // diff
        return f(delta)
    }
}

// MARK: TimeIntervalTree
class TimeIntervalTree<T: IntervalTreeValueP>: IntervalTree<Date> { }

// MARK: Extension: Date
/// Allows compact presentation of dates as strings
extension Date {
    /// compact date format
    public var short: String {
        let datef = "YY.M.d@HH:m:s"
        return getFormattedDate(format: datef)
    }

   private func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension Date: AdditiveArithmetic {
    public static var zero: Date {
        return Date()
    }

    /// Date addition is trivially implemented as the max of the given dates. This is so because the distance
    /// between any two time points must always equal the lesser time plus the delta between the two time points,
    /// taken as an absolute value - which equals the max of the two dates. In this way, the commutative
    /// property of addition is preserved.
    public static func + (lhs: Date, rhs: Date) -> Date {
        return max(lhs, rhs)
    }

    /// Date subtraction is not a commutative operation. The order of the arguments will yield different outcomes.
    /// Subtracting today from tomorrow (tomorrow - today) will give us today (tomorrow minus 24 hours), while
    /// subtracting tomorrow from today (today - tomorrow) yields tomorrow (today -(-24 hours) ==( today + 24 hours)),
    /// or tomorrow.
    public static func - (lhs: Date, rhs: Date) -> Date {
        let now:Double = lhs.timeIntervalSinceReferenceDate
        let then:Double = rhs.timeIntervalSinceReferenceDate
        let delta = (now - then) // diff
        return lhs.addingTimeInterval(-delta)
    }
}

extension Date: IntervalTreeValueP {
    public typealias NodeValue = Date
    public var start: Date {
        get {
            return self
        }
        set {
            self = newValue
        }
    }

    public var end: Date {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
