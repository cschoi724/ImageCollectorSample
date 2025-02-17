//
//  ImageEntity.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//
//

import Foundation
import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var url: String?
    @NSManaged public var width: Int16
    @NSManaged public var height: Int16
}

extension ImageEntity: CoreDataConvertible {
    public typealias DomainModel = ImageInfo

    public var domain: DomainModel {
        return ImageInfo(
            id: id ?? "",
            url: url ?? "",
            width: Int(width),
            height: Int(height)
        )
    }

    public func update(from model: ImageInfo) {
        self.id = model.id
        self.url = model.url
        self.width = Int16(model.width)
        self.height = Int16(model.height)
    }
}

extension ImageEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }
}
