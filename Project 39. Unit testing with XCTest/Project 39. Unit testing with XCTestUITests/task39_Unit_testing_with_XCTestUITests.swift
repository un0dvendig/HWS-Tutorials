//
//  task39_Unit_testing_with_XCTestUITests.swift
//  Project 39. Unit testing with XCTestUITests
//
//  Created by Eugene Ilyin on 09.01.2020.
//  Copyright © 2020 Eugene Ilyin. All rights reserved.
//

import XCTest

class task39_Unit_testing_with_XCTestUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testUserFilteringByString() {
        XCUIApplication().launch()
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("test")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }
    
    func testUserFilteringByNumber1000() {
        XCUIApplication().launch()
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("1000")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 55, "There are should be 55 word matching '1000'")
    }
    
    func testUserTapsCancel() {
        XCUIApplication().launch()
        let app = XCUIApplication()
        
        var alertsCount = app.alerts.count
        XCTAssertEqual(alertsCount, 0, "There should be 0 alerts before 'search' tap")
        
        let searchButton = app.navigationBars["Title"].buttons["Search"]
        searchButton.tap()
        
        alertsCount = app.alerts.count
        XCTAssertEqual(alertsCount, 1, "There should be 1 alert after 'search' tap")
        
        let cancelButton = app.alerts["Filter..."].scrollViews.otherElements.buttons["Cancel"]
        cancelButton.tap()
        
        alertsCount = app.alerts.count
        XCTAssertEqual(alertsCount, 0, "There should be 0 alerts after 'cancel' tap")
    }
    
    func testInitialStateIsCorrect() {
        XCUIApplication().launch()
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }
}
