//
//  ServiceError.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

enum ServiceError: Error, Equatable {
    case networkError(String)
    case clientError(Int, String)
    case serverError(Int, String)
    case decodingError(String)
    case unknownError(String)
    
    var userFriendlyMessage: String {
        switch self {
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .clientError(_, let message):
            return "잘못된 요청입니다: \(message)"
        case .serverError(_, let message):
            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요: \(message)"
        case .decodingError(let message):
            return "데이터 처리 중 문제가 발생했습니다: \(message)"
        case .unknownError(let message):
            return "알 수 없는 오류: \(message)"
        }
    }
}
