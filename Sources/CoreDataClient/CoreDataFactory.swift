//
//  CoreDataFactory.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

public final class CoreDataFactory<
    Mapper: CDMapper,
    CDModel: NSManagedObject,
    Item: ItemConvertable
> {
    public init() { }

    public func buildClient(
        modelName: String,
        mapper: Mapper
    ) -> any CoreDataClient<Item> where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
        return CoreDataClientImpl<Item, CDModel, Mapper>(
            mapper: mapper,
            modelName: modelName
        )
    }
    
    public func buildClient(
        persistantContainer: NSPersistentContainer,
        mapper: Mapper
    ) -> any CoreDataClient<Item> where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
        return CoreDataClientImpl<Item, CDModel, Mapper>(
            mapper: mapper,
            persistentContainer: persistantContainer
        )
    }
}
