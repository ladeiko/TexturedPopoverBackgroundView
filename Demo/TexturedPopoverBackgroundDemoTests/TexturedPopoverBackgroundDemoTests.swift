//
//  TexturedPopoverBackgroundDemoTests.swift
//  TexturedPopoverBackgroundDemoTests
//
//  Created by Siarhei Ladzeika on 10/27/19.
//  Copyright © 2019 Siarhei Ladzeika. All rights reserved.
//

import XCTest
import TexturedPopoverBackgroundView

class Class1: TexturedPopoverBackgroundView {}

class TexturedPopoverBackgroundDemoTests: XCTestCase {

    func testExample() {
        TexturedPopoverBackgroundView.setBorderWidth(11)
        XCTAssertEqual(TexturedPopoverBackgroundView.borderWidth, 11)
        XCTAssertNotEqual(TexturedPopoverBackgroundView.borderWidth, Class1.borderWidth)
        
        Class1.setBorderWidth(12)
        XCTAssertEqual(TexturedPopoverBackgroundView.borderWidth, 11)
        XCTAssertEqual(Class1.borderWidth, 12)
    }

}
