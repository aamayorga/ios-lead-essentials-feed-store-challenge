//
//  CDCache.swift
//  FeedStoreChallenge
//
//  Created by Antonio Mayorga on 11/16/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

@objc(CDCache)
internal class CDCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var feed: NSOrderedSet
}

extension CDCache {
    public static func fetchCachedFeed(_ context: NSManagedObjectContext) throws -> CDCache? {
        let fetchRequest = NSFetchRequest<CDCache>(entityName: Constant.CORE_DATA_CACHE)
        return try context.fetch(fetchRequest).first
    }
}

