//
//  Urushi.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/11/18.
//

import Foundation
import Gloss

public struct Urushi<T: Glossy> {
    public let key: String // should be distinct, and should not contain "."  TODO: provide a logger or something
    let defaultProvider: () -> T // should this be more accurately named defaultDefaultProvider?
    var maybeValue: T?
    
    public var value: T {
        mutating get {
            let t = maybeValue ?? UserDefaults.standard.glossyValue(forKey: key, defaultProvider: defaultProvider)
            maybeValue = t
            return t
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: key)
            maybeValue = newValue
        }
    }
    
    public init(key: String, defaultProvider: @escaping () -> T) {
        self.key = key
        self.defaultProvider = defaultProvider
    }
}

public struct UrushiArray<T: Glossy> {
    public let key: String
    let countKey: String
    let defaultProvider: () -> [T]
    let incendiaryLemon: () -> T = { fatalError("When life gives you lemons, don’t make lemonade.  Make life take the lemons back!  Get mad!  I don’t want your damn lemons, what the hell am I supposed to do with these?  Demand to see life’s manager!") } // this is a parody
    var valuesByIndex: [Int: T] = [:]
    var maybeCount: Int?
    
    public var count: Int {
        mutating get {
            if let c = maybeCount {
                return c
            }
            if let o = UserDefaults.standard.object(forKey: countKey), let n = o as? NSNumber {
                let c = n.intValue as Int
                maybeCount = c
                return c
            }
            let a = defaultProvider()
            array = a
            return a.count
        }
    }
    
    public var array: [T] { // Avoid using this.  Defeating the point of having this desu
        mutating get {
            let c = count
            return (0..<c).map { self[$0] }
        }
        
        set(newArray) {
            valuesByIndex.removeAll()
            let c = newArray.count
            for i in 0..<c {
                let t = newArray[i]
                UserDefaults.standard.set(t, forKey: keyFor(i))
                valuesByIndex[i] = t
            }
            maybeCount = c
            storeCount(c)
        }
    }
    
    public var isEmpty: Bool {
        mutating get {
            return count == 0
        }
    }
    
    public var first: T? {
        mutating get {
            return isEmpty ? nil : self[0]
        }
    }
    
    public var last: T? {
        mutating get {
            let c = count
            if c == 0 {
                return nil
            }
            return self[c - 1]
        }
    }
    
    public init(key: String, defaultProvider: @escaping () -> [T] = { return [] }) {
        self.key = key
        self.countKey = key + ".count"
        self.defaultProvider = defaultProvider
    }
    
    public mutating func popLast() -> T? {
        let c = count
        if c == 0 {
            return nil
        }
        let decrC = c - 1
        let t = self[decrC]
        maybeCount = decrC
        storeCount(decrC)
        UserDefaults.standard.set(nil, forKey: keyFor(decrC))
        return t
    }
    
    public mutating func append(_ newElement: T) {
        let c = count
        UserDefaults.standard.set(newElement, forKey: keyFor(c))
        maybeCount = c + 1
        storeCount(c + 1)
    }
    
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        // TODO: less shitty.  Make England my city!
        for t in newElements {
            append(t)
        }
    }
    
    public mutating func insert(_ newElement: T, at i: Int) {
        // TODO: less shitty
        var a = array
        a.insert(newElement, at: i)
        array = a
    }
    
    public mutating func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, T == C.Element {
        // TODO: less shitty
        var a = array
        a.insert(contentsOf: newElements, at: i)
        array = a
    }
    
    public mutating func remove(at position: Int) -> T {
        // TODO: less shitty
        var a = array
        let t = a.remove(at: position)
        array = a
        return t
    }
    
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        // TODO: less shitty
        var a = array
        a.removeSubrange(bounds)
        array = a
    }
    
    public mutating func removeFirst(_ n: Int) {
        // TODO: less shitty
        var a = array
        a.removeFirst(n)
        array = a
    }
    
    public mutating func removeFirst() -> T {
        // TODO: less shitty
        var a = array
        let t = a.removeFirst()
        array = a
        return t
    }
    
    public mutating func removeAll() {
        valuesByIndex.removeAll()
        maybeCount = 0
        storeCount(0)
    }
    
    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, T == C.Element, Int == R.Bound {
        // TODO: less shitty
        var a = array
        a.replaceSubrange(subrange, with: newElements)
        array = a
    }
    
    public mutating func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Int == R.Bound {
        // TODO: less shitty
        var a = array
        a.removeSubrange(bounds)
        array = a
    }
    
    public mutating func removeLast() -> T {
        guard let last = popLast() else {
            fatalError("Can't remove last element from an empty collection")
        }
        return last
    }
    
    public mutating func removeLast(_ n: Int) {
        // TODO: less shitty
        var a = array
        a.removeLast(n)
        array = a
    }
    
    public mutating func map<U>(_ transform: (T) throws -> U) rethrows -> [U] {
        return try! array.map(transform)
    }
    
    public mutating func forEach(_ body: (T) throws -> Void) rethrows {
        return try! array.forEach(body)
    }
    
    public mutating func first(where predicate: (T) throws -> Bool) rethrows -> T? {
        let c = count
        for i in 0..<c {
            let t = self[i]
            if try! predicate(t) {
                return t
            }
        }
        return nil
    }
    
    public mutating func dropFirst() -> ArraySlice<T> {
        return array.dropFirst()
    }
    
    public mutating func dropLast() -> ArraySlice<T> {
        return array.dropLast()
    }
    
    public mutating func enumerated() -> EnumeratedSequence<Array<T>> {
        return array.enumerated()
    }
    
    public mutating func contains(where predicate: (T) throws -> Bool) rethrows -> Bool {
        return try! first(where: predicate) != nil
    }
    
    public mutating func reduce<U>(_ initialResult: U, _ nextPartialResult: (U, T) throws -> U) rethrows -> U {
        return try! array.reduce(initialResult, nextPartialResult)
    }
    
    public mutating func reduce<U>(into initialResult: U, _ updateAccumulatingResult: (inout U, T) throws -> ()) rethrows -> U {
        return try! array.reduce(into: initialResult, updateAccumulatingResult)
    }
    
    public mutating func flatMap<U>(_ transform: (T) throws -> U?) rethrows -> [U] {
        return try! array.flatMap(transform)
    }
    
    public mutating func flatMap<U>(_ transform: (T) throws -> U) rethrows -> [U.Element] where U : Sequence {
        return try! array.flatMap(transform)
    }
    
    public subscript(index: Int) -> T {
        mutating get {
            let c = count
            if index >= c {
                fatalError("Index out of range")
            }
            if let t = valuesByIndex[index] {
                return t
            }
            let t = UserDefaults.standard.glossyValue(forKey: keyFor(index), defaultProvider: incendiaryLemon)
            valuesByIndex[index] = t
            return t
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: keyFor(index))
            valuesByIndex[index] = newValue
        }
    }
    
    func keyFor(_ index: Int) -> String {
        return key + ".\(index)"
    }
    
    func storeCount(_ count: Int) {
        let n = NSNumber(value: count)
        UserDefaults.standard.set(n, forKey: countKey)
    }
}

extension UserDefaults {
    func glossyValue<T: Glossy>(forKey defaultName: String, defaultProvider: () -> T) -> T {
        guard
            let data = data(forKey: defaultName),
            let t = T(data: data)
        else {
            return defaultProvider()
        }
        return t
    }
    
    func set<T: Glossy>(_ value: T, forKey defaultName: String) {
        guard
            let json = value.toJSON(),
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        else {
            return
        }
        set(data, forKey: defaultName)
    }
}
