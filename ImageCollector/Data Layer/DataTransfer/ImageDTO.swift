//
//  ImageDTO.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

struct ImageDTO: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}

extension ImageDTO {
    var domain: ImageInfo {
        .init(id: id, url: url, width: width, height: height)
    }
}
