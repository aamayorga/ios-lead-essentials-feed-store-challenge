//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Antonio Mayorga on 11/13/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let storeContainer: NSPersistentContainer
    private let managedContext: NSManagedObjectContext
    
    public init() {
        storeContainer = NSPersistentContainer(name: Constant.CORE_DATA_FEED_STORE_NAME)
        
        storeContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Core Data error \(error)")
            }
        }
        
        managedContext = storeContainer.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        print("")
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        print("")
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
    
    // MARK: Helper Methods
    
    func saveContext() {
        if storeContainer.viewContext.hasChanges {
            do {
                try storeContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}
