//
//  TestItem.swift
//  CoreDataClient
//
//  Created by Егор Шкарин on 01.02.2025.
//


import CoreDataClient
import CoreData

struct TestItem: ItemConvertable, Equatable {
    let id: Int64

    init(id: Int64) {
        self.id = id
    }

    init(cdModel: CDTestEntity) {
        self.id = cdModel.id
    }
}
