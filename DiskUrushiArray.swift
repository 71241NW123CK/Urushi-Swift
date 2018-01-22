//
//  DiskUrushiArray.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/20/18.
//

import Foundation
import Gloss

public extension Disk {
    public struct UrushiArray<T: Glossy> {
        public let key: Key
        let recursiveLock = NSRecursiveLock()
        let countKey: Key
        let defaultProvider: () -> [T]
        
        var valuesByIndex: [Int: T] = [:]
        var maybeCount: Int?
        
        public var count: Int {
            mutating get {
                recursiveLock.lock()
                if let c = maybeCount {
                    recursiveLock.unlock()
                    return c
                }
                let maybeI = try! maybeGetInt(at: countKey)
                if let i = maybeI {
                    maybeCount = i
                    recursiveLock.unlock()
                    return i
                }
                let a = defaultProvider()
                array = a
                recursiveLock.unlock()
                return a.count
            }
        }
        
        public var array: [T] { // Avoid using this, since it eagerly fetches all the values in the urushi array
            mutating get {
                recursiveLock.lock()
                let c = count
                let result = (0..<c).map { self[$0] }
                recursiveLock.unlock()
                return result
            }
            
            set(newArray) {
                recursiveLock.lock()
                valuesByIndex.removeAll()
                let c = newArray.count
                for i in 0..<c {
                    let t = newArray[i]
                    try! put(at: keyFor(i), t)
                    valuesByIndex[i] = t
                }
                if let oldCount = maybeCount, c < oldCount {
                    for i in c ..< oldCount {
                        try! Disk.remove(keyFor(i))
                    }
                }
                maybeCount = c
                storeCount(c)
                recursiveLock.unlock()
            }
        }

        public var isEmpty: Bool {
            mutating get {
                return count == 0
            }
        }
        
        public var first: T? {
            mutating get {
                recursiveLock.lock()
                let result = isEmpty ? nil : self[0]
                recursiveLock.unlock()
                return result
            }
        }
        
        public var last: T? {
            mutating get {
                recursiveLock.lock()
                let c = count
                if c == 0 {
                    recursiveLock.unlock()
                    return nil
                }
                let result = self[c - 1]
                recursiveLock.unlock()
                return result
            }
        }
        
        public init(key: Key, defaultProvider: @escaping () -> [T] = { return [] }) {
            self.key = key
            self.countKey = (directory: key.directory, path: key.path + "/count")
            self.defaultProvider = defaultProvider
        }
        
        public mutating func popLast() -> T? {
            recursiveLock.lock()
            let c = count
            if c == 0 {
                recursiveLock.unlock()
                return nil
            }
            let decrC = c - 1
            let t = self[decrC]
            maybeCount = decrC
            storeCount(decrC)
            try! Disk.remove(keyFor(decrC))
            valuesByIndex.removeValue(forKey: decrC)
            recursiveLock.unlock()
            return t
        }
        
        public mutating func append(_ newElement: T) {
            recursiveLock.lock()
            let c = count
            try! put(at: keyFor(c), newElement)
            valuesByIndex[c] = newElement
            maybeCount = c + 1
            storeCount(c + 1)
            recursiveLock.unlock()
        }
        
        public mutating func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
            // TODO: less shitty.  Make England my city!
            recursiveLock.lock()
            for t in newElements {
                append(t)
            }
            recursiveLock.unlock()
        }
        
        public mutating func insert(_ newElement: T, at i: Int) {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.insert(newElement, at: i)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, T == C.Element {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.insert(contentsOf: newElements, at: i)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func remove(at position: Int) -> T {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            let t = a.remove(at: position)
            array = a
            recursiveLock.unlock()
            return t
        }
        
        public mutating func removeSubrange(_ bounds: Range<Int>) {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.removeSubrange(bounds)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func removeFirst(_ n: Int) {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.removeFirst(n)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func removeFirst() -> T {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            let t = a.removeFirst()
            array = a
            recursiveLock.unlock()
            return t
        }
        
        public mutating func removeAll() {
            array = []
        }
        
        public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, T == C.Element, Int == R.Bound {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.replaceSubrange(subrange, with: newElements)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Int == R.Bound {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.removeSubrange(bounds)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func removeLast() -> T {
            guard let last = popLast() else {
                fatalError("Can't remove last element from an empty collection")
            }
            return last
        }
        
        public mutating func removeLast(_ n: Int) {
            // TODO: less shitty
            recursiveLock.lock()
            var a = array
            a.removeLast(n)
            array = a
            recursiveLock.unlock()
        }
        
        public mutating func map<U>(_ transform: (T) throws -> U) -> [U] { // this could rethrow?
            return try! array.map(transform)
        }
        
        public mutating func forEach(_ body: (T) throws -> Void) { // this could rethrow?
            return try! array.forEach(body)
        }
        
        public mutating func first(where predicate: (T) throws -> Bool) -> T? { // this could rethrow?
            recursiveLock.lock()
            let c = count
            for i in 0..<c {
                let t = self[i]
                if try! predicate(t) {
                    recursiveLock.unlock()
                    return t
                }
            }
            recursiveLock.unlock()
            return nil
        }
        
        public mutating func dropFirst() -> ArraySlice<T> {
            // TODO: less shitty
            return array.dropFirst()
        }
        
        public mutating func dropLast() -> ArraySlice<T> {
            // TODO: less shitty
            return array.dropLast()
        }
        
        public mutating func enumerated() -> EnumeratedSequence<Array<T>> {
            return array.enumerated()
        }
        
        public mutating func contains(where predicate: (T) throws -> Bool) -> Bool { // this could rethrow?
            return first(where: predicate) != nil
        }
        
        public mutating func reduce<U>(_ initialResult: U, _ nextPartialResult: (U, T) throws -> U) -> U { // this could rethrow?
            return try! array.reduce(initialResult, nextPartialResult)
        }
        
        public mutating func reduce<U>(into initialResult: U, _ updateAccumulatingResult: (inout U, T) throws -> ()) -> U { // this could rethrow?
            return try! array.reduce(into: initialResult, updateAccumulatingResult)
        }
        
        public mutating func flatMap<U>(_ transform: (T) throws -> U?) -> [U] { // this could rethrow?
            return try! array.flatMap(transform)
        }
        
        public mutating func flatMap<U>(_ transform: (T) throws -> U) -> [U.Element] where U : Sequence { // this could rethrow?
            return try! array.flatMap(transform)
        }

        public subscript(index: Int) -> T {
            mutating get {
                recursiveLock.lock()
                let c = count
                if index >= c {
                    fatalError("Index out of range")
                }
                if let t = valuesByIndex[index] {
                    recursiveLock.unlock()
                    return t
                }
                let maybeT: T? = try! maybeGetGlossyValue(at: keyFor(index))
                guard let t = maybeT else {
                    fatalError("incendiary lemons have burned your house down") // in a parodic fashion
                }
                valuesByIndex[index] = t
                recursiveLock.unlock()
                return t
            }
            
            set(newValue) {
                recursiveLock.lock()
                try! put(at: keyFor(index), newValue)
                valuesByIndex[index] = newValue
                recursiveLock.unlock()
            }
        }
        
        func keyFor(_ index: Int) -> Key {
            return (directory: key.directory, path: key.path + "/\(index)")
        }
        
        func storeCount(_ count: Int) {
            try! put(at: countKey, count)
        }
    }
}
