//
//  FileStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import Foundation

class FileStorage{
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
    
    func storeTemporary(_ data: Data, type: String? = nil) throws -> String{
        try store(data, type: type, to: temporaryDirectory)
    }
    
    func pickTemporary(_ name: String) throws -> Data{
        return try pick(name, from: temporaryDirectory)
    }
    
    func storePersistent(_ data: Data, type: String? = nil) throws -> String{
        try store(data, type: type, to: persistentDirectory)
    }
    
    func pickPersistent(_ name: String) throws -> Data{
        return try pick(name, from: persistentDirectory)
    }
    
    func getTemporaryPath(name: String) -> String{
        let url = temporaryDirectory.appendingPathComponent(name)
        return url.path
    }
    
    func getPersistentPath(name: String) -> String{
        let url = persistentDirectory.appendingPathComponent(name)
        return url.path
    }
    
    private func store(_ data: Data, type: String?, to directory: URL) throws -> String{
        let digest = StringUtil.md5(data: data)
        let filename: String
        if let type = type{
            filename = "\(digest).\(type)"
        }else{
            filename = digest
        }
        let url = directory.appendingPathComponent(filename)
        if !FileManager.default.fileExists(atPath: url.path){
            try data.write(to: url)
        }
        return filename
    }
    
    private func pick(_ name: String, from directory: URL) throws -> Data{
        let url = directory.appendingPathComponent(name)
        return try Data(contentsOf: url)
    }
}
