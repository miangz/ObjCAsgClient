//
//  asignment1Tests.m
//  asignment1Tests
//
//  Created by miang on 4/8/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProfilerClk.h"
@interface asignment1Tests : XCTestCase

@end

@implementation asignment1Tests{
    ProfilerClk *clk;
}

- (void)setUp
{
    [super setUp];
    clk = [ProfilerClk new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStart
{
    [clk start];
    XCTAssertNotEqual(clk.st, 0, @"start fail");
}

-(void)testNano{
    [clk start];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [clk printNanoDifferent];
        XCTAssertTrue(clk.elapsedNano/1000000000 > 0, @"clock can't measure nanosec");
    });
}

@end
