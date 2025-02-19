//
//  ImageInfo.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation

public struct ImageInfo {
    let id: String
    let url: String
    let width: Int
    let height: Int
    let imageData: Data?
}

extension ImageInfo: Equatable, Hashable {
    
}

/* ex
 "id": "ahv",
 "url": "https://cdn2.thecatapi.com/images/ahv.jpg",
 "width": 625,
 "height": 469
 */
