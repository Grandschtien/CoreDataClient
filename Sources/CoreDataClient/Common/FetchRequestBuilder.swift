//
//  FetchRequestBuilder.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

final class FetchRequestBuilder<CDModel: NSManagedObject> {
    let fetchRequst: NSFetchRequest<CDModel>
    
    init(fetchRequst: NSFetchRequest<CDModel>) {
        self.fetchRequst = fetchRequst
    }
    
    func add(sortDescriptors: [NSSortDescriptor]?) {
        fetchRequst.sortDescriptors = sortDescriptors
    }
    
    func add(fetchLimit: Int?) {
        guard let fetchLimit else { return }
        fetchRequst.fetchLimit = fetchLimit
    }
    
    func add(resultType: NSFetchRequestResultType?) {
        guard let resultType else { return }
        fetchRequst.resultType = resultType
    }
    
    func add(returnsObjectsAsFaults: Bool) {
        fetchRequst.returnsObjectsAsFaults = returnsObjectsAsFaults
    }
    
    func add(relationshipKeyPathsForPrefetching: [String]?) {
        fetchRequst.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
    }
    
    func add(fetchOffset: Int?) {
        guard let fetchOffset else { return }
        fetchRequst.fetchOffset = fetchOffset
    }
    
    func add(fetchBatchSize: Int?) {
        guard let fetchBatchSize else { return }
        fetchRequst.fetchBatchSize = fetchBatchSize
    }
    
    func build() -> NSFetchRequest<CDModel> {
        return self.fetchRequst
    }
}
