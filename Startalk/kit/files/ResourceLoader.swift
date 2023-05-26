//
//  ResourceLoader.swift
//  Startalk
//
//  Created by lei on 2023/5/6.
//

import Foundation

class ResourceLoader{
    private let logger = STLogger(ResourceLoader.self)
    
    lazy var connection = STKit.shared.databaseManager.getShareConnection()
    lazy var urlSession = URLSession.shared
    lazy var storage = STKit.shared.filesManager.storage
    
    let queue = DispatchQueue(label: "resource_loading")
    var handlesHolder: [String: [Handle]] = [: ]
    
    func load(_ url: String, object: AnyObject, complete: @escaping (Data?) -> Void){
        let url = URLUtil.normalize(url)
        queue.async{ [self] in
            do{
                var loading: Loading! = try pickLoading(url)
                let timeout = loading?.timeout ?? false
                if timeout{
                    loading?.status = .failed
                }
                
                switch loading?.status{
                case .none:
                    let loadingId = try addLoading(url: url)
                    addHandle(url: url, object: object, complete: complete)
                    doLoad(loadingId: loadingId, url: url)
                case .loading:
                    addHandle(url: url, object: object, complete: complete)
                case .loaded:
                    let filename = loading.name!
                    let data =  try storage.pickTemporary(filename)
                    complete(data)
                case .failed:
                    try updateLoading(id: loading.id, status: .loading, name: nil)
                    addHandle(url: url, object: object, complete: complete)
                    doLoad(loadingId: loading.id, url: url)
                }
            }catch{
                logger.warn("load failed", error)
            }
        }
    }
    
    private func addHandle(url: String, object: AnyObject, complete: @escaping (Data?) -> Void){
        let keys = handlesHolder.keys
        for key in keys{
            let handles = handlesHolder[key]
            if var handles = handles{
                let index = handles.firstIndex { $0.object === object }
                if let index = index{
                    handles.remove(at: index)
                }
            }
            handlesHolder[key] = handles
        }
        
        var handles = handlesHolder[url] ?? []
        let handle = Handle(object: object, complete: complete)
        handles.append(handle)
        handlesHolder[url] = handles
    }
    
    private func doLoad(loadingId: Int, url source: String){
        Task{
            guard let url = URL(string: source) else{
                try updateLoading(id: loadingId, status: .failed, name: nil)
                complete(url: source, data: nil)
                return
            }
            do{
                let (data, _) = try await urlSession.data(from: url)
                let type = url.pathExtension
                let name = try storage.storeTemporary(data, type: type)
                try updateLoading(id: loadingId, status: .loaded, name: name)
                complete(url: source, data: data)
            }catch{
                logger.warn("load resource failed", error)
                complete(url: source, data: nil)
            }
           
        }
    }
    
    private func complete(url: String, data: Data?){
        let handles = handlesHolder[url]
        if let handles = handles{
            for handle in handles{
                let complete = handle.complete
                complete(data)
            }
        }
        handlesHolder[url] = nil
    }

    private func pickLoading(_ url: String) throws -> Loading?{
        let sql  = "select * from resource_loading where url = ?"
        let resultSet = try connection.query(sql: sql, values: url)
        if resultSet.next(){
            let id = try resultSet.getInt32("id")
            let url = try resultSet.getString("url")!
            let statusValue = try resultSet.getInt32("status")
            let name = try resultSet.getString("name")
            let updateTimeValue = try resultSet.getInt64("update_time")
            
            let status = Status(rawValue: Int(statusValue))!
            let updateTime = Date(milliseconds: updateTimeValue)
           
            return Loading(id: Int(id), url: url, status: status, name: name, updateTime: updateTime)
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
    
    private func updateLoading(id: Int, status: Status, name: String?) throws{
        let sql = "update resource_loading set status = ?, name = ?, update_time = ? where id = ?"

        let id = Int32(id)
        let statusValue = Int32(status.rawValue)
        let updateTimeValue = Date().milliseconds
        try connection.update(sql: sql, values: statusValue, name, updateTimeValue, id)
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
        var name: String?
        var updateTime: Date
        
        var timeout: Bool{
            status == .loading && abs(updateTime.timeIntervalSinceNow) > Self.TIMEOUT
        }
    }
    
    struct Handle{
        var object: AnyObject
        var complete: (Data?) -> ()
    }
}

extension ResourceLoader{
    
    func path(of url: String) -> String?{
        let url = URLUtil.normalize(url)
        do {
            let loading: Loading! = try pickLoading(url)
            if loading.status == .loaded, let filename = loading.name{
                return storage.getTemporaryPath(name: filename)
            }else{
                return nil
            }
        } catch {
            logger.warn("pick loading failed", error)
            return nil
        }
        
    }
}
