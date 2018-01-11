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
    let defaultModelProducer: () -> T
    var maybeModel: T?
    
    public var model: T {
        mutating get {
            let m = maybeModel ?? fetchModel()
            maybeModel = m
            return m
        }
        
        set(newModel) {
            storeModel(newModel)
            maybeModel = newModel
        }
    }
    
    public init(key: String, defaultModelProducer: @escaping () -> T) {
        self.key = key
        self.defaultModelProducer = defaultModelProducer
    }
    
    func fetchModel() -> T {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let m = T(data: data)
            else {
                return defaultModelProducer()
        }
        return m
    }
    
    func storeModel(_ model: T) {
        guard
            let json = model.toJSON(),
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            else {
                return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
}
