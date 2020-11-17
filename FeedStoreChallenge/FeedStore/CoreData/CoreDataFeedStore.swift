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
        
        guard let model = bundle.url(forResource: name, withExtension: "momd").flatMap({ (url) in
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
        print("")
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        _ = mapLocalFeedToCoreData(feed, timestamp: timestamp)
        
        if let saveError = saveContext() {
            completion(.some(saveError))
        } else {
            completion(.none)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            if let cache = try fetchCachedFeed() {
                let imageFeed: [LocalFeedImage] = cache.feed.compactMap { ($0 as? CDFeedImage)?.local }
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
    
    private func mapLocalFeedToCoreData(_ feed: [LocalFeedImage], timestamp: Date) -> CDCache {
        
        var imageSet: [CDFeedImage] = []
        
        for image in feed {
            
            let cdImage = CDFeedImage(context: managedContext)
            
            cdImage.id = image.id
            cdImage.url = image.url
            cdImage.imageDescription = image.description
            cdImage.location = image.location
            
            imageSet.append(cdImage)
        }
        
        let images = NSOrderedSet(array: imageSet)
        let cache = CDCache(context: managedContext)
        
        cache.feed = images
        cache.timestamp = timestamp
        
        return cache
    }
    
    private func fetchCachedFeed() throws -> CDCache? {
        let fetchRequest = NSFetchRequest<CDCache>(entityName: Constant.CORE_DATA_CDCACHE_ENTITY_NAME)
        return try managedContext.fetch(fetchRequest).first
    }
}
