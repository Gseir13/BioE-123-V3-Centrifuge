//
//  RunningViewController.swift
//  BioE 123 V3 Centrifuge
//
//  Created by Gabriel Seir on 3/11/23.
//

import UIKit
import Charts

class RunningViewController: UIViewController {

    @IBOutlet weak var RPMNumber: UILabel!
    
    @IBOutlet weak var CountdownLabel: UILabel!
    
    @IBOutlet weak var Stop: UIButton!
    
    @IBOutlet weak var back: UIButton!
    
    @IBAction func backButton(_ sender: Any) {
        self.performSegue(withIdentifier: "allDone", sender: nil)
    }
    
    @IBAction func StopButton(_ sender: Any) {
        let stopFuncArgs = [] as [Any]
        var stopTask = myPhoton!.callFunction("stop", withArguments: stopFuncArgs) { (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) {
                print("Stop was successful")
                self.seconds = 0
                self.minutes = 0
                self.CountdownLabel.text = "0\(self.minutes):0\(self.seconds)"
            } else {
                self.seconds = 0
                self.minutes = 0
                self.CountdownLabel.text = "0\(self.minutes):0\(self.seconds)"
            }
        }
    }
    
    let chartView = LineChartView()
    
    var minutes:Int = pickedTime[0]
    var seconds:Int = pickedTime[1]
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(didUpdatedChartView), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(didStartCoverRampDown), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Stop.setTitleColor(UIColor.black, for: .normal)
        Stop.setTitle("Stop", for: .normal)
        
        back.setTitleColor(UIColor.blue, for: .normal)
        back.setTitle("Back", for: .normal)
        
        RPMNumber.text = "\(setSpeed) RPM"
        updateLabel()
        startTimer()
        

        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        chartView.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        
        setupInitialDataEntries()
        setupChartData()
    }
    
    var dataEntries = [ChartDataEntry]()
        
    // Determine how many dataEntries shows up in the chartView
    var xValue: Double = 10

    func setupInitialDataEntries() {
        (0..<Int(xValue)).forEach {
            let dataEntry = ChartDataEntry(x: Double($0), y: 0)
            dataEntries.append(dataEntry)
        }
    }

    func setupChartData() {
        // 1
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(.blue)
        chartDataSet.mode = .linear
            
        // 2
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawLabelsEnabled = false
    }
    
    func updateChartView(with newDataEntry: ChartDataEntry, dataEntries: inout [ChartDataEntry]) {
        // 1
        if let oldEntry = dataEntries.first {
            dataEntries.removeFirst()
            chartView.data?.removeEntry(oldEntry, dataSetIndex: 0)
        }
        
        // 2
        dataEntries.append(newDataEntry)
        chartView.data?.appendEntry(newDataEntry, toDataSet: 0)
            
        // 3
        chartView.notifyDataSetChanged()
        chartView.moveViewToX(newDataEntry.x)
    }

    @objc func didUpdatedChartView() {
        myPhoton!.getVariable("currentRPM", completion: { (result:Any?, error:Error?) -> Void in
            if let _ = error {
                print("Failed to read currentRPM")
            }
            else {
                if let currentRPM = result as? NSNumber {
                    print("currentRPM is \(currentRPM.stringValue)")
                    
                    let newDataEntry = ChartDataEntry(x: self.xValue,
                                                      y: currentRPM.doubleValue)
                    self.updateChartView(with: newDataEntry, dataEntries: &self.dataEntries)
                    self.xValue += 1
                }
            }
        })
        
    }
    
    @objc func didStartCoverRampDown() {
        myPhoton!.getVariable("caseRemovedRelatedRampDown", completion: { (result:Any?, error:Error?) -> Void in
            if let _ = error {
                print("Failed to read caseRemovedRelatedRampDown")
            }
            else {
                if let caseRemovedRelatedRampDown = result as? NSNumber {
                    print("caseRemovedRelatedRampDown is \(caseRemovedRelatedRampDown.stringValue)")
                    
                    let status = caseRemovedRelatedRampDown.intValue
                    if (status == 1) {
                        var popUpWindow: PopUpWindow!
                        popUpWindow = PopUpWindow(title: "Error", text: "Case removed - Ramping Down", buttontext: "OK")
                        self.present(popUpWindow, animated: true, completion: nil)
                        
                        self.seconds = 0
                        self.minutes = 0
                        self.CountdownLabel.text = "0\(self.minutes):0\(self.seconds)"
                    }
                }
            }
        })
        
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in
            if (self.seconds > 0) {
                self.seconds = self.seconds - 1
            } else if (self.minutes > 0 && self.seconds == 0) {
                self.minutes = self.minutes - 1
                self.seconds = 59
            }
            
            self.updateLabel()
        })
    }
    
    private func updateLabel() {
        if (minutes > 9 && seconds > 9) {
            CountdownLabel.text = "\(minutes):\(seconds)"
        } else if (minutes > 9 && seconds < 10) {
            CountdownLabel.text = "\(minutes):0\(seconds)"
        } else if (minutes < 10 && seconds > 9) {
            CountdownLabel.text = "0\(minutes):\(seconds)"
        } else if (minutes < 10 && seconds < 10) {
            CountdownLabel.text = "0\(minutes):0\(seconds)"
        } else if (minutes == 0 && seconds == 0) {
            
        }
    }
}


