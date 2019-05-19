//
//  AppDelegate.swift
//  test
//
//  Created by Hyunsun Park on 9/27/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Cocoa

/**
    Initilizing instances of variables to be used throughout the project.
 */
var library: Collection = Collection()
var lib: Collection = Collection()
var filterLib: Collection = Collection()
var searchLib: Collection = Collection()
var last = MMResultSet()
var searchOn: Bool = false
var filterOn: Bool = false
var selected:Int = Int()
var getlib:[MMFile] = [MMFile]()
var getText: String = String()


/**
    A Struct created to manage and organize the MMFiles in Bookmark NSOutLineView.
 */
struct Favourite {
    var audioFiles: [MMFile]
    var documentFiles: [MMFile]
    var videoFiles: [MMFile]
    var imageFiles: [MMFile]
}



/**
    Extension for tableView. To help manipulate data in the NSTableView for our Bookmark NSOutlineView.
 */
extension NSTableView {
    /** When passed an Int, it selects that row in NSTableView.
     - Parameters index: A int for the specified row to be selected in NSTableView.
     */
    func selectRow(at index: Int) {
        selectRowIndexes(.init(integer: index), byExtendingSelection: false)
        if let action = action {
            perform(action)
        }
    }
}

var fav = Favourite(audioFiles: [], documentFiles: [], videoFiles: [], imageFiles: [])
let keys = ["audio", "video", "document", "image"]

