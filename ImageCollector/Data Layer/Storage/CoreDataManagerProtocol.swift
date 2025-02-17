//
//  CoreDataManagerProtocol.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import CoreData

protocol CoreDataManagerProtocol {
    var context: NSManagedObjectContext { get }
    func saveContext()
}
