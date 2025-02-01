//
//  CDTestMapper.swift
//  CoreDataClient
//
//  Created by Егор Шкарин on 01.02.2025.
//

import CoreDataClient
import CoreData

struct CDTestMapper: CDMapper {
    func convert(from cdModel: CDTestEntity) -> TestItem {
        return TestItem(cdModel: cdModel)
    }
    
    func convert(
        from item: TestItem,
        context: NSManagedObjectContext
    ) -> CDTestEntity {
        let entity = CDTestEntity(context: context)
        entity.id = item.id
        return entity
    }
}
