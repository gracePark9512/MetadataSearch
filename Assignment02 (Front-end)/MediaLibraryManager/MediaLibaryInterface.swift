//
//  MediaLibaryInterface.swift
//  MMFWindow
//
//  Created by Tiare Horwood on 9/23/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class Interface: MMInterface {
    public init(){
    }
    func command(commandString: String, line: String){
        let parts = line.split(separator: " ").map({String($0)})
        var command: MMCommand
        
        do {
            guard parts.count > 0 else {
                throw MMCliError.noCommand
            }
 
            switch commandString {
            case "load":
                command = LoadCommand(collection: library, paths: parts)
            case "list":
                command = ListCommand(collection: library, terms: parts)
            case "add":
                command = AddMetadataCommand(collection: library, items: last.result(), params: parts)
            case "set":
                command = SetMetadataCommand(collection: library, items: last.result(), params: parts)
            case "del":
                command = DelMetadataCommand(collection: library, items: last.result(), params: parts)
            case "save-search":
                command = SaveCommand(collection: library, filename: parts, items: last.result())
            case "save":
                command = SaveCommand(collection: library, filename: parts, items: nil)
            case "help":
                command = HelpCommand()
            case "quit":
                command = QuitCommand()
            default:
                throw MMCliError.unknownCommand
            }
            // try execute the command and catch any thrown errors below
            try command.execute()
            
            // if there are any results from the command, print them out here
            if let results = command.results {
                results.show()
                last = results
            }
        } catch MMCliError.noCommand {
            print("No command given -- see \"help\" for details.")
        } catch MMCliError.unknownCommand {
            print("Command \"\(commandString)\" not found -- see \"help\" for details.")
        } catch MMCliError.invalidParameters {
            print("Invalid parameters for \"\(commandString)\" -- see \"help\" for details.")
        } catch MMCliError.unimplementedCommand {
            print("The \"\(commandString)\" command is not implemented.")
        } catch MMCliError.missingResultSet {
            print("No previous results to work from.")
        } catch {
            print("Something outside of the errors went wrong")
        }
    }
}
