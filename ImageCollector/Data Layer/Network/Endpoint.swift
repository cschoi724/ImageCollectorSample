//
//  Endpoint.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//
import Foundation

struct Endpoint {
    public let path: String
    public let method: HTTPMethodType
    public let headerParameters: [String: String]
    public let queryParametersEncodable: Encodable?
    public let queryParameters: [String: Any]
    public let bodyParametersEncodable: Encodable?
    public let bodyParameters: [String: Any]
    
    init(
        path: String,
        method: HTTPMethodType,
        headerParameters: [String: String] = [:],
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String: Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyParameters: [String: Any] = [:]
    ) {
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
    }
}

public struct HTTPMethodType: RawRepresentable, Equatable, Hashable {
    public static let delete = HTTPMethodType(rawValue: "DELETE")
    public static let get = HTTPMethodType(rawValue: "GET")
    public static let post = HTTPMethodType(rawValue: "POST")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Endpoint {
    func asURLRequest(configuration: NetworkConfiguration) throws -> URLRequest {
        // Base URL + Path 확인
        guard let url = URL(string: configuration.baseURL.absoluteString + path) else {
            throw APIError.invalidURL
        }

        // URLComponents 생성 및 쿼리 매핑
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let queryParameters = queryParametersEncodable {
            do {
                let data = try JSONEncoder().encode(queryParameters)
                let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                components?.queryItems = dictionary?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            } catch {
                throw APIError.invalidURL
            }
        } else if !queryParameters.isEmpty {
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }

        // URLRequest 생성
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue

        // Header 병합
        var mergedHeaders = configuration.headers
        headerParameters.forEach { mergedHeaders[$0.key] = $0.value }
        request.allHTTPHeaderFields = mergedHeaders

        // Body 데이터 설정
        if let bodyEncodable = bodyParametersEncodable {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(bodyEncodable)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.invalidBody
            }
        } else if !bodyParameters.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.invalidBody
            }
        }

        return request
    }
}
