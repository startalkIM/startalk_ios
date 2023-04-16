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
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: Self.STORAGE_NAME)
        container.loadPersistentStores(completionHandler: { [self] (storeDescription, error) in
            if let error = error {
                loggger.error("could not initialize NSPersistentContainer")
                fatalError("Unresolved error \(error)")
            }
        })
        
        return container
    }()
    
    lazy var context = persistentContainer.viewContext

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
