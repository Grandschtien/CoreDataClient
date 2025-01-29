//
//  CoreDataFactory.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

public final class CoreDataFactory {
    func buildClient<
        Mapper: CDMapper,
        CDModel: NSManagedObject,
        Item: ItemConvertable
    >(
        modelName: String,
        mapper: Mapper
    ) -> any CoreDataClient where Item.CDModel == CDModel, Mapper.Item == Item, Mapper.CDModel == CDModel {
        return CoreDataClientImpl<Item, CDModel, Mapper>(
            modelName: modelName,
            mapper: mapper
        )
    }
}
