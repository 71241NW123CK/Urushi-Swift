//
//  Urushi.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/11/18.
//

import Foundation
import Gloss

public struct Urushi<T: Glossy> {
    let key: String
    let defaultProvider: () -> T // should this be named defaultDefaultProvider?
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
