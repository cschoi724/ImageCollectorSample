//
//  ImageInfo.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

public struct ImageInfo {
    let id: String
    let url: String
    let width: Int
    let height: Int
}

extension ImageInfo: Equatable, Hashable {
    
}

/* ex
 "id": "ahv",
 "url": "https://cdn2.thecatapi.com/images/ahv.jpg",
 "width": 625,
 "height": 469
 */
