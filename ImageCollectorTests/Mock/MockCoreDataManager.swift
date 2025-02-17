//
//  MockCoreDataManager.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import CoreData
import XCTest

@testable import ImageCollector

final class MockCoreDataManager: CoreDataManagerProtocol {
    var persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    init() {
        let modelURL = Bundle.main.url(forResource: "ImageCollector", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)

        persistentContainer = NSPersistentContainer(name: "ImageCollector", managedObjectModel: managedObjectModel!)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        let expectation = XCTestExpectation(description: "In-Memory Core Data 로드 완료")
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Core Data 스택 로드 실패: \(error?.localizedDescription ?? "")")
            expectation.fulfill()
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
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
