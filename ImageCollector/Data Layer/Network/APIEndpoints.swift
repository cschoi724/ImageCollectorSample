//
//  APIEndpoints.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

struct APIEndpoints {
    static func fetchImageList(request: SearchRequest) -> Endpoint {
        return Endpoint(
            path: "/v1/images/search",
            method: .get,
            queryParametersEncodable: request
        )
    }
}
