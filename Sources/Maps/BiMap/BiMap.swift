//
//  BiMap.swift
//  ccavnor-swift-collections
//
//  Created by Christopher Charles Cavnor on 10/10/24.
//
//  Implemention builds off of: https://stackoverflow.com/a/47081889

import Foundation

/// BiMap is value-based data structure that allows for a dictionary of bijected elements
/// (where the values are all distinct) to be reversed:
/// ```swift
/// var bim = BiMap( [(1,"A"), (2,"B"), (3,"C")] )
/// print(bim.forward) // [(1,"A"), (2,"B"), (3,"C")]
/// print(bim.backward) // [("A",1), ("B",2), ("C",3)]
/// ```
/// NOTE that we are using uniquingKeysWith to avoid a duplicate key exception when converting
/// duplicate values into keys - which must be unique. This means that for BiMaps that are not a
/// bijection (mapping one-to-one from keys to values), some KVPs might be dropped when going
/// from forward to backward, but restored when reversing back to forward.
///  ```swift
/// // notice duplicate values
/// var bim = BiMap( [(1,"A"), (2,"B"), (3,"C"), (4, "C")] )
/// print(bim.forward) // [(1,"A"), (2,"B"), (3,"C"), (4, "C")]
/// // notice that reversing drops what would have been a duplicate key: ["C": 3]
/// print(bim.backward) // ["A": 1, "B": 2, "C": 4]
/// // going forward again gives original dict
/// print(bim.forward) // [(1,"A"), (2,"B"), (3,"C"), (4, "C")]
/// ```
public struct BiMap<H:Hashable,T:Hashable> {
    private var _forward  : [H:T]? = nil
    private var _backward : [T:H]? = nil

    var forward:[H:T] {
        mutating get {
            //_forward = _forward ?? [H:T](uniqueKeysWithValues:_backward?.lazy.map{($1,$0)} ?? [] )
            _forward = _forward ?? [H:T](_backward?.lazy.map{($1,$0)} ?? [], uniquingKeysWith: { (_, last) in last })
            return _forward!
        }
        set { _forward = newValue; _backward = nil }
    }

    var backward:[T:H] {
        mutating get {
            _backward = _backward ?? [T:H](_forward?.lazy.map{($1,$0)} ?? [], uniquingKeysWith: { (_, last) in last })
            return _backward!
        }
        set {_backward = newValue; _forward = nil}
    }

    // Create using dictionary
    init(_ dict:[H:T] = [:]) { forward = dict }

    // Create from the given key-value pairs
    init(_ values:[(H,T)]) { forward = [H:T](uniqueKeysWithValues:values) }

    var count:Int { return _forward?.count ?? _backward?.count ?? 0 }

    // removing elements
    mutating func remove(_ key: H) { forward[key] = nil }
    mutating func remove(_ key: T) { backward[key] = nil }

    // forward access
    subscript(_ key:H) -> T? {
        mutating get { return forward[key] }
        set { forward[key]  = newValue }
    }
//    subscript(_ key:H) -> [T?] {
//        mutating get {
//            var items = [T?]()
//            for key in forward.keys {
//                items.append(forward[key])
//            }
//            return items
//        }
//        set {
//            if newValue.count == 1 {
//                forward[key]  = newValue[0]
//            }
//        }
//    }

    subscript(key key:H) -> T? {
        mutating get { return forward[key] }
        set { forward[key]  = newValue }
    }

    // backward access
    subscript(value key:T) -> H? {
        mutating get { return backward[key] }
        set { self[key as T] = newValue }
    }

    subscript(_ key:T) -> H? {
        mutating get { return backward[key] }
        set { backward[key]  = newValue }
    }

//    subscript(_ key:T) -> H? {
//        mutating get { return backward[key] }
//        set {
//            // assign forward else uniqueKeysWithValues might
//            // throw a duplicate key (the value from backward
//            // assignment) error
//            if let val = newValue {
//                forward[val] = key
//            } else {
//                // this removes element
//                backward[key] = nil
//            }
//        }
//    }
}
