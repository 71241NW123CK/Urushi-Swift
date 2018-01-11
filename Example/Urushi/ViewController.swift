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
        let model = AppDelegate.urushi.value
        fooTextField.text = model.foo
        bizTextField.text = model.biz
    }
    
    @IBAction func saveButtonWasTapped(_ sender: Any) {
        // Probably better to get the value as a var, mutate it, and then set its new value to AppDelegate.urushi.value, but setting fields in the value directly here to illustrate what you can do.
        guard
            let foo = fooTextField.text,
            let biz = bizTextField.text
        else {
            return
        }
        AppDelegate.urushi.value.foo = foo
        AppDelegate.urushi.value.biz = biz
    }
}
