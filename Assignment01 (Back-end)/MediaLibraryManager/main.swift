//
//  main.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 18/06/18.
//  Copyright © 2018 Paul Crane. All rights reserved.

import Foundation

// TODO create your instance of your library here

var library = Collection()
var last = MMResultSet()

// The while-loop below implements a basic command line interface. Some
// examples of the (intended) commands are as follows:
//
// load foo.json bar.json
//  from the current directory load both foo.json and bar.json and
//  merge the results
//
// list foo bar baz
//  results in a set of files with metadata containing foo OR bar OR baz
//
// add 3 foo bar
//  using the results of the previous list, add foo=bar to the file
//  at index 3 in the list
//
// add 3 foo bar baz qux
//  using the results of the previous list, add foo=bar and baz=qux
//  to the file at index 3 in the list
//
// Feel free to extend these commands/errors as you need to.
while let line = prompt("> "){
    var command : String = ""
    var parts = line.split(separator: " ").map({String($0)})
    do{
        guard parts.count > 0 else {
            throw MMCliError.noCommand
        }
        command = parts.removeFirst().lowercased();
        switch(command){
            /// saves the last list results to a file
        case "save-search":
            last = try SaveSearchCommandHandler.handle(parts, last:last)
            break
            /// removes a metadata items from a file
        case "del":
            last = try DeleteCommandHandler.handle(parts, last:last)
            break
            /// delete followed by add
        case "set":
            last = try SetCommandHandler.handle(parts, last:last)
            break
            /// saves the whole collection to a file
        case "save":
            last = try SaveCommandHandler.handle(parts, last:last)
            break
            /// add some metadata to a specific file
        case "add":
            last = try AddCommandHandler.handle(parts, last:last)
            break
            /// ist all the files that have the term specified
        case "list":
            last = try ListCommandHandler.handle(parts, last:last)
            break
            /// shows available command for users
        case "help":
            last = try HelpCommandHandler.handle(parts, last:last)
            break
            /// returns files that contain key or value
        case "search":
            last = try SearchCommandHandler.handle(parts, last:last)
            break
            /// quit the program
        case "quit":
            last = try QuitCommandHandler.handle(parts, last:last)
            /// load file into the collection
        case "load":
            last = try LoadCommandHandler.handle(parts, last:last)
            continue
        default:
            throw MMCliError.unknownCommand
        }
        last.showResults();
        
    }catch MMCliError.noCommand {
        print("No command given -- see \"help\" for details.")
        
    }catch MMCliError.unknownCommand {
        print("Command \"\(command)\" not found -- see \"help\" for details.")
        
    }catch MMCliError.invalidParameters {
        print("Invalid parameters for \"\(command)\" -- see \"help\" for details.")
        
    }catch MMCliError.unimplementedCommand {
        print("The \"\(command)\" command is not implemented.")
        
    }catch MMCliError.missingResultSet {
        print("No previous results to work from.")
        
    }catch MMCliError.couldNotDecode {
        print("Could not decode \"\(parts)\". Please check the file and try again")
        
    }catch MMCliError.couldNotConvert {
        print("Could not convert \"\(parts)\" to utf8 format")
        
    }catch MMCliError.invalidLoadInput {
        print("Could not load in \"\(parts)\". Make sure to input files like this: \"/home/cshome/.../MMfile.json\"")
        
    }catch MMCliError.outOfBoundsError {
        print("Index is out of bounds. Current Index max is: \(library.listOfFiles.count-1)")
        
    }catch MMCliError.notFoundError {
        print("Could not find \"\(parts)\". Please check the file and try again")
        
    }catch MMCliError.emptyError{
        print ("\"\(parts)\" empty. Please check the file and try again")
    }
}
