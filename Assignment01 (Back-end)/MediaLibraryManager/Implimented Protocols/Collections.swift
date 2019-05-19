//
//  Collections.swift
//  MediaLibraryManager
//
//  Created by Tiare Horwood on 8/28/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// Representation of a collection of MMFile
class Collection: MMCollection{
    var description: String
    var listOfFiles = [MMFile]()
    
    /**
     Empty initialiser for description
     */
    init() {
        description = ""
    }
    
    /** Adds a passed MMFile to the collection.
     
     - Parameter file: A single instance of MMFile
     */
    func add(file: MMFile) {
        listOfFiles.append(file)
    }
    
    /** This adds a single instance of metadata to a passed MMfile.
     
     - Parameters:
     - metadata: The metadata that is going to be appended
     - file: The file that is going to have the metadata appeneded to it
     */
    func add(metadata: MMMetadata, file: MMFile) {
         for i in 0...library.listOfFiles.count-1{
            if library.listOfFiles[i].description == file.description{
                library.listOfFiles[i].metadata.append(metadata)
            }
        }
    }
    
    /** Removes all occurence of a passed metadata from the collection of MMFiles.
     
     - Parameter metadata: The metadata that is going to be removed from the collection
     */
    func remove(metadata: MMMetadata) {
        for var file in library.listOfFiles{
            for index in 0...file.metadata.count-1{
                var value = file.metadata[index].value
                var keyword = file.metadata[index].keyword
                value = value.lowercased()
                keyword = keyword.lowercased()
                if metadata.value.lowercased() == value && metadata.keyword.lowercased() == keyword {
                    file.metadata.remove(at: index)
                    break
                }
            }
        }
    }
    
    /** Removes occurence of a passed metadata from a specified file.
     
     - Parameters:
     - metadata: The metadata that is going to be removed from a given file.
     - index: The index in the collection array that points to a specific file.
     */
    func remove(metadata: MMMetadata, index: Int) {
        var fileMetadata = library.listOfFiles[index].metadata
        for i in 0...fileMetadata.count-1{
            var value = fileMetadata[i].value
            var keyword = fileMetadata[i].keyword
            value = value.lowercased()
            keyword = keyword.lowercased()
            if metadata.value.lowercased() == value && metadata.keyword.lowercased() == keyword{
                library.listOfFiles[index].metadata.remove(at: i)
                break
            }
        }
    }

    /** When passed a string, searches the contents of FilePath, FileName, Type and MetaData. Returning an array of MMFile of matching MMFiles.
     
     - Parameter term: The term that is being searched for in the collection.
     
     - Returns: An array of MMFiles that contains the contains the searched results.
     */
    func search(term: String) -> [MMFile] {
        /// Map of the MMFile array
        let searchFiles = library.listOfFiles.map({$0})
        var searchConditions = searchFiles.filter{$0.metadata.contains(where: { (searchMetaData) -> Bool in
            searchMetaData.keyword.lowercased() == term.lowercased() || searchMetaData.value.lowercased() == term.lowercased()
        })}
        for file in listOfFiles{
            if file.type.lowercased() == term || file.filename.lowercased() == term || file.path.lowercased() == term{
                searchConditions.append(file)
            }
        }
        return searchConditions
    }

    /** Passed an key value pair to search the contents of just Metadata.
     
     - Parameter item: The key value pair that is used to search the collection of MMFile metadata.
     
     - Returns: An array of MMfile that contains the key value pair.
     */
    func search(item: MMMetadata) -> [MMFile] {
        /// Map of MMFile array
        let searchFiles = library.listOfFiles.map({$0})
        /// Conditional filter of MMFile array
        let searchConditions = searchFiles.filter{$0.metadata.contains(where: { (searchMetaData) -> Bool in
                searchMetaData.description.lowercased() == item.description.lowercased()
            })}
        
        return searchConditions
    }
    /** Returns all files in the Collection.
     
     - Returns: An array of all MMFile in the Collection.
     */
    func all() -> [MMFile] {
        return listOfFiles
    }
    
}

