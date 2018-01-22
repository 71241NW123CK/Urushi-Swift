//
//  Model.swift
//  Urushi_Example
//
//  Created by Ryan Hiroaki Tsukamoto on 1/11/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Gloss

struct Model: Glossy {
    static let defaultModel: Model = Model(foo: "bar", biz: "baz")
    
    var foo: String
    var biz: String
    
    init(foo: String, biz: String) {
        self.foo = foo
        self.biz = biz
    }
    
    init?(json: JSON) {
        guard
            let foo: String = "foo" <~~ json,
            let biz: String = "biz" <~~ json
        else {
            return nil
        }
        self.foo = foo
        self.biz = biz
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "foo" ~~> foo,
            "biz" ~~> biz
            ])
    }
}

struct FulfilmentOrder: Glossy { // this is a parody
    var incendiaryLemonCount: Int
    var weightedStorageCubeCount: Int
    
    init(incendiaryLemonCount: Int, weightedStorageCubeCount: Int) {
        self.incendiaryLemonCount = incendiaryLemonCount
        self.weightedStorageCubeCount = weightedStorageCubeCount
    }
    
    init?(json: JSON) {
        guard
            let incendiaryLemonCount: Int = "incendiaryLemonCount" <~~ json,
            let weightedStorageCubeCount: Int = "weightedStorageCubeCount" <~~ json
        else {
            return nil
        }
        self.incendiaryLemonCount = incendiaryLemonCount
        self.weightedStorageCubeCount = weightedStorageCubeCount
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "incendiaryLemonCount" ~~> incendiaryLemonCount,
            "weightedStorageCubeCount" ~~> weightedStorageCubeCount
            ])
    }
}
