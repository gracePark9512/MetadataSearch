//
//  cli.swift
//  MediaLibraryManager
//  COSC346 S2 2018 Assignment 1
//
//  Created by Paul Crane on 21/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

/// The list of exceptions that can be thrown by the CLI command handlers
enum MMCliError: Error {
    
    /// Thrown if there is something wrong with the input parameters for the
    /// command
    case invalidParameters
    
    /// Thrown if there is no result set to work with (and this command depends
    /// on the previous command)
    case missingResultSet
    
    /// Thrown when the command is not understood
    case unknownCommand
    
    /// Thrown if the command has yet to be implemented
    case unimplementedCommand
    
    /// Thrown if there is no command given
    case noCommand
    
    /// Thrown if .json is in the wrong layout and could not decode
    case couldNotDecode
    
    /// Thrown if .json could not be converted into utf8
    case couldNotConvert
    
    /// Thrown if load is fed a String that is not a .json file
    case invalidLoadInput
    
    /// Thrown if index is out of bounds
    case outOfBoundsError
    
    /// Throws if index is not found
    case notFoundError
    
    /// Throws if index is empty
    case emptyError
}

/// Generate a friendly prompt and wait for the user to enter a line of input
/// - parameter prompt: The prompt to use
/// - parameter strippingNewline: Strip the newline from the end of the line of
///   input (true by default)
/// - return: The result of `readLine`.
/// - seealso: readLine
func prompt(_ prompt: String, strippingNewline: Bool = true) -> String? {
    // the following terminator specifies *not* to put a newline at the
    // end of the printed line
    print(prompt, terminator:"")
    return readLine(strippingNewline: strippingNewline)
}

/// This class representes a set of results.
class MMResultSet{
    
    /// The list of files produced by the command
    private var results: [MMFile]
    
    /// Constructs a new result set.
    /// - parameter results: the list of files produced by the executed
    /// command, could be empty.
    init(_ results:[MMFile]){
        self.results = results
    }
    /// Constructs a new result set with an empty list.
    convenience init(){
        self.init([MMFile]())
    }
    
    /// If there are some results to show, enumerate them and print them out.
    /// - note: this enumeration is used to identify the files in subsequent
    /// commands.
    func showResults(){
        guard self.results.count > 0 else{
            return
        }
        for (i,file) in self.results.enumerated() {
            print("\(i): \(file)")
        }
    }
    
    /// Determines if the result set has some results.
    /// - returns: True iff there are results in this set
    func hasResults() -> Bool{
        return self.results.count > 0
    }
}

/// The interface for the command handler.
protocol MMCommandHandler{
    
    /// The handle function executes the command.
    ///
    /// - parameter params: The list of parameters to the command. For example,
    /// typing 'load foo.json' at the prompt will result in params containing
    /// *just* the foo.json part. 
    ///
    /// - parameter last: The previous result set, used to give context to some
    /// of the commands that add/set/del the metadata associated with a file.
    ///
    /// - Throws: one of the `MMCliError` exceptions
    ///
    /// - returns: an instance of `MMResultSet`
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet;
    
}

/// Handles the 'help' command -- prints usage information
/// - Attention: There are some examples of the commands in the source code
/// comments
class HelpCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet{
        print("""
\thelp                              - this text
\tload <filename> ...               - load file into the collection
\tlist <term> ...                   - list all the files that have the term specified
\tlist                              - list all the files in the collection
\tadd <number> <key> <value> ...    - add some metadata to a specific file
\tset <number> <key> <value> ...    - this is really a del followed by an add
\tdel <number> <key> ...            - removes a metadata item from a file
\tsearch <key or value>              - returns files that contain key or value
\tdel <key> <value>                 - removes all occurences of metadata from collection
\tsave-search <filename>            - saves the last list results to a file
\tsave <filename>                   - saves the whole collection to a file
\tquit                              - quit the program
""")
        return MMResultSet()
    }
}

/** Handle the 'quit' command. Gives user option to quit or to continue.
 - Parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws:  'MMCliError.nocommand'
            if user didn't respond to question double checing to quit.
            'MMCliError.unknownCommand'
            if user responded with invalid answer.
 
 - Returns: Quits the commandhandle.
 */
class QuitCommandHandler : MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        outer:
            /// line of prompt for users.
        while let line = prompt("Are you sure you want to quit?\n Press \"Y\" to quit. \n Press \"N\" to continue \n > "){
            var command: String = ""
            var parts = line.split(separator: " ").map({String($0)})
            do{
                guard parts.count > 0 else {
                    throw MMCliError.noCommand
                }
                command = parts.removeFirst().lowercased()
                switch(command){
                case "y","yes":
                    exit(0)
                case "n", "no":
                    break outer
                default:
                    throw MMCliError.unknownCommand
                }
            }
        }
        return MMResultSet()
    }
}

/**
 Shows error message for commands that are not implemented
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.unimplementedCommand'
            if command input by user is not implemented.
 */
class UnimplementedCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        throw MMCliError.unimplementedCommand
    }
}

/**
 This returns of list of all MMfiles that have currently been loaded into the libary.
 Passed a term it will return only the MMfiles that contain those terms. EG Type,
 MetaData ect. (Can list multiple)
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws:  'MMCliError.emptyError'
            if library or list is empty
 
 - Returns: The list of files that have been loaded
 */
class ListCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        var multiSearch = [MMFile]()
        if params.count == 0{
            if library.all().isEmpty{
                throw MMCliError.emptyError
            }else{
                multiSearch = library.all()
            }
        }else{
            for items in params{
                multiSearch.append(contentsOf: library.search(term: items))
            }
        }
        /// Result of the command line list according to appended search ifc multiple.
        let returnedList = MMResultSet(multiSearch)
        if multiSearch.count == 0{
            throw MMCliError.emptyError
        }
        return returnedList
    }
}

/**
 Add some metadata to specific file. (can add multiple)
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidParameters'
            if user puts wrong parameter to command line.
            'MMCliError.outOfBoundsError'
            if user puts index that is out of bound to command line.
 
 - Returns: parameter user asked will be added to the list. Can be checked by calling
            command <list>.
 */
class AddCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        if params.count < 2 || params.count % 3 != 0{
            throw MMCliError.invalidParameters
        }else{
            if params.count % 3 == 0{
                /// number of parameters
                let count = params.count
                var i = 0
                while i < count{
                    guard let index = Int(params[i]) else{
                        throw MMCliError.invalidLoadInput
                    }
                    /// Instance of metadata from params
                    let meta = MetaData(keyword: params[i+1], value: params[i+2])
                    if index > library.listOfFiles.count-1{
                        throw MMCliError.outOfBoundsError
                    }
                    library.add(metadata: meta, file: library.listOfFiles[(index)])
                i = i + 3
                }
            }
        }
        return MMResultSet()
        
        }
    }

/**
 Searches through the loaded file that matches with user's parameter given.
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.notFoundError'
            if user's input cannot be found.
 
 - Returns: Show the metadata that matches with user's command.
 */
class SearchCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        var returnSearch = [MMFile]()
        if params.isEmpty{
            throw MMCliError.invalidParameters
        }else{
            for elements in params{
                returnSearch.append(contentsOf: library.search(term: elements))
            }
        }
        /// Result that is going to be returned
        let returnedResults = MMResultSet(returnSearch)
        if returnSearch.count == 0{
            throw MMCliError.notFoundError
        }
        return returnedResults
    }
}

/**
 Reads the file and import for later use. (can load multiple)
 
 - Parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidLoadInput'
            if user tried to load file that does not exist.
 
 - Returns: Files besing successfully loaded
 
 */
class LoadCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        var loadFiles = [MMFile]()
        for items in params{
            do {
            loadFiles = try FileImport().read(filename: items)
            } catch {
                throw MMCliError.invalidLoadInput
            }
            for files in loadFiles{
                library.add(file: files)
            }
        }
        return MMResultSet()
    }
}

/**
 Saves the file according to the name given by user.
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidParameters'
            if user gives filename that is outside the parameters.
 
 - Returns: Files being successfully saved.
 */
class SaveCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        if params.count <= 1 || params.count > 2{
            throw MMCliError.invalidParameters
        }
        try FileExport().write(filename: params[0], items:library.listOfFiles)
        
    
        
        return MMResultSet()
    }
}

/**
 Delete according to user input and add on the end of the file.
 
 - parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidParameters'
            if user trys to delete things that does not exist or outside the parameter.
 
 - Returns: successfully removed and added to metadata according to user's command.
 */
class SetCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        print(params.count)
        if params.count % 5 == 0{
            guard let i = Int(params[0]) else{
                throw MMCliError.invalidParameters
            }
            ///Delete location
            let metaDel = MetaData(keyword: params[1], value: params[2])
            ///Add location
            let metaAdd = MetaData(keyword: params[3], value: params[4])
            library.remove(metadata: metaDel, index: i)
            library.add(metadata: metaAdd, file: library.listOfFiles[i])
        }else{
            throw MMCliError.invalidParameters
        }
        return MMResultSet()
    }
}

/**
 Removes the metadata item from a file.
 
 - Parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidParameters'
            if user tries to delete metadata that is outside the parameter.
 
 - Returns: successfully deleted list of metadata according to user's command.
 */
class DeleteCommandHandler: MMCommandHandler {
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        if params.count % 2 == 0{
            /// Instance of metadata from params for remove
            let meta = MetaData(keyword: params[0], value: params[1])
            library.remove(metadata: meta)
        }
        if params.count % 3 == 0{
            guard let i = Int(params[0]) else {
                throw MMCliError.invalidParameters
            }
            /// Instance of metadata from params for add
            let meta = MetaData(keyword: params[1], value: params[2])
            library.remove(metadata: meta, index: i)
        }
        if params.count > 3 || params.count < 2{
            throw MMCliError.invalidParameters
        }
        return MMResultSet()
    }
}

/**
 Saves the result of last search into a file.
 
 - Parameters:
 - _params: Array of string that is being passed.
 - last: Represents set of results.
 
 - Throws: 'MMCliError.invalidParameters'
            if user tries command that is outside the parameter.
            'MMCliError.notFoundError'
            if user's input cannot be found.
 
 - Returns: successfully saved last search result to a file
 **/
class SaveSearchCommandHandler: MMCommandHandler{
    static func handle(_ params: [String], last: MMResultSet) throws -> MMResultSet {
        if params.count < 2 {
            throw MMCliError.invalidParameters
        }
            var returnSearch = [MMFile]()
            if params.isEmpty{
                throw MMCliError.invalidParameters
            }else{
                for elements in params{
                    returnSearch.append(contentsOf: library.search(term: elements))
                }
            }
        if returnSearch.count == 0{
            throw MMCliError.notFoundError
        }
            try FileExport().write(filename: params[0], items: returnSearch)
            return MMResultSet()
        }
    }


