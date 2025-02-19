//
//  CoreDataManager.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import CoreData

final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    
    var persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {
        persistentContainer = NSPersistentContainer(name: "ImageCollector")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data 로드 실패: \(error.localizedDescription)")
            }
        }
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data 저장 실패: \(error.localizedDescription)")
            }
        }
    }
}
