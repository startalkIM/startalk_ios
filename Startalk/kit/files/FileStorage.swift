//
//  FileStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import Foundation

class FileStorage{
    static let TEMPORARY_DIRECTORY = "temporary"
    static let PERSISTENT_DIRECTORY = "persistent"
    let logger = STLogger(FileStorage.self)
        
    let temporaryDirectory: URL
    let persistentDirectory: URL
    
    init(){
        let fileManager = FileManager.default
        do{
            temporaryDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            persistentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }catch{
            let message = "could not make temporary dirctory"
            logger.error(message, error)
            fatalError(message)
        }
    }
    
    func storeTemporary(_ data: Data) throws -> String{
        try store(data, to: temporaryDirectory)
    }
    
    func pickTemporary(_ name: String) throws -> Data{
        return try pick(name, from: temporaryDirectory)
    }
    
    func storePersistent(_ data: Data) throws -> String{
        try store(data, to: persistentDirectory)
    }
    
    func pickPersistent(_ name: String) throws -> Data{
        return try pick(name, from: persistentDirectory)
    }
    
    func getPersistentPath(name: String) -> String{
        let url = persistentDirectory.appendingPathComponent(name)
        return url.path
    }
    
    private func store(_ data: Data, to directory: URL) throws -> String{
        let digest = StringUtil.md5(data: data)
        let url = directory.appendingPathComponent(digest)
        if !FileManager.default.fileExists(atPath: url.path){
            try data.write(to: url)
        }
        return digest
    }
    
    private func pick(_ name: String, from directory: URL) throws -> Data{
        let url = directory.appendingPathComponent(name)
        return try Data(contentsOf: url)
    }
}
