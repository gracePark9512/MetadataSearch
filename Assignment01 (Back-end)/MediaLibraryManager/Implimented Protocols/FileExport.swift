//
//  FileExport.swift
//  MediaLibraryManager
//
//  Created by Tiare Horwood on 8/28/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//


import Foundation

/// A global container for all goodByeFiles
struct goodByeFiles: Codable{
    var fileName: String
    var fullPath: String
    var type: String
    var metaData: [String: String]
}

/// Exports the data into file outside.
class FileExport: MMFileExport{
    
    /**
     Write the file outside.
     
     - Parameters:
     - filename: name of the file
     - items: elements inside the MMFile
     
     - Returns: files successfully exported
 */
   func write(filename: String, items: [MMFile]) throws {
    
    /// Instance of JSONEnconder
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
    /// URL path to my Documents Folder
        let nameOfFile = getDocumentDirectory().appendingPathComponent(filename)
        var jstr = [String]()
        var count = 1
        for file in items{
            /// type of the file provided
            let fileType = file.type
            /// path of the file provided
            let filePath = file.path
            var MMFileMetaData = [String:String]()

            for meta in file.metadata{
                MMFileMetaData[meta.keyword] = meta.value
            }

            /// instance of files that is being exported
            let byeByeFiles = goodByeFiles(fileName: filename,fullPath: filePath, type: fileType, metaData: MMFileMetaData)
            /// files that has been encoded
            let jsonData = try jsonEncoder.encode(byeByeFiles)
            /// Encoding json String
            let jsonString = String(data: jsonData, encoding: .utf8)
            if count == items.count{
                jstr.append(jsonString!)
                break
            }
            jstr.append("\(jsonString!),")
            count += 1
        }
    /// output of the file that has been appended
        let output = jstr.joined()
    try "[\(output)]".write(to: nameOfFile, atomically: true, encoding: .utf8)
    }
}

/**
 place exported file into document directory.
 
 - Returns: URL for current computers my Document Directory
 
 */
    private func getDocumentDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask)
        return paths[0]
    }
