//
//  XCTest+Tracking.swift
//  Tests
//
//  Created by Antonio Mayorga on 11/26/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated", file: file, line: line)
        }
    }
}
