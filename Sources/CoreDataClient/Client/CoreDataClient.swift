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
    associatedtype CDModel: NSManagedObject where Item.CDModel == CDModel

    func saveAll(
        items: [Item],
        completion: ((Error?) -> Void)?
    )
    
    func getItems(
        predicate: NSPredicate?,
        configuration: FetchRequestConfiguration?
    ) -> [Item]
    
    func deleteItems(
        via predicate: NSPredicate,
        completion: ((Error?) -> Void)?
    )
    
    func deleteAll(completion: ((Error?) -> Void)?)

    func updateItem(
        predicate: NSPredicate,
        updateBlock: @escaping (CDModel) -> Void,
        completion: ((Error?) -> Void)?
    )
    
    func refreshViewContext()
}

public extension CoreDataClient {
    /// Method returns first item from selection
    func getItem() -> Item? {
        let configuration = FetchRequestConfiguration(fetchLimit: 1)
        return getItems(predicate: nil, configuration: configuration).first
    }
    
    /// Method returns first item from selection according to given predicate
    func getItem(with predicate: NSPredicate? = nil) -> Item? {
        let configuration = FetchRequestConfiguration(fetchLimit: 1)
        return getItems(predicate: predicate, configuration: configuration).first
    }
    
    func save(item: Item, completion: ((Error?) -> Void)?) {
        saveAll(items: [item], completion: completion)
    }
}
