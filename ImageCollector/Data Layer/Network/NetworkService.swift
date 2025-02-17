//
//  NetworkService.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation
import Combine

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError>
}

final class DefaultNetworkService: NetworkService {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private let logger: NetworkLogger

    init(
        session: URLSession = .shared,
        configuration: NetworkConfiguration,
        logger: NetworkLogger = DefaultNetworkLogger(isEnabled: true)
    ) {
        self.session = session
        self.configuration = configuration
        self.logger = logger
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        Future { [weak self] promise in
            guard let self = self else { return }

            Task {
                do {
                    let request = try endpoint.asURLRequest(configuration: self.configuration)
                    self.logger.log("URLRequest created: \(request)")

                    let (data, response) = try await self.session.data(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.badServerResponse(statusCode: 0)
                    }
                    self.logger.log("HTTP Status Code: \(httpResponse.statusCode)")

                    switch httpResponse.statusCode {
                    case 200..<300:
                        if let responseString = String(data: data, encoding: .utf8) {
                            self.logger.log("Response Data: \(responseString)")
                        }
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            self.logger.log("Decoded Data: \(decodedData)")
                            promise(.success(decodedData))
                        } catch {
                            if let decodingError = error as? DecodingError {
                                self.logger.log("Decoding Error: \(decodingError)")
                            }
                            throw error
                        }
                    default:
                        throw APIError.badServerResponse(statusCode: httpResponse.statusCode)
                    }
                } catch let error as APIError {
                    self.logger.log("API Error: \(error)")
                    promise(.failure(error))
                } catch {
                    self.logger.log("General Error: \(error)")
                    promise(.failure(.networkError(error)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
