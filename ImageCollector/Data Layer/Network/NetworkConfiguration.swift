//
//  NetworkConfiguration.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation

protocol NetworkConfiguration {
    var baseURL: URL { get set}
    var headers: [String: String] { get set}
    var queryParameters: [String: String] { get set}
    var bodyParameters: [String: Any] { get set}
}

public struct APINetworkConfig: NetworkConfiguration {
    public var baseURL: URL
    public var headers: [String: String]
    public var queryParameters: [String: String]
    public var bodyParameters: [String: Any]
    
    public init(
        baseURL: URL,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:],
        bodyParameters: [String: Any] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
    }
}
