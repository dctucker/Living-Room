//
//  InterfaceController.swift
//  Living Room WatchKit Extension
//
//  Created by Douglas Casey Tucker on 1/16/18.
//  Copyright © 2018 Douglas Casey Tucker. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        crownSequencer.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        crownSequencer.focus()
        self.getReceiverVolume()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBOutlet var valueLabel: WKInterfaceLabel!
    @IBOutlet var valueSlider: WKInterfaceSlider!
    @IBAction func valueSliderChanged(_ value: Float) {
        adjustReceiverVolume(before: myValue, after: Int(value))
    }
    
    func adjustReceiverVolume(before: Int, after: Int) {
        /*
        let difference: Int = abs(before - after)
        if after > before {
            if difference == 5 {
                incReceiverVolume()
            }
        } else if after < before {
            if difference == 5 {
                decReceiverVolume()
            }
        }
        */
        myValue = after
        setReceiverVolume(myValue)
    }
    
    var extDelegate: ExtensionDelegate {
        get {
            return WKExtension.shared().delegate as! ExtensionDelegate
        }
    }
    
    var myValue: Int = -270 {
        didSet {
            let text = String(format: "%2i.%i dB", myValue/10, abs(myValue % 10))
            valueLabel.setText(text)
            valueSlider.setValue(Float(myValue))
        }
    }
    var lastDirection: Int = 0
    var deltaBuffer: Double = 0
    
    func incReceiverVolume() {
        Comm.sharedInstance.putReceiver("<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Volume><Lvl><Val>Up</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")
    }

    func decReceiverVolume() {
        Comm.sharedInstance.putReceiver("<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Volume><Lvl><Val>Down</Val><Exp></Exp><Unit></Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>")
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
            self.myValue = a
        }
    }
}

extension InterfaceController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        lastDirection = Int(sign(rotationalDelta))
        deltaBuffer += rotationalDelta
        if abs(deltaBuffer) >= 0.1 {
            let newValue: Int = myValue + Int(sign(rotationalDelta) * 5)
            adjustReceiverVolume(before: myValue, after: newValue)
            deltaBuffer = 0
        }
    }
    
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        //myValue += lastDirection * 5
        //deltaBuffer = 0
        //getReceiverVolume()
    }
}
