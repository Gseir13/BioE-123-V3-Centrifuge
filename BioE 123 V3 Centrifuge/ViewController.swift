//
//  ViewController.swift
//  BioE 123 V3 Centrifuge
//
//  Created by Gabriel Seir on 3/9/23.
//

import UIKit
import Particle_SDK

var setSpeed:Int = 0
var pickedTime = [0, 0]
//var setTime:Double = 0.0
var setTime:Int = 0
var myPhoton : ParticleDevice?

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var RPMInput: UITextField!
    
    @IBAction func RPMInputNumber(_ sender: Any) {
        
        if (Int(self.RPMInput.text ?? "0")! > 2800) {
            self.RPMInput.backgroundColor = .red
            self.RPMInput.text = ""
        } else {
            self.RPMInput.backgroundColor = .white
            setSpeed = Int(self.RPMInput.text ?? "0")!
        }
    }
    
    @IBOutlet weak var TimePicker: UIPickerView!
    var timePickerData: [[String]] = [[String]]()
    
    
    /*@IBAction func RPMEnter(_ sender: Any) {
        if (self.RPMInput.text != "") {
            RPMInput.endEditing(true)
        }
        // Could also just do tap anywhere to enter
    }*/
    
    var startArgString = ""
    
    @IBAction func StartButton(_ sender: Any) {
        setTime = (pickedTime[0] * 60) + pickedTime[1]
        print("setTime: \(setTime)")
        startArgString = ""
        startArgString = "\(setSpeed) \(setTime)"
        let startFuncArgs = [startArgString] as [Any]
        if (RPMInput.isEditing) {
            var popUpWindow: PopUpWindow!
            popUpWindow = PopUpWindow(title: "Error", text: "Please tap off of the RPM input keyboard before proceeding", buttontext: "OK")
            self.present(popUpWindow, animated: true, completion: nil)
        } else if (myPhoton != nil) {
            var startTask = myPhoton!.callFunction("start", withArguments: startFuncArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    if (resultCode == -1) {
                        // This means protective box is not attached -> want to give user a pop-up to attach the box
                        var popUpWindow: PopUpWindow!
                        popUpWindow = PopUpWindow(title: "Error", text: "Please reinsert cover before proceeding", buttontext: "OK")
                        self.present(popUpWindow, animated: true, completion: nil)
                    } else {
                        print("Start was successful")
                        self.performSegue(withIdentifier: "RunningCent", sender: nil)
                    }
                } else {
                    var popUpWindow: PopUpWindow!
                    popUpWindow = PopUpWindow(title: "Error", text: "Centrifuge is not connected to the internet, please reconnect and try again", buttontext: "OK")
                    self.present(popUpWindow, animated: true, completion: nil)
                }
            }
        } else {
            var popUpWindow: PopUpWindow!
            popUpWindow = PopUpWindow(title: "Error", text: "Wait a moment while the app logs in to access the centrifuge", buttontext: "OK")
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    @IBAction func StopButton(_ sender: Any) {
        let stopFuncArgs = ["stop"] as [Any]
        var stopTask = myPhoton!.callFunction("stop", withArguments: stopFuncArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) {
                print("Stop was successful")
            }
        }
    }
    
    @IBOutlet weak var start: UIButton!
    
    @IBOutlet weak var stop: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ParticleCloud.sharedInstance().login(withUser: "gseir@stanford.edu", password: userPass) { (error:Error?) -> Void in
            if let _ = error {
                print("Wrong credentials or no internet connectivity, please try again")
            }
            else {
                print("Logged in")
            }
        }
        
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "BioE_123_V3_Centrifuge_-_Photon" {
                            myPhoton = device
                        }
                    }
                }
            }
        }
        
        
        RPMInput.placeholder = "0...2800"
        RPMInput.keyboardType = .numberPad
        start.setTitleColor(UIColor.black, for: .normal)
        start.setTitle("Start", for: .normal)
        stop.setTitleColor(UIColor.black, for: .normal)
        stop.setTitle("Stop", for: .normal)
        
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
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        if (self.RPMInput.text != "") {
            RPMInput.endEditing(true)
        }
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




















let userPass = "Gabriel2002!"
