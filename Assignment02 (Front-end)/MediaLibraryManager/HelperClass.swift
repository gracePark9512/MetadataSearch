//
//  HelperClass.swift
//  FileUI
//
//  Created by Tiare Horwood on 10/1/18.
//  Copyright © 2018 Hyunsun Park. All rights reserved.
//

import Foundation

class Helper: MMHelperClass {
    public init(){
    }
    
    /** Checks the type of the file based on the key metaData that each file types needs. It then returns the found type as a string to be used throughout our application.
     - Parameters file: the MMFile that is wanted to be checked what type of media file it is.
     - Returns: the string representation for that MMFile.
     */
    func checkType(file:MMFile) -> String{
        
        /// Type constants
        let Image = "image"
        let Video = "video"
        let Audio = "audio"
        let Document = "document"
        
        /// Key Keyword Constant
        let Resolution = "resolution"
        let Creator = "creator"
        let Runtime = "runtime"
        
        /// The type of the file in lower case
        var type: String = ""
        
        if file.metadata.contains(where: { (fileMeta) -> Bool in
            fileMeta.keyword.lowercased() == Resolution
        }) && file.metadata.contains(where: { (fileMeta) -> Bool in
            fileMeta.keyword.lowercased() == Creator
        }) && file.metadata.contains(where: { (fileMeta) -> Bool in
            fileMeta.keyword.lowercased() == Runtime
        }){
            type = Video
        }else if file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Resolution
            }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                fileMeta.keyword.lowercased() == Creator
            }){
                type = Image
            } else if  file.metadata.contains(where: { (fileMeta) -> Bool in
                    fileMeta.keyword.lowercased() == Runtime
                }) && file.metadata.contains(where: { (fileMeta) -> Bool in
                    fileMeta.keyword.lowercased() == Creator
                }){
                    type = Audio
                } else if file.metadata.contains(where: { (fileMeta) -> Bool in
                        fileMeta.keyword.lowercased() == Creator
                    }){
                        type = Document
        }
        return type
    }
    
}

