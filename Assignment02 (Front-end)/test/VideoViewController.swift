//
//  VideoViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 9/30/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa
import AVKit


class VideoViewController: NSWindowController, NSWindowDelegate {

    /**
     Initilizing instances of variables to be used within VideoViewController only.
     */
    @IBOutlet weak var videoView: AVPlayerView!
    @IBOutlet weak var filename: NSTextField!
    fileprivate var select = selected
    fileprivate var gotlib = getlib
    fileprivate var chosenMeta: [String] = []
    fileprivate var text: String = ""
    var lib: MMCollection?
    var file: MMFile?
    var index = 0
    var player: AVPlayer?
    var controller = NSWindowController()

    /**
     Needed so other windows controller can open call the VideoViewController.
    */
    convenience init(file: MMFile, lib: MMCollection) {
        self.init(windowNibName: NSNib.Name(rawValue: "VideoViewController"))
        self.file = file
        self.lib = lib
    }
    /**
    Overrides windowDidLoad function from NSWindowController and adds two extra functions that are wanting to be called as soon as the window is opened.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        updateFilename()
        updateVideo(index:select)
    }
    
    /**
     When window is being closed, calls a function to stop the media playing in the window.
     */
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        //need to add something to stop playing
        stopPlayer()
        return true
    }
    
    /**
     Stops the Video that is currently being played in the window once the window is clsoed.
    */
    func stopPlayer(){
        if let play = player {
            play.pause()
            player = nil
        }
    }
    
    /** Used for when we are cycling though the videos, updates to the next pointed at video.
     - Parameters index: Int passed in to point at a specified location in MMFile Array. Extracting the pathway to the media via MMFiles full pathway.
     */
    func updateVideo(index: Int){
        file = gotlib[index]
        if var fileExists = file{
            self.videoView.window?.aspectRatio = NSSize(width: 16, height: 9)
            
            var realPath = fileExists.path
            realPath.append("/\(fileExists.filename)")
            
            let nsUrl = NSURL(fileURLWithPath: realPath)
            player = AVPlayer(url: nsUrl as URL)
            videoView.player = player
        }
    }
    
    /**
     Stops from having to write out video all the time.
     */
    private let fileType = "video"
    
    /** When pressed, the window will display the next video with the relevent MetaData.
     - Parameters _ sender: NSButton ">" is pressed
     */
    @IBAction func nextVidClicked(_ sender: Any) {
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
            updateVideo(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
            
        }
    }


        
    /** When pressed, the window will display the next video with the relevent MetaData.
     - Parameters _ sender: NSButton "<" is pressed
     */
    @IBAction func prevVidClicked(_ sender: Any) {
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
            updateVideo(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
        
    }
    
    /**
     When laucnhing the Video windows, it places the correct metaData lable at the bottom of the window.
     */
    func updateFilename(){
        if select < gotlib.count && select != -1{
            for metadata in gotlib[select].metadata{
                chosenMeta.append(metadata.description)
            }
            text = chosenMeta.joined(separator: "\n")
        }
        filename.stringValue = text
    }
}
