//
//  OrderedDictionary.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation

struct OrderedDictionary<KeyType: Hashable, ValueType> {
    private var _dictionary: Dictionary<KeyType, ValueType>
    private var _keys: Array<KeyType>

    init() {
        _dictionary = [:]
        _keys = []
    }

    init(minimumCapacity: Int) {
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity: minimumCapacity)
        _keys = Array<KeyType>()
    }

    init(_ dictionary: Dictionary<KeyType, ValueType>) {
        _dictionary = dictionary
        _keys = dictionary.keys.map { $0 }
    }

    subscript(key: KeyType) -> ValueType? {
        get {
            _dictionary[key]
        }
        set {
            if newValue == nil {
                self.removeValueForKey(key: key)
            } else {
                _ = self.updateValue(value: newValue!, forKey: key)
            }
        }
    }

    mutating func updateValue(value: ValueType, forKey key: KeyType) -> ValueType? {
        let oldValue = _dictionary.updateValue(value, forKey: key)
        if oldValue == nil {
            _keys.append(key)
        }
        return oldValue
    }

    mutating func removeValueForKey(key: KeyType) {
        _keys = _keys.filter {
            $0 != key
        }
        _dictionary.removeValue(forKey: key)
    }

    mutating func removeAll(keepCapacity: Int) {
        _keys = []
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity: keepCapacity)
    }

    var count: Int {
        get {
            _dictionary.count
        }
    }

    // keys isn't lazy evaluated because it's just an array anyway
    var keys: [KeyType] {
        get {
            _keys
        }
    }

    var values: Array<ValueType> {
        get {
            _keys.map { _dictionary[$0]! }
        }
    }

    static func ==<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
        lhs._keys == rhs._keys && lhs._dictionary == rhs._dictionary
    }

    static func !=<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
        lhs._keys != rhs._keys || lhs._dictionary != rhs._dictionary
    }

}

