//
//  AboutViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 10/3/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa

class AboutViewController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "AboutViewController"))
    }
    
    
}
