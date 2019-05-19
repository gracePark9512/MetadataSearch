//
//  File.swift
//  MediaLibraryManager
//
//  Created by Tiare Horwood on 8/28/18.
//  Copyright © 2018 Paul Crane. All rights reserved.


import Foundation

/// File class that prints out the read data.
class File: MMFile{
    var metadata: [MMMetadata]
    var type: String
    var filename: String
    var path: String
    /**
     Description of the file.
     
     - Returns: formatted representation of the file.
 */
    var description: String{
        get{
            return "Filename: \(filename)\n Path: \(path) \n Type: \(type) \n <Metadata> \(metadata) \n"
        }
    }
    
    /**
     Initialises a data with the provided specifications.
     
     - Parameters:
     - metadata: metadata of the read file.
     - type: type of the read file.
     - filename: filename of the read file.
     - path: path of the read file.
 */
    init( metadata: [MMMetadata], filename: String, type: String, path: String) {
        self.metadata = metadata
        self.type = type
        self.filename = filename
        self.path = path
    }
}
