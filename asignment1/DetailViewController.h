//
//  DetailViewController.h
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BEMSimpleLineGraphView.h"
#import "CorePlot-CocoaTouch.h"

@interface DetailViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>
//BEMSimpleLineGraphDelegate

//@property BEMSimpleLineGraphView *myGraph;        
@property NSMutableArray *ArrayOfValues;
@property NSMutableArray *ArrayOfDates;
@property NSString *stockName;

@end
