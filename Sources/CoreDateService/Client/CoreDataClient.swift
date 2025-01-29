//
//  CoreDataClient.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

public protocol CoreDataClient<Item> {
    associatedtype Item: ItemConvertable

    func saveAll(items: [Item])

    func getItems(
        predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) -> [Item]

    func clearDatabase()
}

public extension CoreDataClient {
    func getItem() -> Item? {
        let configuration = FetchRequestConfiguration(fetchLimit: 1)
        return getItems(predicate: nil, configuration: configuration).first
    }

    func save(item: Item) {
        saveAll(items: [item])
    }
}
