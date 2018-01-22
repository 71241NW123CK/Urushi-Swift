//
//  DiskUrushi.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/20/18.
//

import Foundation
import Gloss

public extension Disk {
    public struct Urushi<T: Glossy> {
        public let key: Key
        let dispatchQueue = DispatchQueue(label: "com.treesquared.urushi.Disk.Urushi")
        let defaultProvider: () -> T
        var maybeValue: T?
        
        public var value: T { // too bad you can't throw in a Swift computed property's getter and setter.  hurr durr.
            mutating get {
                return dispatchQueue.sync {
                    if let t =  maybeValue {
                        return t
                    }
                    let maybeT: T? = try! maybeGetGlossyValue(at: key)
                    let t = maybeT ?? defaultProvider()
                    maybeValue = t
                    return t
                }
            }
            
            set(newValue) {
                dispatchQueue.sync {
                    try! put(at: key, newValue)
                    maybeValue = newValue
                }
            }
        }
        
        public init(key: Key, defaultProvider: @escaping () -> T) {
            self.key = key
            self.defaultProvider = defaultProvider
        }
    }
}
