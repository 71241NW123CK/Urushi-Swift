//
//  ViewController.swift
//  Urushi
//
//  Created by Ryan Hiroaki Tsukamoto on 01/10/2018.
//  Copyright (c) 2018 Ryan Hiroaki Tsukamoto. All rights reserved.
//

import UIKit
import Urushi

class ViewController: UIViewController {
    static var fulfilmentOrderUrushiArray: Disk.UrushiArray<FulfilmentOrder> = Disk.UrushiArray(key: Disk.Key(directory: .applicationSupport, path: "fulfilmentOrderList"))
    static var modelUrushi: Disk.Urushi = Disk.Urushi(key: Disk.Key(directory: .applicationSupport, path: "model")) { return Model(foo: "bar", biz: "baz") }

    @IBOutlet weak var fooTextField: UITextField!
    @IBOutlet weak var bizTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fooTextField.text = ViewController.modelUrushi.value.foo
        bizTextField.text = ViewController.modelUrushi.value.biz
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 42
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func fooTextFieldEditingChanged(_ sender: Any) {
        if let fooTextFieldText = fooTextField.text {
            ViewController.modelUrushi.value.foo = fooTextFieldText
        }
    }
    
    @IBAction func bizTextFieldEditingChanged(_ sender: Any) {
        if let bizTextFieldText = bizTextField.text {
            ViewController.modelUrushi.value.biz = bizTextFieldText
        }
    }
    
    @IBAction func addFulfilmentOrderButtonWasTapped(_ sender: Any) {
        ViewController.fulfilmentOrderUrushiArray.append(FulfilmentOrder(incendiaryLemonCount: 42, weightedStorageCubeCount: 420))
        tableView.reloadData()
    }
}

class AddAnOrderTableViewCell: UITableViewCell {}

class FulfilmentOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var incendiaryLemonCountLabel: UILabel!
    @IBOutlet weak var incendiaryLemonCountStepper: UIStepper!
    @IBOutlet weak var weightedStorageCubeCountLabel: UILabel!
    @IBOutlet weak var weightedStorageCubeCountStepper: UIStepper!
    
    var index: Int!
    
    @IBAction func incendiaryLemonCountStepperValueChanged(_ sender: Any) {
        let incendiaryLemonCount = Int(incendiaryLemonCountStepper.value)
        incendiaryLemonCountLabel.text = "\(incendiaryLemonCount)"
        ViewController.fulfilmentOrderUrushiArray[index].incendiaryLemonCount = incendiaryLemonCount
    }
    
    @IBAction func weightedStorageCubeCountStepperValueChanged(_ sender: Any) {
        let weightedStorageCubeCount = Int(weightedStorageCubeCountStepper.value)
        weightedStorageCubeCountLabel.text = "\(weightedStorageCubeCount)"
        ViewController.fulfilmentOrderUrushiArray[index].weightedStorageCubeCount = weightedStorageCubeCount
    }
    
    func bind(index: Int) {
        self.index = index
        let fulfilmentOrder = ViewController.fulfilmentOrderUrushiArray[index]
        incendiaryLemonCountStepper.value = Double(fulfilmentOrder.incendiaryLemonCount)
        incendiaryLemonCountLabel.text = "\(fulfilmentOrder.incendiaryLemonCount)"
        weightedStorageCubeCountStepper.value = Double(fulfilmentOrder.weightedStorageCubeCount)
        weightedStorageCubeCountLabel.text = "\(fulfilmentOrder.weightedStorageCubeCount)"
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fulfilmentOrderUrushiArrayCount = ViewController.fulfilmentOrderUrushiArray.count
        switch section {
        case 0:
            return fulfilmentOrderUrushiArrayCount == 0 ? 1 : 0
        case 1:
            return fulfilmentOrderUrushiArrayCount
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "add-an-order", for: indexPath) as? AddAnOrderTableViewCell ?? UITableViewCell()
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fulfilment-order", for: indexPath) as? FulfilmentOrderTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(index: indexPath.row)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if ViewController.fulfilmentOrderUrushiArray.isEmpty {
            return []
        }
        let deleteAction = UITableViewRowAction(style: .default, title: nil) { (action, indexPath) in
            tableView.beginUpdates()
            _ = ViewController.fulfilmentOrderUrushiArray.remove(at: indexPath.row)
            if ViewController.fulfilmentOrderUrushiArray.count == 0 {
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
        return [deleteAction]
    }
}
