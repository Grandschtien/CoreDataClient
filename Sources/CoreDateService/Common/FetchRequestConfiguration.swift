//
//  FetchRequestConfiguration.swift
//  CoreDateService
//
//  Created by Егор Шкарин on 29.01.2025.
//

import Foundation
import CoreData

public struct FetchRequestConfiguration {
    let sortDescriptors: [NSSortDescriptor]?
    let fetchLimit: Int?
    let resultType: NSFetchRequestResultType?
    let returnsObjectsAsFaults: Bool
    let relationshipKeyPathsForPrefetching: [String]?
    let fetchOffset: Int?
    let fetchBatchSize: Int?
    
    public init(
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil,
        resultType: NSFetchRequestResultType? = nil,
        returnsObjectsAsFaults: Bool = true,
        relationshipKeyPathsForPrefetching: [String]? = nil,
        fetchOffset: Int? = nil,
        fetchBatchSize: Int? = nil
    ) {
        self.sortDescriptors = sortDescriptors
        self.fetchLimit = fetchLimit
        self.resultType = resultType
        self.returnsObjectsAsFaults = returnsObjectsAsFaults
        self.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        self.fetchOffset = fetchOffset
        self.fetchBatchSize = fetchBatchSize
    }
}
