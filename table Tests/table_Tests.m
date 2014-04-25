//
//  table_Tests.m
//  table Tests
//
//  Created by miang on 4/9/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface table_Tests : XCTestCase

@end

@implementation table_Tests{
    ViewController *view;
}

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSString *str = @"http://download.finance.yahoo.com/d/quotes.csv?s=AAPL&f=snl1c1p2v&e=.csv";
    NSURL *url = [NSURL URLWithString:str];
    [view retrieveData:url];
    XCTAssertNotNil(view.csv, @"Result equals to nil");
}

@end
