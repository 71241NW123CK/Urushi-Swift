//
//  ViewController.swift
//  Urushi
//
//  Created by Ryan Hiroaki Tsukamoto on 01/10/2018.
//  Copyright (c) 2018 Ryan Hiroaki Tsukamoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var fooTextField: UITextField!
    @IBOutlet weak var bizTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let model = AppDelegate.urushi.model
        fooTextField.text = model.foo
        bizTextField.text = model.biz
    }
    
    @IBAction func saveButtonWasTapped(_ sender: Any) {
        // Probably better to get the model as a var, mutate it, and then set its new value to AppDelegate.urushi.model, but setting fields in the model directly here to illustrate what you can do.
        guard
            let foo = fooTextField.text,
            let biz = bizTextField.text
        else {
            return
        }
        AppDelegate.urushi.model.foo = foo
        AppDelegate.urushi.model.biz = biz
    }
}
