//
//  DocumentViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 9/30/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa


class DocumentViewController: NSWindowController{
    
    /**
     Initilizing instances of variables to be used within DocumentViewController only.
     */
    fileprivate var select = selected
    fileprivate var gotlib = getlib
    fileprivate var chosenMeta: [String] = []
    fileprivate var text: String = ""
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var filename: NSTextField!
    @IBOutlet weak var documentView: NSView!
    var lib: MMCollection?
    var file: MMFile?
    var index = 0
    var controller = NSWindowController()
    
    /**
     Needed so other windows controller can open call the DocumentViewController.
     */
    convenience init(file: MMFile, lib: MMCollection) {
        self.init(windowNibName: NSNib.Name(rawValue: "DocumentViewController"))
        self.file = file
        self.lib = lib
    }
    
    /**
     Overrides windowDidLoad function from NSWindowController and adds three extra functions and two conditions that are wanting to be called as soon as the window is opened.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        updateFilename()
        updateDoc(index: select)
        textView.isEditable = false
        scrollView.hasHorizontalScroller = true
        textView.sizeToFit()
        
    }
    
    /** Used for when we are cycling though the documents, updates to the next pointed at document.
     - Parameters index: Int passed in to point at a specified location in MMFile Array. Extracting the pathway to the media via MMFiles full pathway.
     */
    func updateDoc(index:Int){
        file = gotlib[index]
        if var fileExists = file {
            //self.videoView.window?.aspectRatio = NSSize(width: 16, height: 9)
            var realPath = fileExists.path
            realPath.append("/\(fileExists.filename)")
            var readFile = ""
            do {
                readFile = try String(contentsOfFile: realPath, encoding: .utf8)
            } catch{
            }
            textView.textStorage?.mutableString.setString("")
            textView.textStorage?.append(NSAttributedString(string: readFile))
            // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        }
    }
    
    /**
     When laucnhing the document windows, it places the correct metaData lable at the bottom of the window.
     */
    func updateFilename(){
        if select < gotlib.count && select != -1{
            for metadata in gotlib[select].metadata {
                chosenMeta.append(metadata.description)
            }
            text = chosenMeta.joined(separator: "\n")
        }
        filename.stringValue = text
    }
    
    /**
     Stops from having to write out document all the time.
     */
    private let fileType = "document"
    
    /** When pressed, the window will display the next document with the relevent MetaData.
     - Parameters _ sender: NSButton ">" is pressed
     */
    @IBAction func nextDocButton(_ sender: NSButton) {
        select += 1
        var modSelect = select % gotlib.count
        
        if modSelect == 0 && Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select += 1
            modSelect = select % gotlib.count
        }
        
        while Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select += 1
            modSelect = select % gotlib.count
            if Helper().checkType(file: (gotlib[modSelect])) == fileType {
                break
            }
        }
        
        if Helper().checkType(file: (gotlib[modSelect])) == fileType {
            chosenMeta = []
            for metadata in gotlib[modSelect].metadata{
                chosenMeta.append(metadata.description)
            }
            updateDoc(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
    }
    
    /** When pressed, the window will display the next document with the relevent MetaData.
     - Parameters _ sender: NSButton "<" is pressed
     */
    @IBAction func prevDocButton(_ sender: NSButton) {
        select -= 1
        var modSelect = (select + gotlib.count) % gotlib.count
        if modSelect <= 0{
            select = gotlib.count
            modSelect = (select + gotlib.count) % gotlib.count
        }
        
        if modSelect == 0 && Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select -= 1
            modSelect = (select + gotlib.count) % gotlib.count
            if modSelect <= 0{
                select = gotlib.count
                modSelect = (select + gotlib.count) % gotlib.count
            }
        }
        
        while Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select -= 1
            modSelect = (select + gotlib.count) % gotlib.count
            
            if modSelect <= 0{
                select = gotlib.count
                modSelect = (select + gotlib.count) % gotlib.count
            }
            if Helper().checkType(file: (gotlib[modSelect])) == fileType {
                break
            }
        }
        
        if Helper().checkType(file: (gotlib[modSelect])) == fileType {
            chosenMeta = []
            for metadata in gotlib[modSelect].metadata{
                chosenMeta.append(metadata.description)
            }
            updateDoc(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
    }
    
    
}
