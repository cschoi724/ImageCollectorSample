//
//  NetworkServiceTests.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import XCTest
import Combine
@testable import ImageCollector

final class NetworkServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    private var mockSession: URLSession!
    private var networkService: DefaultNetworkService!
    private var mockConfiguration: APINetworkConfig!

    override func setUp() {
        super.setUp()


        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self] // Mock 프로토콜 사용
        mockSession = URLSession(configuration: config)
        mockConfiguration = APINetworkConfig(baseURL: URL(string: "https://mockapi.com")!)
        networkService = DefaultNetworkService(
            session: mockSession,
            configuration: mockConfiguration
        )
    }

    override func tearDown() {
        cancellables.removeAll()
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        super.tearDown()
    }

    // 정상적인 응답을 받을 경우
    func test_request_SuccessfulResponse() {
        let jsonString = """
        {
            "id": "123",
            "name": "Test Image"
        }
        """
        let responseData = jsonString.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "https://mockapi.com/image")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!

        MockURLProtocol.mockResponse = (response, responseData)

        let expectation = XCTestExpectation(description: "정상적인 응답을 받는지 확인")

        let endpoint = Endpoint(path: "/image", method: .get)

        networkService.request(endpoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    XCTFail("성공을 예상했지만 실패가 발생함")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { (data: MockResponse) in
                XCTAssertEqual(data.id, "123")
                XCTAssertEqual(data.name, "Test Image")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // HTTP 400~500 오류 응답이 발생할 경우
    func test_request_BadServerResponse() {
        let response = HTTPURLResponse(url: URL(string: "https://mockapi.com/error")!,
                                       statusCode: 500,
                                       httpVersion: nil,
                                       headerFields: nil)!

        MockURLProtocol.mockResponse = (response, Data())

        let expectation = XCTestExpectation(description: "서버 오류 응답이 올바르게 처리되는지 확인")

        let endpoint = Endpoint(path: "/error", method: .get)

        networkService.request(endpoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case APIError.badServerResponse(statusCode: 500) = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("500 서버 오류를 예상했지만 다른 오류가 발생함: \(error)")
                    }
                case .finished:
                    XCTFail("실패를 예상했지만 성공이 발생함")
                }
            }, receiveValue: { (_: MockResponse) in
                XCTFail("실패를 예상했지만 성공이 발생함")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // 네트워크 오류가 발생할 경우
    func test_request_NetworkError() {
        let error = NSError(domain: "network", code: -1009, userInfo: nil) // 인터넷 연결 없음 에러

        MockURLProtocol.mockError = error

        let expectation = XCTestExpectation(description: "네트워크 오류가 올바르게 처리되는지 확인")

        let endpoint = Endpoint(path: "/network-error", method: .get)

        networkService.request(endpoint)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let receivedError):
                    if case let APIError.networkError(receivedNetworkError) = receivedError {
                        XCTAssertEqual((receivedNetworkError as NSError).domain, error.domain)
                        XCTAssertEqual((receivedNetworkError as NSError).code, error.code)
                        expectation.fulfill()
                    } else {
                        XCTFail("네트워크 오류를 예상했지만 다른 오류가 발생함: \(receivedError)")
                    }
                case .finished:
                    XCTFail("실패를 예상했지만 성공이 발생함")
                }
            }, receiveValue: { (_: MockResponse) in
                XCTFail("실패를 예상했지만 성공이 발생함")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}
