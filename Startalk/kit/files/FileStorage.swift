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
        do{
            temporaryDirectory = try Self.makePath(directory: Self.TEMPORARY_DIRECTORY)
            persistentDirectory = try Self.makePath(directory: Self.PERSISTENT_DIRECTORY)
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
    
    private static func makePath(directory: String) throws -> URL{
        let fileManager = FileManager.default
        let userDirectory = try fileManager.url(for: .userDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = userDirectory.appendingPathComponent(directory)
        if !fileManager.fileExists(atPath: directory.path){
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: false)
        }
        return directory
    }
}
