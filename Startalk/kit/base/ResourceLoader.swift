//
//  ResourceLoader.swift
//  Startalk
//
//  Created by lei on 2023/5/6.
//

import Foundation
class ResourceLoader{
    static let shared = ResourceLoader()
    let logger = STLogger(ResourceLoader.self)
    
    lazy var connection = STKit.shared.databaseManager2.getShareConnection()
    
    let queue = DispatchQueue(label: "resource_loading")
    var handlesHolder: [String: [Handle]] = [: ]
    
    func load(_ url: String, object: AnyObject, load: @escaping (String, @escaping (Result) -> Void) -> Void, process: @escaping (String?) -> Void){
        let url = URLUtil.normalize(url)
        queue.async{ [self] in
            do{
                let loading = try pickLoading(url)
                if var loading = loading{
                    if loading.timeout{
                        loading.status = .failed
                    }
                    switch loading.status{
                    case .loading:
                       addHandle(url: url, object: object, process: process)
                    case .loaded:
                        let identifier = loading.identifier
                        process(identifier)
                    case .failed:
                        try updateLoading(id: loading.id, status: .loading, identifier: nil)
                        addHandle(url: url, object: object, process: process)
                        doLoad(loadingId: loading.id, url: url, load: load, process: process)
                    }
                }else{
                    let loadingId = try addLoading(url: url)
                    addHandle(url: url, object: object, process: process)
                    doLoad(loadingId: loadingId, url: url, load: load, process: process)
                }
            }catch{
                logger.warn("load failed", error)
            }
        }
        
        
    }
    
    private func addHandle(url: String, object: AnyObject, process: @escaping (String?) -> Void){
        let handles = handlesHolder[url]
        if var handles = handles{
            let index = handles.firstIndex { $0.object === object }
            if let index = index{
                handles[index].process = process
            }else{
                let handle = Handle(object: object, process: process)
                handles.append(handle)
            }
            handlesHolder[url] = handles
        }else{
            let handle = Handle(object: object, process: process)
            handlesHolder[url] = [handle]
        }
    }
    
    private func doLoad(loadingId: Int, url: String, load: @escaping (String, @escaping (Result) -> Void) -> Void, process: @escaping (String?) -> Void){
        
        load(url){ [self] result in
            queue.async { [self] in
                do{
                    switch result{
                    case .success(let identifier):
                        try updateLoading(id: loadingId, status: .loaded, identifier: identifier)
                        let handles = handlesHolder[url]
                        if let handles = handles{
                            for handle in handles{
                                handle.process(identifier)
                            }
                        }
                    case .failed:
                       try updateLoading(id: loadingId, status: .failed, identifier: nil)

                    }
                    handlesHolder.removeValue(forKey: url)
                }
                catch{
                    logger.warn("do load failed", error)
                }
            }
        }
    }
    

    private func pickLoading(_ url: String) throws -> Loading?{
        let sql  = "select * from resource_loading where url = ?"
        let resultSet = try connection.query(sql: sql, values: url)
        if resultSet.next(){
            let id = try resultSet.getInt32("id")
            let url = try resultSet.getString("url")!
            let statusValue = try resultSet.getInt32("status")
            let identifier = try resultSet.getString("identifier")
            let updateTimeValue = try resultSet.getInt64("update_time")
            
            let status = Status(rawValue: Int(statusValue))!
            let updateTime = Date(milliseconds: updateTimeValue)
           
            return Loading(id: Int(id), url: url, status: status, identifier: identifier, updateTime: updateTime)
        }else{
            return nil
        }
    }
    
    private func addLoading(url: String) throws -> Int{
        let sql = "insert into resource_loading(url, status, update_time) values(?, ?, ?)"
        
        let statusValue = Int32(Status.loading.rawValue)
        let updateTimeValue = Date().milliseconds
        let id = try connection.insert(sql: sql, values: url, statusValue, updateTimeValue)
        return Int(id)
    }
    
    private func updateLoading(id: Int, status: Status, identifier: String?) throws{
        let sql = "update resource_loading set status = ?, identifier = ?, update_time = ? where id = ?"

        let id = Int32(id)
        let statusValue = Int32(status.rawValue)
        let updateTimeValue = Date().milliseconds
        try connection.update(sql: sql, values: statusValue, identifier, updateTimeValue, id)
    }
    
    
    
    enum Status: Int{
        case loading
        case loaded
        case failed
    }
    
    struct Loading{
        static let TIMEOUT: TimeInterval = 30

        var id: Int
        var url: String
        var status: Status
        var identifier: String?
        var updateTime: Date
        
        var timeout: Bool{
            status == .loading && abs(updateTime.timeIntervalSinceNow) > Self.TIMEOUT
        }
    }
    
    enum Result{
        case success(String?)
        case failed
    }
    
    struct Handle{
        var object: AnyObject
        var process: (String?) -> ()
    }
}
