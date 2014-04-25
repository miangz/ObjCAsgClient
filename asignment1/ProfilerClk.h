//
//  ProfilerClk.h
//  ProfilerClock
//
//  Created by miang on 4/6/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfilerClk : NSObject


@property uint64_t st;
@property uint64_t elapsedNano;
-(void)start;
-(void)printNanoDifferent;

@end
