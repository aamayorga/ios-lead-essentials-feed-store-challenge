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
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    private let storeContainer: NSPersistentContainer
    private let managedContext: NSManagedObjectContext
    
    public init(modelName name: String, url: URL, in bundle: Bundle) throws {
        guard let model = bundle.url(forResource: name, withExtension: Constant.CORE_DATA_EXTENSION).flatMap({ (url) in
            NSManagedObjectModel(contentsOf: url)
        }) else {
            throw LoadingError.modelNotFound
        }
        let description = NSPersistentStoreDescription(url: url)
        
        storeContainer = NSPersistentContainer(name: name, managedObjectModel: model)
        storeContainer.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        storeContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                loadError = error
            }
        }
        
        try loadError.map {
            throw LoadingError.failedToLoadPersistentStores($0)
        }
        
        managedContext = storeContainer.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        do {
            if let currentCache = try CDCache.fetchCachedFeed(managedContext) {
                managedContext.delete(currentCache)
                
                if let saveError = saveContext() {
                    completion(.some(saveError))
                } else {
                    completion(.none)
                }
            } else {
                completion(.none)
            }
        } catch {
            completion(.some(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            if let currentCache = try CDCache.fetchCachedFeed(managedContext) {
                managedContext.delete(currentCache)
            }
        } catch { /* If there is an error then just insert the feed in Core Data*/ }
        
        let cdFeed = mapLocalFeedToCoreDataFeed(feed, timestamp: timestamp)
        
        if let saveError = saveContext() {
            completion(.some(saveError))
        } else {
            completion(.none)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            if let cache = try CDCache.fetchCachedFeed(managedContext) {
                let imageFeed = cache.feed.compactMap { ($0 as? CDFeedImage)?.local }
                completion(.found(feed: imageFeed, timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    
    
    // MARK: Helper Methods
    
    private func saveContext() -> Error? {
        if storeContainer.viewContext.hasChanges {
            do {
                try storeContainer.viewContext.save()
                return nil
            } catch {
                return error
            }
        } else {
            return nil
        }
    }
    
    private func mapLocalFeedToCoreDataFeed(_ feed: [LocalFeedImage], timestamp: Date) -> CDCache {
        let cache = CDCache(context: managedContext)
        cache.feed = CDFeedImage.mapLocalFeedImagesToCoreDataFeedImages(from: feed, in: managedContext)
        cache.timestamp = timestamp
        return cache
    }
}
