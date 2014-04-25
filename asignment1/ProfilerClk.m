//
//  ProfilerClk.m
//  ProfilerClock
//
//  Created by miang on 4/6/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import "ProfilerClk.h"

#include <assert.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

@implementation ProfilerClk{
    mach_timebase_info_data_t    sTimebaseInfo;
}
@synthesize st;
@synthesize elapsedNano;
-(void)start{
    st = mach_absolute_time();
}

-(void)printNanoDifferent{
    
    //From https://developer.apple.com/library/mac/qa/qa1398/_index.html
    uint64_t        end;
    uint64_t        elapsed;
    
    // Call getpid. This will produce inaccurate results because
    // we're only making a single system call. For more accurate
    // results you should call getpid multiple times and average
    // the results.
    
    (void) getpid();
    
    // Stop the clock.
    
    end = mach_absolute_time();
    
    // Calculate the duration.
    
    elapsed = end - st;
    
    // Convert to nanoseconds.
    
    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is
    // uninitialised because it makes no sense to have a zero
    // denominator is a fraction.
    
    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Do the maths. We hope that the multiplication doesn't
    // overflow; the price you pay for working in fixed point.
    
    elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom ;
    
    NSLog(@"elapsedNano : %llu nanosec(s)",elapsedNano);
    
}

@end
