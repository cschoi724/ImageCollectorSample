//
//  MockURLProtocol.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var mockResponse: (HTTPURLResponse, Data)?
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let (response, data) = MockURLProtocol.mockResponse {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
