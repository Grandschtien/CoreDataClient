//
//  File.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation

import CoreData
import Foundation

public protocol CDMapper {
    associatedtype Item: ItemConvertable
    associatedtype CDModel: NSManagedObject

    func convert(from item: Item, context: NSManagedObjectContext) -> CDModel
    func convert(from cdModel: CDModel) -> Item
}
