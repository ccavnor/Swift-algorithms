//
//  BiMultiMap.swift
//  ccavnor-swift-collections
//
//  Created by Christopher Charles Cavnor on 10/10/24.
//

import Foundation

/// BiMultiMap is value-based data structure that provides the following functionality.
/// It acts as a reversable  multi-map:
/// Takes a distict key and accumulates values under that key as a list (a dictionary of type  `[H:[T]]`)
/// And a BiMap:
/// translates the forward multi-mapping into a backward one ([T:[H]]).
/// Example:
/// ```swift
/// var mm = BiMultiMap( [1:["A","B","C"], 2:["A", "B", "C"]] )
/// print(mm.forward) // [1: ["A", "B", "C"], 2: ["A", "B", "C"]]
/// print(mm.backward) // ["C": [1, 2], "B": [1, 2], "A": [1, 2]]
/// ```
/// The values of a key can be expanded using the += operator, either in forward or backward directions:
/// ```swift
/// var mm = BiMultiMap<Int, String>()
/// mm[0] = ["zero"]
/// mm[0]! += ["one"]
/// print(mm.forward) // [0: ["zero", "one"]]
/// ```
public struct BiMultiMap<H:Hashable, T:Hashable> {
    private var _forward : [H:[T]]? = nil
    private var _backward: [T:[H]]? = nil
    private var _count: Int = 0

    var forward:[H:[T]] {
        mutating get {
            _forward = _forward ?? {
                var dict:[H:[T]] = [H:[T]]()

                _ = _backward?.map({ (t:T, h:[H]) in
                    h.map { h in
                        if (dict[h] == nil) {
                            dict[h] = [T]()
                        }
                        dict[h]?.append(t)
                    }
                })
                _forward = dict
                return _forward
            }()

            _count = _forward?.count ?? 0
            return _forward!
        }

        set { _forward = newValue; _count = _forward?.count ?? 0 }
    }

    // Note that [H] may be in any order, since there is no guaranteed
    // order of of the hash keys from which they are derived.
    var backward:[T:[H]] {
        mutating get {
            _backward = _backward ?? {
                var dict:[T:[H]] = [T:[H]]()
                _ = _forward?.map({ (h:H, t:[T]) in
                    t.map { t in
                        if (dict[t] == nil) {
                            dict[t] = [H]()
                        }
                        dict[t]?.append(h)
                    }
                })
                _backward = dict
                return _backward
            }()

            _count = _backward?.count ?? 0
            return _backward!
        }

        set { _backward = newValue; _count = _backward?.count ?? 0  }
    }

    // empty init
    init() { forward = [:] }

    // Create using dictionary
    init(_ dict:[H:[T]] = [:]) { forward = dict; _count = dict.count }

    // Create from the given key-value pairs
    init(_ values:[(H,[T])]) { forward = [H:[T]](uniqueKeysWithValues:values); _count = values.count }

    // count is updated to reflect a forward count when key is H
    // else set to backward count using T
    var count:Int { return _count }

    // removing elements
    mutating func remove(_ key: H) { forward[key] = nil; _backward = nil }
    mutating func remove(_ key: T) { backward[key] = nil; _forward = nil }

    // forward access
    subscript(_ key:H) -> [T]? {
        mutating get { return forward[key] }
        set {
            if let newValue {
                forward[key] = newValue
            } else {
                self.remove(key)
            }
        }
    }

    // reverse access
    subscript(_ key:T) -> [H]? {
        mutating get { return backward[key] }
        set {
            if let newValue {
                backward[key] = newValue
            } else {
                self.remove(key)
            }
        }
    }
}

//extension BiMultiMap {
//    static func += (map: inout BiMultiMap, dict: [H:[T]]) {
//        for key in dict.keys {
//            if dict[key] != nil {
//                //map[key]? += dict[key]!
//                if map[key] != nil {
//                    map[key]! += dict[key]!
//                } else {
//                    print(">>>>>>>> simple assignment")
//                    map[key] = dict[key]!
//                }
//            }
//        }
//    }
//}
