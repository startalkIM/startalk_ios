//
//  FileStorage.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import Foundation

class FileStorage{
    static let TEMPORARY_DIRECTORY = "temporary"
    let logger = STLogger(FileStorage.self)
    
    lazy var databaseManager = STKit.shared.databaseManager2
    
    let temporaryDirectory: URL
    
    init(){
        let fileManager = FileManager.default
        do{
            temporaryDirectory = try Self.makeTemporaryPath()
            let temporaryExists = fileManager.fileExists(atPath: temporaryDirectory.path)
            if !temporaryExists{
               try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: false)
            }
        }catch{
            let message = "could not make temporary dirctory"
            logger.error(message, error)
            fatalError(message)
        }
    }
    
    func storeTemporarily(_ data: Data) -> String?{
        let digest = StringUtil.md5(data: data)
        let url = temporaryDirectory.appendingPathComponent(digest)
        if FileManager.default.fileExists(atPath: url.path){
            return digest
        }
        do{
            try data.write(to: url)
            return digest
        }catch{
            logger.warn("write data failed", error)
            return nil
        }
    }
    
    private static func makeTemporaryPath() throws -> URL{
        var userDirectory = try FileManager.default.url(for: .userDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = userDirectory.appendingPathComponent(Self.TEMPORARY_DIRECTORY)
        return directory
    }
}
