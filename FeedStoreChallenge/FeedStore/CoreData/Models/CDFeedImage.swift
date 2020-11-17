//
//  CDFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Antonio Mayorga on 11/16/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CDFeedImage)
internal class CDFeedImage: NSManagedObject {
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var id: UUID
    @NSManaged internal var url: URL
    @NSManaged internal var cache: CDCache
    
    var local: LocalFeedImage {
        return LocalFeedImage(id: id,
                              description: imageDescription,
                              location: location,
                              url: url)
    }
}
