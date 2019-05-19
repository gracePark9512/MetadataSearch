//
//  metaGeneral.swift
//  MediaLibraryManager
//
//  Created by Hyunsun Park on 8/27/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// Representation of metadata from the file.
class MetaData: MMMetadata {
    var description: String
    var keyword: String
    var value: String

    /**
     Initialises metadata with provided specifications.
     
     - Parameters:
     - keyword : keyword that describes the metadata
     - value: value of the keyword
 */
    init(keyword: String, value: String) {
        self.description = " \n \(keyword) : \(value) "
        self.keyword = keyword
        self.value = value
    }
}

