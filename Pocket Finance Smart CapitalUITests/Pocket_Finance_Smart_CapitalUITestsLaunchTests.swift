//
//  Pocket_Finance_Smart_CapitalUITestsLaunchTests.swift
//  Pocket Finance Smart CapitalUITests
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import XCTest

final class Pocket_Finance_Smart_CapitalUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
