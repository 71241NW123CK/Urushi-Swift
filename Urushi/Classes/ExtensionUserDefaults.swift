//
//  ExtensionUserDefaults.swift
//  Gloss
//
//  Created by Ryan Hiroaki Tsukamoto on 1/13/18.
//

import Foundation
import Gloss

extension UserDefaults {
    func maybeGlossyValue<T: Glossy>(forKey defaultName: String) -> T? {
        guard let data = data(forKey: defaultName) else {
            return nil
        }
        return T(data: data)
    }
    
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
