//
//  STDatabaseManager.swift
//  Startalk
//
//  Created by lei on 2023/4/14.
//

import CoreData

class STDatabaseManager{
    static let STORAGE_NAME = "Startalk"
    let loggger = STLogger(STDatabaseManager.self)
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: Self.STORAGE_NAME)
        container.loadPersistentStores(completionHandler: { [self] (storeDescription, error) in
            if let error = error {
                loggger.error("could not initialize NSPersistentContainer")
                fatalError("Unresolved error \(error)")
            }
        })
        
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy.overwrite
        return container
    }()
    
    lazy var context = container.viewContext

    func fetch<T>(_ request: NSFetchRequest<T>) -> [T] where T : NSFetchRequestResult{
        do{
            return try context.fetch(request)
        }catch{
            let message = "could not fetch data"
            loggger.error(message, error)
            fatalError(message)
        }
    }
    
    func count<T>(for request: NSFetchRequest<T>) -> Int where T : NSFetchRequestResult{
        do{
            return try context.count(for: request)
        }catch{
            let message = "could not count data"
            loggger.error(message, error)
            fatalError(message)
        }
    }
    
    func save () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                loggger.error("could not save changes", error)
            }
        }
    }
}
