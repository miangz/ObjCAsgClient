//
//  DetailView.m
//  asignment1
//
//  Created by miang on 7/1/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "DetailView.h"

@implementation DetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initWithCSV:(NSArray*)csv{
    
    //set layout
    //name
    UITextField *name = [[UITextField alloc]initWithFrame:CGRectMake(20, 60, 200, 17)];
    name.font = [UIFont boldSystemFontOfSize:17];
    NSRange r = NSMakeRange(1,[[csv objectAtIndex:1] length]-2);
    NSRange rn = NSMakeRange(1,[[csv objectAtIndex:0] length]-2);
    name.text = [NSString stringWithFormat:@"%@ (%@)",[[csv objectAtIndex:1] substringWithRange:r],[[csv objectAtIndex:0] substringWithRange:rn]];
    name.enabled = NO;
    [self addSubview:name];
    
    UIView *grayLine = [[UIView alloc]initWithFrame:CGRectMake(10, 115, 300, 2)];
    grayLine.backgroundColor = [UIColor grayColor];
    [self addSubview:grayLine];
    
    // prev close
    UITextField *t1  = [[UITextField alloc]initWithFrame:CGRectMake(20, 125, 180, 17)];
    t1.text = @"Prev Close: ";
    t1.enabled = NO;
    [self addSubview:t1];
    
    UITextField * pClose = [[UITextField alloc]initWithFrame:CGRectMake(20, 125, 280, 17)];
    NSRange rpcl = NSMakeRange(0, [[csv objectAtIndex:6]length]);
    pClose.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:6]substringWithRange:rpcl]];
    pClose.enabled = NO;
    pClose.textAlignment = NSTextAlignmentRight;
    [self addSubview:pClose];
    
    //open
    UITextField *t2  = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 180, 17)];
    t2.text = @"Open: ";
    t2.enabled = NO;
    [self addSubview:t2];
    
    UITextField * open = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 280, 17)];
    NSRange rO = NSMakeRange(0, [[csv objectAtIndex:7]length]);
    open.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:7]substringWithRange:rO]];
    open.enabled = NO;
    open.textAlignment = NSTextAlignmentRight;
    [self addSubview:open];
    
    //50d Moving Average:
    UITextField *t3  = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 180, 17)];
    t3.text = @"50d Moving Average: ";
    t3.enabled = NO;
    [self addSubview:t3];
    
    UITextField * movAvg = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 280, 17)];
    NSRange rMA = NSMakeRange(0, [[csv objectAtIndex:10]length]-2);
    movAvg.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:10]substringWithRange:rMA]];
    movAvg.enabled = NO;
    movAvg.textAlignment = NSTextAlignmentRight;
    [self addSubview:movAvg];
    
    //rangeDay
    UITextField *t4  = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 180, 17)];
    t4.text = @"Day's Range: ";
    t4.enabled = NO;
    [self addSubview:t4];
    
    UITextField * rangeDay = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 280, 17)];
    NSRange rR = NSMakeRange(1, [[csv objectAtIndex:8]length]-2);
    rangeDay.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:8]substringWithRange:rR]];
    rangeDay.enabled = NO;
    rangeDay.textAlignment = NSTextAlignmentRight;
    [self addSubview:rangeDay];
    
    //rangeYear
    UITextField *t5  = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 180, 17)];
    t5.text = @"52wk Range: ";
    t5.enabled = NO;
    [self addSubview:t5];
    
    UITextField * rangeYear = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 280, 17)];
    NSRange rRY = NSMakeRange(1, [[csv objectAtIndex:9]length]-2);
    rangeYear.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:9]substringWithRange:rRY]];
    rangeYear.enabled = NO;
    rangeYear.textAlignment = NSTextAlignmentRight;
    [self addSubview:rangeYear];
    
    //Volume
    UITextField *t6  = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 180, 17)];
    t6.text = @"Volume: ";
    t6.enabled = NO;
    [self addSubview:t6];
    
    UITextField * vol = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 280, 17)];
    vol.text = [NSString stringWithFormat:@"%@",[csv objectAtIndex:5]];
    vol.enabled = NO;
    vol.textAlignment = NSTextAlignmentRight;
    [self addSubview:vol];
    
}
@end
