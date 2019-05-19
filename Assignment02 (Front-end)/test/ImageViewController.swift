//
//  ImageViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 9/30/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa
import Quartz

class ImageViewController: NSWindowController, NSWindowDelegate{

    /**
     Initilizing instances of variables to be used within ImageViewControllervid only.
     */
    @IBOutlet weak var imageView: NSView!
    @IBOutlet weak var filename: NSTextFieldCell!
    @IBOutlet weak var imageFrame: NSImageView!
    fileprivate var select = selected
    fileprivate var gotlib = getlib
    fileprivate var chosenMeta: [String] = []
    fileprivate var text: String = ""
    var lib: MMCollection?
    var file: MMFile?
    var index = 0
    var controller = NSWindowController()
    
    /**
     Needed so other windows controller can open call the ImageViewController.
     */
    convenience init(file: MMFile, lib: MMCollection) {
        self.init(windowNibName: NSNib.Name(rawValue: "ImageViewController"))
        self.file = file
        self.lib = lib
    }

    /**
     Overrides windowDidLoad function from NSWindowController and adds two extra functions that are wanting to be called as soon as the window is opened.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        updateFilename()
        updateImage(index: select)

    }
    
    /** Used for when we are cycling though the images, updates to the next pointed at image.
     - Parameters index: Int passed in to point at a specified location in MMFile Array. Extracting the pathway to the media via MMFiles full pathway.
     */
    func updateImage(index: Int){
        file = gotlib[index]
        
        if var fileExists = file{
            var realPath = fileExists.path
            realPath.append("/\(fileExists.filename)")
            let url = URL(fileURLWithPath: realPath)
            let viewer = NSImage(contentsOf: url)
            imageFrame.image = viewer
        }
    }
    
    /**
     Stops from having to write out image all the time.
     */
    private let fileType = "image"
    
    /** When pressed, the window will display the next iamge with the relevent MetaData.
     - Parameters _ sender: NSButton ">" is pressed
     */
    @IBAction func next(_ sender: Any) {
        select += 1
        var modSelect = select % gotlib.count
        
        if modSelect == 0 && Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select += 1
            modSelect = select % gotlib.count
        }
        
        while Helper().checkType(file: (gotlib[modSelect])) != fileType {
            select += 1
            modSelect = select % gotlib.count
            if Helper().checkType(file: (gotlib[modSelect])) == fileType{
                break
            }
        }
        
        if Helper().checkType(file: (gotlib[modSelect])) == fileType {
            chosenMeta = []
            for metadata in gotlib[modSelect].metadata{
                chosenMeta.append(metadata.description)
            }
            updateImage(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
    }
    
    /** When pressed, the window will display the next image with the relevent MetaData.
     - Parameters _ sender: NSButton "<" is pressed
     */
    @IBAction func prev(_ sender: Any) {
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
            if Helper().checkType(file: (gotlib[modSelect])) == fileType{
                break
            }
        }
        
        if Helper().checkType(file: (gotlib[modSelect])) == fileType {
            chosenMeta = []
            for metadata in gotlib[modSelect].metadata{
                chosenMeta.append(metadata.description)
            }
            updateImage(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
        
    }
    
    /**
     When laucnhing the image windows, it places the correct metaData lable at the bottom of the window.
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

    
}
