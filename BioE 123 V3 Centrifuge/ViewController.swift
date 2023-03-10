//
//  ViewController.swift
//  BioE 123 V3 Centrifuge
//
//  Created by Gabriel Seir on 3/9/23.
//

import UIKit

var setSpeed:Int = 0
var pickedTime = [0, 0]
// Then, setTime = 10 * pickedTime[0] + pickedTime[1] + (pickedTime[2] * 10 + pickedTime[3]) / 60
var setTime:Double = 0.0

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var RPMInput: UITextField!
    
    @IBAction func RPMInputNumber(_ sender: Any) {
        
        if (Int(self.RPMInput.text ?? "0")! > 2800) {
            self.RPMInput.backgroundColor = .red
            self.RPMInput.text = ""
        } else {
            setSpeed = Int(self.RPMInput.text ?? "0")!
        }
    }
    
    @IBOutlet weak var TimePicker: UIPickerView!
    var timePickerData: [[String]] = [[String]]()
    
    
    @IBAction func RPMEnter(_ sender: Any) {
        if (self.RPMInput.text != "") {
            RPMInput.endEditing(true)
        }
        // Could also just do tap anywhere to enter
    }
    
    @IBAction func StartButton(_ sender: Any) {
    }
    
    @IBAction func StopButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        RPMInput.placeholder = "0...2800"
        RPMInput.keyboardType = .numberPad
        
        // Connect data:
        self.TimePicker.delegate = self
        self.TimePicker.dataSource = self
        
        timePickerData = [["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13",
                           "14", "15", "16", "17", "18", "19", "20"],
                          ["m"],
                          ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13",
                           "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                           "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                           "51", "52", "53", "54", "55", "56", "57", "58", "59",],
                          ["s"]]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timePickerData[component][row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (component == 0) {
                pickedTime[component] = Int(timePickerData[component][row])!
        }
        if (component == 2) {
            pickedTime[1] = Int(timePickerData[component][row])!
        }
    }

}

