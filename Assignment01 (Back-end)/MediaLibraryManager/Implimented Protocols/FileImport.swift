//
//  FileImport.swift
//  MediaLibraryManager
//
//  Created by Tiare Horwood on 8/28/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

///A global container for all multiMedia 
struct multiMedia: Codable{
    var fullPath: String
    var type: String
    var metaData: [String: String]
}

/// Import the JSON file.
class FileImport: MMFileImport{
    
    /**
     Goes through JSON file according to there type and check validity (have required field).
     
     - Parameter files: File that is being read.
     
     - Returns: Only valid files.
 */
    private func checkType(files:[MMFile]) -> [MMFile]{
        var approvedFiles = [MMFile]()
        
        /// Type constants
        let Image = "image"
        let Video = "video"
        let Audio = "audio"
        let Document = "document"
        
        /// Key Keyword Constant
        let Resolution = "resolution"
        let Creator = "creator"
        let Runtime = "runtime"
        
        for file in files{
            /// The type of the file in lower case
            let type = file.type.lowercased()
            
            /// Checks valid Image files
            if type == Image && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Resolution
            }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Creator
            }){
                approvedFiles.append(file)
            }
            
            /// Checks valid Video files
            if type == Video && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Resolution
            }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Creator
            }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Runtime
            }){
                approvedFiles.append(file)
            }
            
            /// Checks valid Audio files
            if type == Audio && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Runtime
            }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Creator
            }){
                approvedFiles.append(file)
            }
            
            /// Checks valid Document files
            if type == Document && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Creator
            }){
                approvedFiles.append(file)
            }
        }
        print("\(approvedFiles.count)/\(files.count) files have been sucsessfully loaded")
        return approvedFiles    
    }
    
    /**
     Reads the file that is located in provided URL.
     
     - Parameter filename: The name of the file
     
     - Throws: 'MMCliError.couldNotDecode'
                if file given is not decodable
                'MMCliError.couldNotConvert'
                if file given is not convertable
     
     - Returns: files that has been through checking.
 */
    func read(filename: String) throws -> [MMFile] {
        var filesToReturn = [MMFile]()
        
        /// coverted data to bytes
        if let data = try String(contentsOfFile: filename).data(using: .utf8){
            do{
                /// array of struct MultiMedia
                let MultiMedia: [multiMedia] = try JSONDecoder().decode([multiMedia].self, from: data)
                for file in MultiMedia{
                    var metadata = [MetaData]()
                    /// URL of the file
                    let filePath = URL(fileURLWithPath: filename)
                    
                    for elements in file.metaData{
                        /// array of Metadata corresponding to a file
                        let metaDataElement = MetaData(keyword: elements.key, value: elements.value)
                        metadata.append(metaDataElement)
                    }
                    /// new instance created by file
                    let newFile = File(metadata: metadata, filename:filePath.lastPathComponent, type: file.type, path: filePath.description)
                    filesToReturn.append(newFile)
                }
            }
            catch{
                throw MMCliError.couldNotDecode
            }
        } else {
            throw MMCliError.couldNotConvert
        }
        
        return checkType(files: filesToReturn)
    }
}
