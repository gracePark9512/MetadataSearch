//
//  AudioViewController.swift
//  FileUI
//
//  Created by Hyunsun Park on 9/30/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class AudioViewController: NSWindowController , NSWindowDelegate {
    
    /**
     Initilizing instances of variables to be used within AudioViewController only.
     */
    @IBOutlet weak var filename: NSTextField!
    fileprivate var select = selected
    fileprivate var gotlib = getlib
    fileprivate var chosenMeta: [String] = []
    fileprivate var text: String = ""
    var lib: MMCollection?
    var file: MMFile?
    var index = 0
    var soundPlayer: AVAudioPlayer?
    var playView = AVPlayer()
    var controller = NSWindowController()
    var stopped = false
    var closed = false

    /**
     Needed so other windows controller can open call the AudioViewController.
     */
    convenience init(file: MMFile, lib: MMCollection) {
        self.init(windowNibName: NSNib.Name(rawValue: "AudioViewController"))
        self.file = file
        self.lib = lib
    }
    
    /**
     Overrides windowDidLoad function from NSWindowController and adds two extra functions that are wanting to be called as soon as the window is opened.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        updateFilename()
        updateAudio(index: select)
        }

    /** Pauses the audio file.
     - Parameter _ sender: NSButton "Pause" was pressed
     */
    @IBAction func pauseClicked(_ sender: Any) {
        soundPlayer?.pause()
        stopped = false
    }
    
    /** Play the audio file.
     - Parameter _ sender: NSButton "Play" was pressed
     */
    @IBAction func playClicked(_ sender: Any) {
        soundPlayer?.play()
        if stopped == true{
            soundPlayer?.currentTime = 0.0
        }
    }
    /** Stops the audio file.
     - Parameter _ sender: NSButton "Stop" was pressed
     */
    @IBAction func stopClicked(_ sender: Any) {
        stopping()
    }
    
    /**
     Support function for stoping the audio file.
     */
   @objc  func stopping(){
        soundPlayer?.stop()
        stopped = true
    }
    
    /**
     When window is being closed, calls a function to stop the media playing in the window.
     */
     func windowShouldClose(_ sender: NSWindow) -> Bool {
        stopping()
        return true
    }
    
    /** Used for when we are cycling though the audios, updates to the next pointed at audio.
     - Parameters index: Int passed in to point at a specified location in MMFile Array. Extracting the pathway to the media via MMFiles full pathway.
     */
    func updateAudio(index: Int){
        file = gotlib[index]
        if var fileExists = file{
            var realPath = fileExists.path
            realPath.append("/\(fileExists.filename)")
            let url = URL(fileURLWithPath: realPath)

            do{
                soundPlayer = try AVAudioPlayer(contentsOf: url)
            }catch{
               //cannot load
            }
        }
    }

    /**
     Stops from having to write out audio all the time.
     */
    private let fileType = "audio"
    
    /** When pressed, the window will display the next audio with the relevent MetaData.
     - Parameters _ sender: NSButton ">" is pressed
     */
    @IBAction func next(_ sender: Any) {
        stopping()
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
                //select -= 1
                break
            }
        }
        
        if Helper().checkType(file: (gotlib[modSelect])) == fileType {
            chosenMeta = []
            for metadata in gotlib[modSelect].metadata{
                chosenMeta.append(metadata.description)
            }
            updateAudio(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
        
    }
    
    /** When pressed, the window will display the next audio with the relevent MetaData.
     - Parameters _ sender: NSButton "<" is pressed
     */
    @IBAction func prev(_ sender: Any) {
        stopping()
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
            updateAudio(index: modSelect)
            filename.stringValue = chosenMeta.joined(separator: "\n")
        }
        
    }
    
    /**
     When laucnhing the audio windows, it places the correct metaData lable at the bottom of the window.
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
    

