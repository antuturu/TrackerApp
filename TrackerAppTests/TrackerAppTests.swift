//
//  TrackerAppTests.swift
//  TrackerAppTests
//
//  Created by Александр Акимов on 09.04.2024.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerAppTests: XCTestCase {
    
    func testViewController() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()! // 1
        
        assertSnapshot(matching: vc, as: .image)
        
    }
}