/** Our Main file.
    Our AppDelegate class that holds all the functions, @IBOutlet, @IBAction that deal with the initial FileUI Window. Is also where we can connect and call other NSWindowControllers from.
 */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    /**
        Initilizing instances of variables to be used within appDelegate only.
     */
    var controller = NSWindowController()
    var controller1 = NSWindowController()
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var MetaDataLable: NSTextField!
    @IBOutlet weak var SearchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    /**
        Initilise lib collection type (used to be modified) instance with our library collection type (used as a backup / hard reset for lib).
     */
     var lib = library
    
    /** Support method to check if there is any duplicates within a MMFile array. Created because MMFile types are not hashable.
     - Parameters:
     - files: An array of MMfiles to be passed in and check if it contains
     - new: The MMFile that is being checked to see if it matches any MMFiles in the Array.
     
     - Returns: Boolean, true if the array contains the MMfile, otherwise false.
     */
    fileprivate func checkDupe(files: [MMFile], new: MMFile)-> Bool{
        var check = true
        for file in files{
            if file.description == new.description{
                check = false
            }
        }
        return check
    }
    
    /** Adds a selected MMFile from the NSTableVIew to the Bookmark and then groups it into the correct File Type. Once the sorting is finished, it reloads its self to display it in the FileUI window.
     - Parameter _ sender: NSMenuItem "Add to Bookmark" has been pressed.
     */
    @IBAction func addToBookMark(_ sender: Any) {
        if tableView.selectedRow != -1{
            let file = lib.all()[tableView.selectedRow]
            if Helper().checkType(file: file) == "image" {
                if checkDupe(files: fav.imageFiles, new: file){
                fav.imageFiles.append(file)
                }
            } else if Helper().checkType(file: file) == "audio"{
                if checkDupe(files: fav.audioFiles, new: file){
                    fav.audioFiles.append(file)
                }
            } else if Helper().checkType(file: file) == "document"{
                if checkDupe(files: fav.documentFiles, new: file){
                    fav.documentFiles.append(file)
                }
            } else if Helper().checkType(file: file) == "video"{
                if checkDupe(files: fav.videoFiles, new: file){
                    fav.videoFiles.append(file)
                }
            }
        }
        outlineView.reloadData()
    }
    
    /** Removes the selected MMFile from the Bookmark. It finds the MMfile by checking to see which group it is under and then the index of the child in that group. Once Removed, it reloads itsself to display the remaining bookmarks.
     - Parameter _ sender: NSMenuItem "Remove" has been pressed.
    */
    @IBAction func removeFromBookmark(_ sender: Any) {
        let item = outlineView.item(atRow: outlineView.selectedRow) as Any
        let childsParent = outlineView.parent(forItem: item) as? String
        let childIndex = outlineView.childIndex(forItem: item)
        if childsParent == "audio"{
            fav.audioFiles.remove(at: childIndex)
        } else if childsParent == "video"{
            fav.videoFiles.remove(at: childIndex)
        } else if childsParent == "document"{
            fav.documentFiles.remove(at: childIndex)
        } else if childsParent == "image"{
            fav.imageFiles.remove(at: childIndex)
        }
        outlineView.reloadData()
    }

    /** Works along side with Search and Notes. If a search is true, it will display everything that has been searched. Otherwise it displays everything in Library collection type.
     - Parameters _ sender: NSMenuitem "All" has been pressed.
    */
    @IBAction func AllFilterAction(_ sender: Any) {
        filterOn = false
        filterLib = Collection()
        if searchOn {
            lib = Collection()
            lib = searchLib
            tableView.reloadData()
        }else{
            lib = Collection()
            lib = library
            tableView.reloadData()
        }
        updateNotesArray()
    }
    
    /** Works along side with Search and Notes. If a search is true, it will display everything that has been searched AND is of type Image. Otherwise it displays just Image type.
     - Parameters _ sender: NSMenuitem "Image" has been pressed.
     */
    @IBAction func ImageFilterAction(_ sender: Any) {
        filterOn = true
        filterLib = Collection()
        if searchOn {
            for file in searchLib.all(){
                if Helper().checkType(file: file) == "image"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }else{
            for file in library.all(){
                if Helper().checkType(file: file) == "image"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }
        updateNotesArray()
    }
    
    /** Works along side with Search and Notes. If a search is true, it will display everything that has been searched AND of video type. Otherwise it displays just video type.
     - Parameters _ sender: NSMenuitem "Video" has been pressed.
     */
    @IBAction func VideoFilterAction(_ sender: Any) {
        filterOn = true
        filterLib = Collection()
        if searchOn {
            for file in searchLib.all(){
                if Helper().checkType(file: file) == "video"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }else{
            for file in library.all(){
                if Helper().checkType(file: file) == "video"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }
        updateNotesArray()
    }
    
    /** Works along side with Search and Notes. If a search is true, it will display everything that has been searched AND of audio type. Otherwise it displays just audio type.
     - Parameters _ sender: NSMenuitem "Audio" has been pressed.
     */
    @IBAction func AudioFilterAction(_ sender: Any) {
        filterOn = true
        filterLib = Collection()
        if searchOn {
            for file in searchLib.all(){
                if Helper().checkType(file: file) == "audio"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }else{
            for file in library.all(){
                if Helper().checkType(file: file) == "audio"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }
        updateNotesArray()
    }
    
    /** Works along side with Search and Notes. If a search is true, it will display everything that has been searched AND of Document type. Otherwise it displays just document type.
     - Parameters _ sender: NSMenuitem "Document" has been pressed.
     */
    @IBAction func DocumentFilterAction(_ sender: Any) {
        filterOn = true
        filterLib = Collection()
        if searchOn {
            for file in searchLib.all(){
                if Helper().checkType(file: file) == "document"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }else{
            for file in library.all(){
                if Helper().checkType(file: file) == "document"{
                    filterLib.add(file: file)
                }
            }
            lib = Collection()
            lib = filterLib
            tableView.reloadData()
        }
        updateNotesArray()
    }

    /** Imports MMfiles from a specified directory using NSOpenPanel to suply the corrrect URL pathway. Once the files have been imported, it then reloads the NSTableView and updates the NotesArray Struct.
     - Parameter _ Sender: NSButton "Import" is pressed
    */
    @IBAction func ImportButton(_ sender: NSButtonCell) {
        let importFile: NSOpenPanel = NSOpenPanel()
        let checkDupeCollection: Collection = Collection()
        
        importFile.allowsMultipleSelection = true
        importFile.canChooseFiles = true
        importFile.canChooseDirectories = false
        importFile.runModal()
        
        let chosenImportFile = importFile.urls
        if chosenImportFile.isEmpty == false {
            var libEmpty = false
            if library.all().count == 0{
                libEmpty = true
            }
            for file in chosenImportFile {
                if libEmpty {
                    library.load(filename: file.path)
                }
                if libEmpty == false{
                    checkDupeCollection.load(filename: file.path)
                    let newImportFile: [MMFile] = checkDupeCollection.all()
                    for newFile in newImportFile{
                        if checkDupe(files: library.all(), new: newFile){
                            library.add(file: newFile)
                        }
                    }
                }
            }
            tableView.reloadData()
            updateNotesArray()
        }
    }
    
    /** Exports MMfiles that is currently displayed in NSTabelVIew using NSSavePanel to chose a directory to save it in. This works with both filter and search functions.
     - Parameter _ Sender: NSButton "Export" is pressed
     */
    @IBAction func ExportButton(_ sender: NSButtonCell) {
        let exportFile = NSSavePanel()
        
        exportFile.showsTagField = false
        exportFile.canCreateDirectories = true
        exportFile.showsHiddenFiles = true
        exportFile.prompt = "Export MetaData"
        exportFile.nameFieldLabel = "Pick a name, any name"
        exportFile.nameFieldStringValue = "ExportedFile"
        exportFile.allowedFileTypes = ["json"]
        exportFile.runModal()
        
        lib.save(filename: (exportFile.url?.path)!)
    }
    
    /** Opens the Note Window Controller.
     - Parameters _ sender: NSButton "Add Notes" is pressed
     */
    @IBAction func addNoteClicked(_ sender: Any) {
        controller1 = AddNoteViewController()
        controller1.showWindow(self)
    }
    
    /** This function is called as soon as the FileUI starts up. Used to initilize the states of other Objects. Like Search Menu Field or the meta data lable.
     - Parameters _ aNotification: The FileUI finishes launching.
     */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        tableView.dataSource = self
        tableView.delegate = self
        outlineView.dataSource = self
        outlineView.delegate = self
        createMenuField()
        updateStatus()
        updateNotesArray()
    }
    
    /** Updates the NotesArray given three conditions.
        - There is nothing in the notes array and thus the first MMFile have yet to be imported.
        - NotesArray already contins files but additional files have been imported so it needs to be updated.
        - Filter OR search is on and it needs to make sure notes added during a search or a filter is attatched to the right files when displaying "All" files.
    */
    func updateNotesArray(){
        if noteArray.count == 0 {
            for file in lib.all(){
                let notes = FileNotes(file: file, Note: "Notes for: \(file.filename)")
                noteArray.append(notes)
            }
        }else if noteArray.count < lib.all().count{
            for i in (noteArray.count) ... (lib.all().count-1){
                let notes = FileNotes(file: lib.all()[i], Note: "Notes for: \(lib.all()[i].filename)")
                noteArray.append(notes)
            }

        } else if filterOn || searchOn{
            noteArrayModified = []
            for file in lib.all(){
                for noteFile in noteArray {
                    if noteFile.file.description == file.description{
                        noteArrayModified.append(noteFile)
                    }
                }
            }
        }
    }
    
    /** Updates the Bookmakrs NSOutlineVIew on the event of a double click.
     - Parameters _ notification: A double click has been registered.
     */
    func outlineViewSelectionDidChange(_ notification: Notification){
        outlineView.target = self
        outlineView.doubleAction = #selector(bookMarkViewDoubleClick(_:))
    }
    
    /** Goes through the Bookmark returns either groups are expandable or the child and the group they are currently contained in.
     - Parameters:
     - _ outlineView: Current NSOutlineVIew.
     - child index: The int of the selected row in our BookMark.
     - item: Contents of a row in bookmark.
 
     - Returns: Type Any(Grouping name) or (Grouping name, childs index)
     */
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return keys[index]
        } else if let item = item as? String, item == "image" {
            return ("image", index)
        }else if let item = item as? String, item == "document"{
            return ("document", index)
        }else if let item = item as? String, item == "audio"{
            return ("audio", index)
        }else if let item = item as? String, item == "video"{
            return ("video", index)
        } else {
            return 0
        }
    }
    
    /** Creats the correct number of rows for the groups as well as the number of children each grouping has.
     - Parameters:
     - _ outlineView: Current NSOutlineView
     - numberOfChildrenOfItem item: Contents of a row in bookmark.
 
     - Returns: Number of rows needed to be interactive
    */
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return keys.count
        } else if let item = item as? String, item == "image" {
            return fav.imageFiles.count
        }else if let item = item as? String, item == "document"{
            return fav.documentFiles.count
        }else if let item = item as? String, item == "audio"{
            return fav.audioFiles.count
        }else if let item = item as? String, item == "video"{
            return fav.videoFiles.count
        } else {
            return 0
        }
    }
    
    /** Allows the selected instances of a few to be expandable and be able to hold children.
     - Parameters:
     - _ outlineView: Current NSOutlineView
     - isItemExpandable item: Contents of bookmark.
 
     - Returns: Boolean if the item in Bookmark can be expandable.
     */
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? String,
            item == "image"
                || item == "document"
                || item == "audio"
                || item == "video"{
            return true
        } else {
            return false
        }
    }
    
    /** Goes through outline view and populates the rows. In this case, populates the MMfile Groups with the correct file name.
     - Parameters:
     - _ outlineView: Current NSOutlineView.
     - viewFor tableColumn.
     - item: Contents of bookmark.
     
     - Returns: The Bookmark table. If empty, it will just display the gourps. Otherwise it will display the groups children as well.
 
     */
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }
        
        var text = ""
        
        switch (columnIdentifier, item) {
        case ("keyColumn", let item as String):
            switch item {
            case "audio":
                text = "Audio"
            case "video":
                text = "Video"
            case "image":
                text = "Image"
            case "document":
                text = "Document"
            default:
                break
            }
        case ("keyColumn", _):
            if let (key, index) = item as? (String, Int), key == "image" {
                text = fav.imageFiles[index].filename
            }
            if let (key, index) = item as? (String, Int), key == "audio" {
                text = fav.audioFiles[index].filename
            }
            if let (key, index) = item as? (String, Int), key == "document" {
                text = fav.documentFiles[index].filename
            }
            if let (key, index) = item as? (String, Int), key == "video" {
                text = fav.videoFiles[index].filename
            }
        default:
            text = ""
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewCell")
        let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = text
        
        return cell
    }
    
    /** A support function. This returns the Index of a MMfile matching an MMfile in lib collection type.
     - Parameters file: The file that is being searched for in the lib collection
     
     - Returns: Index of which it was found.
     */
    fileprivate func bookmarkSearchTableView(file: MMFile) -> Int{
        var returnedIndex = 0
        for libFile in lib.all(){
            if file.description == libFile.description
                && Helper().checkType(file: file) == Helper().checkType(file: libFile){
                break
            }
            returnedIndex += 1
        }
        return returnedIndex
    }
    
    /** This method does two things.
     - First thing is when a row is double clicked and its not a groupable item, index in tableView corresponding to the item in bookmark and highlights it.
     - Second thing is, if you double click on an expandable item, the group will either expand or collapse accordingly.
 
     - Parameters _ sender: Action of an item being double clicked.
     */
    @objc func bookMarkViewDoubleClick(_ sender: AnyObject){
        let item = outlineView.item(atRow: outlineView.selectedRow) as Any
        let childsParent = outlineView.parent(forItem: item) as? String
        let childIndex = outlineView.childIndex(forItem: item)
        if outlineView.selectedRow != -1 {
            if childsParent == "audio"{
                tableView.selectRow(at: bookmarkSearchTableView(file: fav.audioFiles[childIndex]))
            } else if childsParent == "video"{
                tableView.selectRow(at: bookmarkSearchTableView(file: fav.videoFiles[childIndex]))
            } else if childsParent == "document"{
                tableView.selectRow(at: bookmarkSearchTableView(file: fav.documentFiles[childIndex]))
            } else if childsParent == "image"{
                tableView.selectRow(at: bookmarkSearchTableView(file: fav.imageFiles[childIndex]))
            }else if outlineView.isExpandable(item) && outlineView.isItemExpanded(item) == false{
                outlineView.expandItem(item)
            }else if outlineView.isExpandable(item) && outlineView.isExpandable(item) == true{
                outlineView.collapseItem(item)
            }
        }
    }
    
    /** Function in here can be called when FileUI session is terminated.
     - Parameters _ aNotification: The action of closing down the window.
     */
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /** This keeps up any changes that has happened in tableView. This working while the application is running.
     - Parameters _Notification: Any action taking place within tableView.
     
     */
    func tableViewSelectionDidChange(_ notification: Notification) {
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        updateStatus()
        createMenuField()
    }
    
    /** Creats the correct number of rows for the tableView based on what is in lib collection type.
     - Parameters in tableView: Current NSTableView.
     
     - Returns: Number of rows needed to be interactive.
     */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return lib.all().count
    }
    
    /**
        Organizes the names for TableView column cells so it can be used when populating the tableView.
     */
    fileprivate enum CellIDs {
        static let KindCell = "KindCellID"
        static let NameCell = "NameCellID"
    }
    
    /** Populates the tableView one row at a time, filling both collumns with relevent information. Kind is filled with MMFile types while Name is filled with MMFile names.
     - Parameters:
     - _ tablveView: Current tableView.
     - viewFor tableColumn: TableView Columns
     - row: An incremented index that goes for the full length of rows created.
     
     - Returns: The TableView.
 
    */
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellID: String = ""
        let mmfile = lib.all()[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = Helper().checkType(file: mmfile)
            cellID = CellIDs.KindCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = mmfile.filename
            cellID = CellIDs.NameCell
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        print("Something went wrong")
        return nil
    }
    
   /** function that will update the NSTextField that holds the metaData for the currently selected row.
     */
    func updateStatus() {
        var text: String = "These are not the \n MetaData you are looking for"
        var file:[MMFile] = lib.all()
        let index:Int = tableView.selectedRow
        var chosenMeta: [String] = []
        selected = index
        getlib = file

        if index < lib.all().count && index != -1 {
            for metadata in file[index].metadata {
                chosenMeta.append(metadata.description)
            }
            text = chosenMeta.joined(separator: "\n")
        }
        MetaDataLable.stringValue = text
    }
    
    /** Creates and customizes a menuFiled for the search bar. This is also where the properties for the Search Bar is set.
    */
    func createMenuField(){
        let menu = NSMenu()
        menu.title = "Menu"
        
        SearchField.sendsSearchStringImmediately = false
        SearchField.sendsWholeSearchString = true
        
        let allMenuItem = NSMenuItem()
        allMenuItem.title = "All"
        allMenuItem.target = self
        allMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        let metaDataMenuItem = NSMenuItem()
        metaDataMenuItem.title = "MetaData"
        metaDataMenuItem.target = self
        metaDataMenuItem.action = #selector(changeSearchFieldItem(_:))
        
        
        menu.addItem(allMenuItem)
        menu.addItem(metaDataMenuItem)
        
        self.SearchField.searchMenuTemplate = menu
        self.changeSearchFieldItem(allMenuItem)
    }
    
    
    /** Applies the names of the new search feild items to the search Bar its self.
    */
    @objc func changeSearchFieldItem(_ sender: AnyObject){
        (self.SearchField.cell as? NSSearchFieldCell)?.placeholderString = sender.title
    }
    
    /** The search function that works with both notes and Filter. Based on if the filter is on and what search menu field is selected. The search will respond accordingly.
     - Parameters _ sender: the search string being entered into the search bar.
    */
    @IBAction func search(_ sender: Any) {
        let searchString = SearchField.stringValue
        if filterOn {
            searchLib = Collection()
            if searchString.isEmpty {
                searchOn = false
                searchLib = Collection()
                searchLib = filterLib
                lib = searchLib
                tableView.reloadData()
            }else{
                searchOn = true
                if (SearchField.cell as? NSSearchFieldCell)?.placeholderString == "All"{
                    let mmfileArray = filterLib.searchAll(term: searchString)
                    searchLib = Collection()
                    for file in mmfileArray {
                        searchLib.add(file: file)
                    }
                    lib = Collection()
                    lib = searchLib
                    tableView.reloadData()
                }else if (SearchField.cell as? NSSearchFieldCell)?.placeholderString == "MetaData"{
                    let mmfileArray = filterLib.search(term: searchString)
                    searchLib = Collection()
                    for file in mmfileArray {
                        searchLib.add(file: file)
                    }
                    lib = Collection()
                    lib = searchLib
                    tableView.reloadData()
                }
            }
        }else{
            if searchString.isEmpty {
                searchOn = false
                searchLib = Collection()
                searchLib = library
                lib = searchLib
                tableView.reloadData()
            }else{
                searchOn = true
                if (SearchField.cell as? NSSearchFieldCell)?.placeholderString == "All"{
                    let mmfileArray = lib.searchAll(term: searchString)
                    searchLib = Collection()
                    for file in mmfileArray {
                        searchLib.add(file: file)
                    }
                    lib = Collection()
                    lib = searchLib
                    tableView.reloadData()
                }else if (SearchField.cell as? NSSearchFieldCell)?.placeholderString == "MetaData"{
                    let mmfileArray = lib.search(term: searchString)
                    searchLib = Collection()
                    for file in mmfileArray {
                        searchLib.add(file: file)
                    }
                    lib = Collection()
                    lib = searchLib
                    tableView.reloadData()
                }
            }
        }
        updateNotesArray()
    }
    
    /** Opens About window controller.
     - Parameters _ sender: NSMenuItem "About test" was clicked.
     */
    @IBAction func aboutClicked(_ sender: Any) {
        controller = AboutViewController()
        controller.showWindow(self)
    }
    
    /** Handles the action of the tableView being double clicked. Depending on the file that is being double clicked will open up different windows controllers.
     - Videos: VideoController + relevent Notes
     - Image: ImageController + relevent Notes
     - Document: DocumentController + relevent Notes
     - Audio: AudioController + relevent Notes
     
     - Parameters _ sender: the action of being double clicked.
     
    */
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let collectionOfFiles:[MMFile] = lib.all()
        let index: Int = tableView.selectedRow
        controller = NSWindowController()
        controller1 = NSWindowController()
        
        if index < collectionOfFiles.count && index != -1 {
            guard index >= 0,
                let item = lib.all()?[index]
                else{
                    return
            }
            let extensionType = item.filename.split(separator: ".")[1]
            selected = tableView.selectedRow
            if extensionType == "mp4" || extensionType == "mov"{
                controller = VideoViewController(file: collectionOfFiles[index], lib: self.lib)
                controller.showWindow(self)
                controller1 = AddNoteViewController()
                controller1.showWindow(self)
            }
            else if extensionType == "jpg" || extensionType == "png"{
                controller = ImageViewController(file: collectionOfFiles[index], lib: self.lib)
                controller.showWindow(self)
                controller1 = AddNoteViewController()
                controller1.showWindow(self)
            }
            else if extensionType == "txt"{
                controller = DocumentViewController(file: collectionOfFiles[index], lib: self.lib)
                controller.showWindow(self)
                controller1 = AddNoteViewController()
                controller1.showWindow(self)
            }
            else if extensionType == "m4a" || extensionType == "mp3"{
                controller = AudioViewController(file: collectionOfFiles[index], lib: self.lib)
                controller.showWindow(self)
                controller1 = AddNoteViewController()
                controller1.showWindow(self)
            }
            else{
                controller = ErrorViewController()
                controller.showWindow(self)
            }
        }
    }
}





