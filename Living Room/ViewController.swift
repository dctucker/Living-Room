//
//  ViewController.swift
//  Living Room
//
//  Created by Douglas Casey Tucker on 1/16/18.
//  Copyright © 2018 Douglas Casey Tucker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushUp() {
        Comm.sharedInstance.sendUp()
    }
    
    @IBAction func pushDown() {
        Comm.sharedInstance.sendDown()
    }

    @IBAction func pushLeft() {
        Comm.sharedInstance.sendLeft()
    }
    
    @IBAction func pushRight() {
        Comm.sharedInstance.sendRight()
    }

    @IBAction func valueSliderChanged() {
        myValue = Int(valueSlider.value)
        self.setReceiverVolume(myValue)
    }
    
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var valueSlider: UISlider!

    var myValue: Int = -270 {
        didSet {
            let text = String(format: "%2i.%i dB", myValue/10, abs(myValue % 10))
            valueLabel.text = text
            valueSlider.value = Float(myValue)
        }
    }

    func setReceiverVolume(_ volume: Int) {
        //Comm.sharedInstance.queueVolumeChange()
        Comm.sharedInstance.queueReceiver(body: Comm.xmlVolumeChange(volume), success: {_ in
            if Comm.sharedInstance.asyncCounter <= 0 {
                Comm.sharedInstance.asyncCounter = 0
                self.getReceiverVolume()
            }
        })
    }
    
    func getReceiverVolume() {
        Comm.sharedInstance.getReceiverVolume() { a in
            DispatchQueue.main.async {
                self.myValue = a
            }
        }
    }

}

