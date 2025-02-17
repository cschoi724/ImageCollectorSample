//
//  ImageRepositoryTests.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import XCTest
import Combine
@testable import ImageCollector
import CoreData

final class ImageRepositoryTests: XCTestCase {
    private var repository: ImageRepository!
    private var mockNetworkService: MockNetworkService!
    private var mockCoreDataManager: CoreDataManagerProtocol!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
        mockNetworkService = MockNetworkService()
        repository = ImageRepositoryImpl(
            networkService: mockNetworkService,
            coreDataManager: mockCoreDataManager
        )
    }

    override func tearDown() {
        mockNetworkService = nil
        mockCoreDataManager = nil
        repository = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // API 요청 성공 시 데이터 반환 테스트
    func test_fetchImageList_Success() {
        let mockImages: [ImageDTO] = [
            ImageDTO(id: "1", url: "https://example.com/1.jpg", width: 100, height: 100),
            ImageDTO(id: "2", url: "https://example.com/2.jpg", width: 200, height: 200)
        ]
        mockNetworkService.mockResponse = mockImages

        let expectation = XCTestExpectation(description: "API에서 데이터를 받아오고 Core Data에 저장해야 함.")

        repository.fetchImageList()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("API 요청이 실패함: \(error)")
                }
            }, receiveValue: { images in
                XCTAssertEqual(images.count, mockImages.count, "받아온 이미지 개수가 일치해야 함.")
                XCTAssertEqual(images.first?.id, "1", "첫 번째 이미지 ID가 맞아야 함.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // API 요청 실패 시 Core Data에서 데이터 반환 테스트
    func test_fetchImageList_ApiFails_ReturnsCachedData() {
        mockNetworkService.mockError = .networkError(NSError(domain: "Test Error", code: -1, userInfo: nil))
        let context = mockCoreDataManager.context
        context.performAndWait {
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: context) as? ImageEntity else {
                XCTFail("ImageEntity를 생성할 수 없습니다.")
                return
            }
            entity.id = "cached"
            entity.url = "https://example.com/cached.jpg"
            entity.width = 300
            entity.height = 300
            try? context.save()
        }

        let expectation = XCTestExpectation(description: "API 요청이 실패하면 Core Data에서 데이터를 반환해야 함.")

        repository.fetchImageList()
            .sink(receiveCompletion: { _ in }, receiveValue: { images in
                XCTAssertEqual(images.count, 1, "Core Data에서 1개의 데이터를 반환해야 함.")
                XCTAssertEqual(images.first?.id, "cached", "캐시된 데이터의 ID가 맞아야 함.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // API 요청 실패 + Core Data 비어있음
    func test_fetchImageList_ApiFails_NoCachedData_ReturnsEmpty() {
        mockNetworkService.mockError = .networkError(NSError(domain: "Test Error", code: -1, userInfo: nil))
        let expectation = XCTestExpectation(description: "API 요청이 실패하고 Core Data에도 데이터가 없으면 빈 배열을 반환해야 함.")

        repository.fetchImageList()
            .sink(receiveCompletion: { _ in }, receiveValue: { images in
                XCTAssertTrue(images.isEmpty, "Core Data에도 데이터가 없으면 빈 배열을 반환해야 함.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}
