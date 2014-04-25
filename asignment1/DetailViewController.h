//
//  DetailViewController.h
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface DetailViewController : UIViewController<BEMSimpleLineGraphDelegate>


@property BEMSimpleLineGraphView *myGraph;
//@property CPTXYGraph *graph;
@property NSMutableArray *ArrayOfValues;
@property NSMutableArray *ArrayOfDates;
@property NSString *stockName;

@end
