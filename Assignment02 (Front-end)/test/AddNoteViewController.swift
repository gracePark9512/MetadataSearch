//
//  AddNoteViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 10/2/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa

/**
    Initilizes two arrays of type FileNote. This is what will used to keep a track and order the Notes unique to each file.
 */
var noteArray:[FileNotes] = []
var noteArrayModified:[FileNotes] = []

/**
    Struct that will hold a media file and the corresponding notes that go with them.
 */
struct FileNotes {
    var file: MMFile
    var Note: String
}

class AddNoteViewController: NSWindowController {

    /**
     Initilizing instances of variables to be used within AddNoteViewController only.
     */
    @IBOutlet var textView: NSTextView!
    
    /**
     Overrides windowDidLoad function from NSWindowController and adds one extra functions that are wanting to be called as soon as the window is opened.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        updateText()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    /**
     When laucnhing the note windows, it puts inside the text feild the correct information that is unique to each MMFile.
     */
    func updateText(){
        if filterOn || searchOn {
            textView.textStorage?.append(NSAttributedString(string: noteArrayModified[selected].Note))
        } else {
            textView.textStorage?.append(NSAttributedString(string: noteArray[selected].Note))
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if filterOn || searchOn {
             noteArrayModified[selected].Note = (textView.string)
            for i in 0 ... noteArray.count - 1{
                if noteArray[i].file.description == noteArrayModified[selected].file.description{
                    noteArray[i].Note = noteArrayModified[selected].Note
                }
            }
        }else{
             noteArray[selected].Note = (textView.string)
        }
    }
    
    /**
     Needed so other windows controller can open call the AddNoteViewController.
     */
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "AddNoteViewController"))
    }
}
