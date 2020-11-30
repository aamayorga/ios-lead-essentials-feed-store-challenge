//
//  CDFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Antonio Mayorga on 11/16/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData

@objc(CDFeedImage)
internal class CDFeedImage: NSManagedObject {
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var url: URL
    @NSManaged internal var cache: CDCache
}

extension CDFeedImage {
    var local: LocalFeedImage {
        return LocalFeedImage(id: id,
                              description: imageDescription,
                              location: location,
                              url: url)
    }
    
    public static func mapLocalFeedImagesToCoreDataFeedImages(from localFeedImages: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        
        var images: [CDFeedImage] = []
        
        for image in localFeedImages {
            let cdImage = CDFeedImage(context: context)
            
            cdImage.id                  = image.id
            cdImage.url                 = image.url
            cdImage.imageDescription    = image.description
            cdImage.location            = image.location
            
            images.append(cdImage)
        }
        
        let imageSet = NSOrderedSet(array: images)
        
        return imageSet
    }
}
