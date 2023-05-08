//
//  FileLoader.swift
//  Startalk
//
//  Created by lei on 2023/3/11.
//

import Foundation

class FileLoader{
    let logger = STLogger(FileLoader.self)
    
    lazy var urlSession = URLSession.shared
    lazy var loader = ResourceLoader.shared
    lazy var storage = STKit.shared.filesManager.storage
    
    func load(url: String, object: AnyObject, cimpletion: @escaping (Data?) -> Void){
        loader.load(url, object: object) { [self] url, completion in
            Task{
                let url = URL(string: url)
                guard let url = url else{
                    completion(.failed)
                    return
                }
                do{
                    let (data, _) = try await urlSession.data(from: url)
                    let identifier = try storage.storeTemporary(data)
                    completion(.success(identifier))
                }catch{
                    logger.warn("load file failed", error)
                    completion(.failed)
                }
                
            }
        } process: { [self] identifier in
            var data: Data?
            if let identifier = identifier{
                do{
                    data = try storage.pickTemporary(identifier)
                }catch{
                    logger.warn("read file failed", error)
                }
            }
            cimpletion(data)
        }

    }
}

 
