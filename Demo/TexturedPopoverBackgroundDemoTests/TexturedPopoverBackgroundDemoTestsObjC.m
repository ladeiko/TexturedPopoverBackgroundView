//
//  TexturedPopoverBackgroundDemoTestsObjC.m
//  TexturedPopoverBackgroundDemoTests
//
//  Created by Siarhei Ladzeika on 10/27/19.
//  Copyright © 2019 Siarhei Ladzeika. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TexturedPopoverBackgroundView-Swift.h>

@interface TexturedPopoverBackgroundDemoTestsObjC: XCTestCase {}
@end

@implementation TexturedPopoverBackgroundDemoTestsObjC

- (void)testExample {
    [TexturedPopoverBackgroundView setBorderWidth: 11];
    XCTAssertEqual(TexturedPopoverBackgroundView.borderWidth, 11);
    
    [TexturedPopoverBackgroundView setCornerRadius: 10];
    XCTAssertEqual(TexturedPopoverBackgroundView.cornerRadius, 10);
    
    [TexturedPopoverBackgroundView setArrowBase:110];
    XCTAssertEqual(TexturedPopoverBackgroundView.arrowBase, 110);
    
    [TexturedPopoverBackgroundView setArrowHeight:111];
    XCTAssertEqual(TexturedPopoverBackgroundView.arrowHeight, 111);
}

@end
