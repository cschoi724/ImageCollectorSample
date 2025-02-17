//
//  FetchImageListUseCaseTests.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import XCTest
import Combine
import Foundation
@testable import ImageCollector

final class FetchImageListUseCaseTests: XCTestCase {
    private var useCase: FetchImageListUseCase!
    private var mockRepository: MockImageRepository!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockRepository = MockImageRepository()
        useCase = FetchImageListUseCaseImpl(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // 정상적으로 이미지 리스트를 반환하는지 테스트
    func test_execute_Success() {
        let mockImages = [
            ImageInfo(id: "1", url: "https://example.com/1.jpg", width: 100, height: 100),
            ImageInfo(id: "2", url: "https://example.com/2.jpg", width: 200, height: 200)
        ]
        mockRepository.mockResponse = mockImages

        let expectation = XCTestExpectation(description: "UseCase가 정상적으로 데이터를 반환해야 함.")

        useCase.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("UseCase 실패: \(error)")
                }
            }, receiveValue: { images in
                XCTAssertEqual(images.count, mockImages.count, "이미지 개수가 일치해야 함.")
                XCTAssertEqual(images.first?.id, mockImages.first?.id, "첫 번째 이미지 ID가 동일해야 함.")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // API 요청 실패 시 오류 반환 테스트
    func test_execute_Failure() {
        mockRepository.mockError = .networkError("네트워크 통신 실패")

        let expectation = XCTestExpectation(description: "UseCase가 API 요청 실패 시 오류를 반환해야 함.")

        useCase.execute()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, .networkError("네트워크 통신 실패"), "네트워크 에러가 발생해야 함.")
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("오류가 발생해야 하지만 데이터를 반환함.")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}
