//
//  CDTestEntity+CoreDataProperties.swift
//  CoreDataClient
//
//  Created by Егор Шкарин on 30.01.2025.
//
//

import Foundation
import CoreData


extension CDTestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTestEntity> {
        return NSFetchRequest<CDTestEntity>(entityName: "CDTestEntity")
    }

    @NSManaged public var id: Int64

}
