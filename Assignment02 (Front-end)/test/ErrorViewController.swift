//
//  ErrorViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 9/30/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa

class ErrorViewController: NSWindowController {

    @IBOutlet weak var errorView: NSView!
    var createLayerSwitch = true
    var controller = NSWindowController()
    override func windowDidLoad() {
        super.windowDidLoad()
        createLayerSwitch = false
        //implement to close

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "ErrorViewController"))
    }
    
}
