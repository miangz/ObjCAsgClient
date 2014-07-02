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


//@property BEMSimpleLineGraphView *myGraph;
@property NSString *stockName;
@property NSArray *csv;

@end
