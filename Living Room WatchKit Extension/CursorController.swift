//
//  CursorController.swift
//  Living Room WatchKit Extension
//
//  Created by Douglas Casey Tucker on 1/17/18.
//  Copyright © 2018 Douglas Casey Tucker. All rights reserved.
//

import Foundation
import WatchKit

class CursorController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    var extDelegate: ExtensionDelegate {
        get {
            return WKExtension.shared().delegate as! ExtensionDelegate
        }
    }

    var CURSOR_CODES = [
            "Up": "7A859D62",
            "Down": "7A859C63",
            "Left": "7A859F60",
            "Right": "7A859E61",
            "Enter": "7A85DE21",
            "Return": "7A85AA55",
            "Level": "7A858679",
            "On Screen": "7A85847B",
            "Option": "7A856B14",
            "Top Menu": "7A85A0DF",
            "Pop Up Menu": "7A85A4DB"
    ]
    
    @IBAction func upButton() {
        Comm.sharedInstance.sendUp()
    }
    @IBAction func downButton() {
        Comm.sharedInstance.sendDown()
    }
    @IBAction func leftButton() {
        Comm.sharedInstance.sendLeft()
    }
    @IBAction func rightButton() {
        Comm.sharedInstance.sendRight()
    }
    @IBAction func backButton() {
        Comm.sharedInstance.sendBack()
    }
    @IBAction func enterButton() {
        Comm.sharedInstance.sendEnter()
    }
    
}
