//
//  test.swift
//  test
//
//  Created by Hyunsun Park on 9/27/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa

class test: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    convenience init() {
        self.init(windowNibName: NSNib.Name("test"))
    }
}
