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

@interface DetailViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate,NSStreamDelegate,NSNetServiceDelegate>


//@property BEMSimpleLineGraphView *myGraph;        
@property NSMutableArray *ArrayOfValues;
@property NSString *stockName;
@property NSArray *csv;

@property (nonatomic, assign, readonly ) BOOL               isStarted;
@property (nonatomic, assign, readonly ) BOOL               isReceiving;
@property (nonatomic, strong, readwrite) NSNetService *     netService;
@property (nonatomic, assign, readwrite) CFSocketRef        listeningSocket;
@property (nonatomic, assign, readonly ) BOOL               isSending;
@property (nonatomic, strong, readwrite) NSOutputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, assign, readonly ) uint8_t *          buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;

@property (copy) NSData  *data ;

- (void) sendMessage:(NSString *)string;
@end
