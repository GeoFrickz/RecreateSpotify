//
//  HomeUITests.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 10/09/26.
//


import XCTest

final class HomeUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // In UI tests it's usually best to stop immediately when a failure occurs
        continueAfterFailure = false
    }
    
    func testHomeScreenLoadsTitle() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Check that the "Home" label defined in HomeViewController exists on screen
        let homeTitleLabel = app.staticTexts["Home"]
        
        // Verify existence
        XCTAssertTrue(homeTitleLabel.exists, "The main 'Home' title should be visible upon launching the app.")
    }
}