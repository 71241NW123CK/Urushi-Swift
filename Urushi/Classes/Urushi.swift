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
