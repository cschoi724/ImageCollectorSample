//
//  CoreDataManagerTests.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import XCTest
import CoreData
@testable import ImageCollector

final class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer(name: "ImageCollector")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        let expectation = XCTestExpectation(description: "Core Data 스택 로드 완료")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Core Data 스택 로드 실패: \(error?.localizedDescription ?? "")")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0) // 비동기 완료 대기

        coreDataManager = CoreDataManager.shared
        coreDataManager.setupForTesting(container: container)
        testContext = coreDataManager.context
    }

    override func tearDown() {
        coreDataManager = nil
        testContext = nil
        super.tearDown()
    }

    // Core Data가 정상적으로 로드되는지 테스트
    func test_CoreDataStack_Initialization() {
        XCTAssertNotNil(coreDataManager.persistentContainer)
        XCTAssertNotNil(coreDataManager.context)
    }

    // 엔티티를 정상적으로 저장할 수 있는지 테스트
    func test_Save_ImageEntity() {
        guard let image = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: testContext) as? ImageEntity else {
            XCTFail("ImageEntity를 생성할 수 없습니다.")
            return
        }
        image.id = "test_id"
        image.url = "https://example.com/image.jpg"
        image.width = 500
        image.height = 300

        coreDataManager.saveContext()

        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "test_id")

        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "저장된 데이터가 없습니다.")
            XCTAssertEqual(results.first?.url, "https://example.com/image.jpg", "저장된 URL이 올바르지 않습니다.")
        } catch {
            XCTFail("데이터를 불러오지 못했습니다: \(error.localizedDescription)")
        }
    }

    // 데이터를 불러올 수 있는지 테스트
    func test_Fetch_ImageEntity() {
        guard let image = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: testContext) as? ImageEntity else {
            XCTFail("ImageEntity를 생성할 수 없습니다.")
            return
        }
        image.id = "fetch_test_id"
        image.url = "https://example.com/fetch.jpg"
        image.width = 800
        image.height = 600

        coreDataManager.saveContext()

        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "fetch_test_id")

        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertFalse(results.isEmpty, "데이터가 조회되지 않습니다.")
            XCTAssertEqual(results.first?.url, "https://example.com/fetch.jpg", "조회된 데이터의 URL이 다릅니다.")
        } catch {
            XCTFail("데이터를 불러오는 데 실패했습니다: \(error.localizedDescription)")
        }
    }

    // 데이터를 삭제할 수 있는지 테스트
    func test_Delete_ImageEntity() {
        guard let image = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: testContext) as? ImageEntity else {
            XCTFail("ImageEntity를 생성할 수 없습니다.")
            return
        }
        image.id = "delete_test_id"
        image.url = "https://example.com/delete.jpg"
        image.width = 400
        image.height = 400

        coreDataManager.saveContext()

        testContext.delete(image)
        coreDataManager.saveContext()

        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "delete_test_id")

        do {
            let results = try testContext.fetch(fetchRequest)
            XCTAssertTrue(results.isEmpty, "데이터가 삭제되지 않았습니다.")
        } catch {
            XCTFail("데이터 삭제 후 조회 실패: \(error.localizedDescription)")
        }
    }
}
