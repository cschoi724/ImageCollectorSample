//
//  CoreDataConvertible.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

public protocol CoreDataConvertible {
    associatedtype DomainModel

    var domain: DomainModel { get }
    func update(from model: DomainModel)
}
