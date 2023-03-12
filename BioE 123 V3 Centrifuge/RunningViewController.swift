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
    
    
    @IBOutlet weak var CentCountDown: UIDatePicker!
    
    let chartView = LineChartView()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(didUpdatedChartView), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        RPMNumber.text = String(setSpeed)
        
        CentCountDown.countDownDuration = (setTime * 60)

        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        chartView.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
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
}


