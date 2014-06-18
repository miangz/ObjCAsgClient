//
//  DetailViewController.m
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "DetailViewController.h"

#import "NetworkManager.h"
#import "QNetworkAdditions.h"
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface DetailViewController ()

@end

@implementation DetailViewController{
//    NSArray *data;
    CPTXYGraph *graph;
    float min;
    float max;
    int count;
    
    UITextField * price;
    UITextField * change;
    
    NSTimer *t;
    BOOL isClosed;
    NSMutableData *message;
    
    NSString *lastRequest;
}

@synthesize stockName;
@synthesize csv;

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startServer];
    count = 0;
    isClosed = NO;
    if (self.ArrayOfValues == nil) {
        self.ArrayOfValues = [[NSMutableArray alloc]init];
    }
    
    max = -1;
    min = 99999999;
    
    [self.ArrayOfValues addObject:[csv objectAtIndex:2]];
    [self.ArrayOfValues addObject:[csv objectAtIndex:2]];
    NSString *value = [self.ArrayOfValues lastObject];
    if (max<[value floatValue]) {
        max = [value floatValue];
        [self setupPlotSpace];
    }
    if (min>[value floatValue]) {
        min = [value floatValue];
        [self setupPlotSpace];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self initGraph];
}

-(void)viewDidDisappear:(BOOL)animated{
    [t invalidate];
    t = nil;
    isClosed = YES;
    [self.fileStream close];
    [self.networkStream close];
    [self stopServer:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)updateGraph{
    if (isClosed == YES) {
        return;
    }
    [t invalidate];
    t = nil;
    
    [self sendMessage:[NSString stringWithFormat:@"getStockDetail:%@",stockName]];
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateGraph) userInfo:nil repeats:NO];
}
-(void)initData{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //set layout
        //name
        UITextField *name = [[UITextField alloc]initWithFrame:CGRectMake(20, 60, 200, 17)];
        name.font = [UIFont boldSystemFontOfSize:17];
        NSRange r = NSMakeRange(1,[[csv objectAtIndex:1] length]-2);
        NSRange rn = NSMakeRange(1,[[csv objectAtIndex:0] length]-2);
        name.text = [NSString stringWithFormat:@"%@ (%@)",[[csv objectAtIndex:1] substringWithRange:r],[[csv objectAtIndex:0] substringWithRange:rn]];
        name.enabled = NO;
        [self.view addSubview:name];
        
        //price
        price = [[UITextField alloc]initWithFrame:CGRectMake(20, 80, 120, 30)];
        price.font = [UIFont boldSystemFontOfSize:30];
        NSRange rp = NSMakeRange(0, [[csv objectAtIndex:2]length]);
        price.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:2]substringWithRange:rp]];
        price.enabled = NO;
        [self.view addSubview:price];
        
        // change (percent change)
        int y = [[csv objectAtIndex:2]length]*20 ;
        change = [[UITextField alloc]initWithFrame:CGRectMake(y, 85, 150, 30)];
        NSRange rc = NSMakeRange(0, [[csv objectAtIndex:3]length]);
//        NSRange rc2 = NSMakeRange(2, [[csv objectAtIndex:4]length]-3);
        change.text = [NSString stringWithFormat:@"%@(%@%%)",[[csv objectAtIndex:3]substringWithRange:rc],[csv objectAtIndex:4]];
        
        UIColor *color;
        if ([[[csv objectAtIndex:3]substringWithRange:rc]floatValue]>0) {
            color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0];
        }else if ([[[csv objectAtIndex:3]substringWithRange:rc]floatValue]<0) {
            color = [UIColor redColor];
        }else{
            color = [UIColor grayColor];
        }
        change.textColor = color;
        change.enabled = NO;
        [self.view addSubview:change];
        
        UIView *grayLine = [[UIView alloc]initWithFrame:CGRectMake(10, 115, 300, 2)];
        grayLine.backgroundColor = [UIColor grayColor];
        [self.view addSubview:grayLine];
        
        // prev close
        UITextField *t1  = [[UITextField alloc]initWithFrame:CGRectMake(20, 125, 180, 17)];
        t1.text = @"Prev Close: ";
        t1.enabled = NO;
        [self.view addSubview:t1];
        
        UITextField * pClose = [[UITextField alloc]initWithFrame:CGRectMake(20, 125, 280, 17)];
        NSRange rpcl = NSMakeRange(0, [[csv objectAtIndex:6]length]);
        pClose.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:6]substringWithRange:rpcl]];
        pClose.enabled = NO;
        pClose.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:pClose];
        
        //open
        UITextField *t2  = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 180, 17)];
        t2.text = @"Open: ";
        t2.enabled = NO;
        [self.view addSubview:t2];
        
        UITextField * open = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 280, 17)];
        NSRange rO = NSMakeRange(0, [[csv objectAtIndex:7]length]);
        open.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:7]substringWithRange:rO]];
        open.enabled = NO;
        open.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:open];
        
        //50d Moving Average:
        UITextField *t3  = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 180, 17)];
        t3.text = @"50d Moving Average: ";
        t3.enabled = NO;
        [self.view addSubview:t3];
        
        UITextField * movAvg = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 280, 17)];
        NSRange rMA = NSMakeRange(0, [[csv objectAtIndex:10]length]-2);
        movAvg.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:10]substringWithRange:rMA]];
        movAvg.enabled = NO;
        movAvg.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:movAvg];
        
        //rangeDay
        UITextField *t4  = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 180, 17)];
        t4.text = @"Day's Range: ";
        t4.enabled = NO;
        [self.view addSubview:t4];
        
        UITextField * rangeDay = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 280, 17)];
        NSRange rR = NSMakeRange(1, [[csv objectAtIndex:8]length]-2);
        rangeDay.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:8]substringWithRange:rR]];
        rangeDay.enabled = NO;
        rangeDay.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:rangeDay];
        
        //rangeYear
        UITextField *t5  = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 180, 17)];
        t5.text = @"52wk Range: ";
        t5.enabled = NO;
        [self.view addSubview:t5];
        
        UITextField * rangeYear = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 280, 17)];
        NSRange rRY = NSMakeRange(1, [[csv objectAtIndex:9]length]-2);
        rangeYear.text = [NSString stringWithFormat:@"%@",[[csv objectAtIndex:9]substringWithRange:rRY]];
        rangeYear.enabled = NO;
        rangeYear.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:rangeYear];
        
        //Volume
        UITextField *t6  = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 180, 17)];
        t6.text = @"Volume: ";
        t6.enabled = NO;
        [self.view addSubview:t6];
        
        UITextField * vol = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 280, 17)];
        vol.text = [NSString stringWithFormat:@"%@",[csv objectAtIndex:5]];
        vol.enabled = NO;
        vol.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:vol];
        
    });
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBT.frame = CGRectMake(5, 25, 70, 35);
    [backBT setTitle:@"<Back" forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
}

-(void)updateData:(NSArray *)array{
    //price
    NSRange rp = NSMakeRange(0, [[array objectAtIndex:2]length]);
    price.text = [NSString stringWithFormat:@"%@",[[array objectAtIndex:2]substringWithRange:rp]];
    
    float secondLast = [[self.ArrayOfValues objectAtIndex:self.ArrayOfValues.count-2]floatValue];
    float last = [[self.ArrayOfValues lastObject]floatValue];
    if (last == secondLast) {
        return;
    }
    
    int y = [[array objectAtIndex:2]length]*20 ;
    change.frame = CGRectMake(y, 85, 150, 30);
    // change (percent change)
    //        NSRange rc2 = NSMakeRange(2, [[csv objectAtIndex:4]length]-3);
    change.text = [NSString stringWithFormat:@"%.2f(%.2f%%)",last - secondLast,(last - secondLast)/[price.text floatValue]];

    UIColor *color;
    if (last - secondLast>0) {
        color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0];
    }else if (last - secondLast<0) {
        color = [UIColor redColor];
    }else{
        color = [UIColor grayColor];
    }
    change.textColor = color;
    
}

-(void)initGraph{
    //Graph
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"start load graph");
        
        [self createCorePlotGraph];
        [self updateGraph];
        NSLog(@"end load graph");
        
//        UITextField *txtMonth = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-10, 60, 10)];
//        txtMonth.font = [UIFont boldSystemFontOfSize:10];
//        txtMonth.textColor = [UIColor whiteColor];
//        txtMonth.text = @"avg 1 month";
//        [self.view addSubview:txtMonth];
        
        
    });
}

#pragma Core plot graph
-(void)createCorePlotGraph{
    
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    float h = self.view.frame.size.height - 480;
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 280, 320, 200+h)];//self.view.frame.size.width, self.view.frame.size.height)];//(CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling

    hostingView.hostedGraph     = graph;
    
    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    NSDecimal low    = CPTDecimalFromFloat(min*0.9);
    NSDecimal length = CPTDecimalFromFloat((max*1.1)-(min*0.9));
    
    //NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-2) length:CPTDecimalFromUnsignedInteger(12)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:low length:length];
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(10.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    x.minorTicksPerInterval       = 1;
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:6];
    if (max<1) {
        [numberFormatter setPositiveFormat:@"###0.000"];
    }else if(max>100){
        [numberFormatter setPositiveFormat:@"###0.0"];
    }else{
        [numberFormatter setPositiveFormat:@"###0.00"];
    }
    CPTXYAxis *y  = axisSet.yAxis;
    NSDecimal six = CPTDecimalFromInteger(6);
    y.majorIntervalLength         = CPTDecimalDivide(length, six);
    y.majorTickLineStyle          = nil;
    y.minorTicksPerInterval       = 4;
    y.minorTickLineStyle          = nil;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:0.1], [NSNull null]];
    
    
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval = 1;
    y.preferredNumberOfMajorTicks = 5;
    y.labelFormatter = numberFormatter;
    
//    // Axes
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
//    CPTXYAxis *x          = axisSet.xAxis;
//    x.majorIntervalLength         = CPTDecimalFromDouble(1);
//    x.minorTicksPerInterval       = 5;
//    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
//    x.delegate = self;
//
//    
//    CPTXYAxis *y = axisSet.yAxis;
//    y.majorIntervalLength         = CPTDecimalFromDouble((max-min)/10);//distant bt 2 label
//    y.minorTicksPerInterval       = 5;
//    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
//    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:0.1], [NSNull null]];
//    y.delegate             = self;
//    
    
    
    [self.view addSubview:hostingView];


    // Create a line graph
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle                        = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor colorWithComponentRed:0.3 green:0.7 blue:0.9 alpha:1];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.identifier    = @"Green Plot";
    dataSourceLinePlot.dataSource    = self;
    
    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:0.7 blue:0.9 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(max-min/5);//fill under graph to 0
    
    dataSourceLinePlot.opacity = 0.0;
    [graph addPlot:dataSourceLinePlot];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0;
    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    [self setupPlotSpace];
    
    
    

}
-(void)setupPlotSpace{
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    plotSpace.allowsUserInteraction = YES;
    NSDecimal low    = CPTDecimalFromFloat(min*0.9);
    NSDecimal length = CPTDecimalFromFloat((max*1.1)-(min*0.9));
    
    //NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-2) length:CPTDecimalFromUnsignedInteger(12)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:low length:length];
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(10.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    x.minorTicksPerInterval       = 1;
    
    CPTXYAxis *y  = axisSet.yAxis;
    NSDecimal six = CPTDecimalFromInteger(6);
    y.majorIntervalLength         = CPTDecimalDivide(length, six);
    y.majorTickLineStyle          = nil;
    y.minorTicksPerInterval       = 4;
    y.minorTickLineStyle          = nil;
    y.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:0.1], [NSNull null]];
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
//    plotSpace.allowsUserInteraction = NO;
//	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
//    [xRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.4) length:CPTDecimalFromFloat(10.025)]];
//    plotSpace.xRange = xRange;
//    
//    float rangefillter = max-min==0? max/10:(max-min);
//	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
//    [yRange shiftEndToFitInRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(max*1.1) length:CPTDecimalFromFloat(rangefillter)]];
//    [yRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(min*0.9) length:CPTDecimalFromFloat(rangefillter)]];
//    plotSpace.yRange = yRange;
    
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.ArrayOfValues count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithInt:index];
    }

    return [self.ArrayOfValues objectAtIndex:index];
}

#pragma mark -
//#pragma mark Axis Delegate Methods
//
-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    return NO;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    if (axis == axisSet.xAxis) {
        return NO;
    }
    
    
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSNumber *tickLocation in locations ) {
        
       
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor colorWithComponentRed:0.3 green:0.7 blue:0.9 alpha:1];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}



- (void)sendMessage:(NSString *)string{
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self.networkStream close];
    }
    
    [self initNetworkCommunication];
    
    //    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@" , string);
    lastRequest = [[NSString alloc]initWithString:string];
	NSData *data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
	[self.networkStream write:[data bytes] maxLength:[data length]];
    
}

- (void)sendData:(NSData *)mydata{
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self.networkStream close];
    }
    
    [self initNetworkCommunication];
	[self.networkStream write:[mydata bytes] maxLength:[mydata length]];
    
}

- (void) initNetworkCommunication {
    NSOutputStream *    output;
    BOOL                success;
    NSNetService *      netService;
    
    netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSUpload._tcp." name:@"Test"];
    assert(netService != nil);
    
    
    success = [netService qNetworkAdditions_getInputStream:NULL outputStream:&output];
    assert(success);
    
    self.networkStream = output;
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.networkStream open];
    
    // Tell the UI we're sending.
    
    [self sendDidStart];
    
}
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
	//NSLog(@"stream event %i", eventCode);
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            NSLog(@"RECEIVING");
            
			if (aStream == self.fileStream) {
                
                uint8_t buffer[5000];
				long len;
				
				while ([self.fileStream hasBytesAvailable]) {
					len = [self.fileStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSData *d = [[NSData alloc]initWithBytes:buffer length:len];
                        if (output != nil) {
                            if (message == nil) {
                                message = [NSMutableData new];
                            }
                            [message appendData:d];
                        }
					}
				}
                
                NSArray *array;
                if (message != nil) {
                    @try {
                        array = [NSKeyedUnarchiver unarchiveObjectWithData:message];
                        
                    }
                    @catch (NSException *exception) {
                        //                        NSLog(@"ERROR : %@",exception);
                    }
                    @finally{
                        if (array == nil) {
                            NSString *str = [[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding];
                            NSLog(@"string : %@",str);
                            NSRange rng = [str rangeOfString:@"stock not found" options:0];
                            if (rng.length > 0) {
                                NSLog(@"stock not found");
                            }else if(lastRequest != nil){
                                NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                                if (rng.length > 0)
                                    [self sendMessage:lastRequest];
                            }
                        }else if([[array objectAtIndex:0]isEqualToString:@"getStockDetail"]){
                            NSLog(@"array :%@",array);
                            NSString *ticker = [[[array objectAtIndex:1]objectAtIndex:0] substringFromIndex:1];
                            NSString *cutTicker = [NSString stringWithFormat:@"%@",[ticker substringToIndex:ticker.length-1]];
                            if (![cutTicker isEqualToString:stockName]) {
                                return;
                            }
                            if (self.ArrayOfValues == nil) {
                                self.ArrayOfValues = [[NSMutableArray alloc]init];
                            }
                            NSArray *dataOfStock = [array objectAtIndex:1];
                            [self.ArrayOfValues addObject:[dataOfStock objectAtIndex:2]];
//                            
//                            if (count == 0) {
//                                max = -1;
//                                min = 99999999;
//                            }
                            NSString *value = [self.ArrayOfValues lastObject];
                            if (max<[value floatValue]) {
                                max = [value floatValue];
                                [self setupPlotSpace];
                            }
                            if (min>[value floatValue]) {
                                min = [value floatValue];
                                [self setupPlotSpace];
                            }
                            
                            if (self.ArrayOfValues.count>10) {
                                [self.ArrayOfValues removeObjectAtIndex:0];
                            }
                            if (count == 0) {
//                                [self initGraph];
                                count++;
                            }
                            [self updateData:[array objectAtIndex:1]];
                            [graph reloadData];
                            
                            [t invalidate];
                            t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateGraph) userInfo:nil repeats:NO];
//                            NSLog(@"self.ArrayOfValues : %@",self.ArrayOfValues);
                        }
                        message = nil;
                    }
                }
			}
			break;
            
        case NSStreamEventHasSpaceAvailable:
            //            if (aStream == outputStream) {
            //                if (c == 0) {
            //                    [self sendMessage:@"Hello\n"];
            //                    c++;
            //                }
            //
            //            }
            break;
		default:
            //			NSLog(@"Unknown event %@,%@",aStream,inputStream);
            break;
            
	}
}


#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Send succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        self.networkStream.delegate = nil;
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    [self sendDidStopWithStatus:statusString];
}
//Server Receive
- (void)serverDidStartOnPort:(NSUInteger)port
{
    assert( (port != 0) && (port < 65536) );
    NSLog(@"%@", [NSString stringWithFormat:@"Started on port %zu", (size_t) port]);
}
- (void)serverDidStopWithReason:(NSString *)reason
{
    if (reason == nil) {
        reason = @"Stopped";
    }
}
- (void)receiveDidStart
{
    NSLog( @"Receiving" );
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}
- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Receive succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}


- (void)startReceive:(int)fd
{
    CFReadStreamRef     readStream;
    
    assert(fd >= 0);
    
    
    [self.fileStream open];
    
    // Open a stream based on the existing socket file descriptor.  Then configure
    // the stream for async operation.
    
    CFStreamCreatePairWithSocket(NULL, fd, &readStream, NULL);
    assert(readStream != NULL);
    
    self.fileStream = (__bridge NSInputStream *) readStream;
    
    CFRelease(readStream);
    
    [self.fileStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    self.fileStream.delegate = self;
    [self.fileStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.fileStream open];
    
    // Tell the UI we're receiving.
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
{
    if (self.fileStream != nil) {
        self.fileStream.delegate = nil;
        [self.fileStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.fileStream close];
        self.fileStream = nil;
    }
    if (self.networkStream != nil) {
        [self.networkStream close];
        self.networkStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
}


- (BOOL)isStarted
{
    return (self.netService != nil);
}

- (BOOL)isReceiving
{
    return (self.fileStream != nil);
}
- (void)acceptConnection:(int)fd
{
    [self startReceive:fd];
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
// Called by CFSocket when someone connects to our listening socket.
// This implementation just bounces the request up to Objective-C.
{
    NSLog(@"AcceptCallback");
    
    DetailViewController  *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge DetailViewController *) info;
    assert(obj != nil);
    
    assert(s == obj->_listeningSocket);
#pragma unused(s)
    
    [obj acceptConnection:*(int *)data];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
// A NSNetService delegate callback that's called if our Bonjour registration
// fails.  We respond by shutting down the server.
//
// This is another of the big simplifying assumptions in this sample.
// A real server would use the real name of the device for registrations,
// and handle automatically renaming the service on conflicts.  A real
// client would allow the user to browse for services.  To simplify things
// we just hard-wire the service name in the client and, in the server, fail
// if there's a service name conflict.
{
#pragma unused(sender)
    assert(sender == self.netService);
#pragma unused(errorDict)
    
    [self stopServer:@"Registration failed"];
}

- (void)startServer
{
    BOOL                success;
    int                 err;
    int                 fd;
    int                 junk;
    struct sockaddr_in  addr;
    NSUInteger          port;
    
    // Create a listening socket and use CFSocket to integrate it into our
    // runloop.  We bind to port 0, which causes the kernel to give us
    // any free port, then use getsockname to find out what port number we
    // actually got.
    
    port = 0;
    
    fd = socket(AF_INET, SOCK_STREAM, 0);
    success = (fd != -1);
    
    if (success) {
        memset(&addr, 0, sizeof(addr));
        addr.sin_len    = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port   = 0;
        addr.sin_addr.s_addr = INADDR_ANY;
        err = bind(fd, (const struct sockaddr *) &addr, sizeof(addr));
        success = (err == 0);
    }
    if (success) {
        err = listen(fd, 5);
        success = (err == 0);
    }
    if (success) {
        socklen_t   addrLen;
        
        addrLen = sizeof(addr);
        err = getsockname(fd, (struct sockaddr *) &addr, &addrLen);
        success = (err == 0);
        
        if (success) {
            assert(addrLen == sizeof(addr));
            port = ntohs(addr.sin_port);
        }
    }
    if (success) {
        CFSocketContext context = { 0, (__bridge void *) self, NULL, NULL, NULL };
        
        assert(self->_listeningSocket == NULL);
        self->_listeningSocket = CFSocketCreateWithNative(
                                                          NULL,
                                                          fd,
                                                          kCFSocketAcceptCallBack,
                                                          AcceptCallback,
                                                          &context
                                                          );
        success = (self->_listeningSocket != NULL);
        
        if (success) {
            CFRunLoopSourceRef  rls;
            
            fd = -1;        // listeningSocket is now responsible for closing fd
            
            rls = CFSocketCreateRunLoopSource(NULL, self.listeningSocket, 0);
            assert(rls != NULL);
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
            
            CFRelease(rls);
        }
    }
    
    // Now register our service with Bonjour.  See the comments in -netService:didNotPublish:
    // for more info about this simplifying assumption.
    
    if (success) {
        self.netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSDownload._tcp." name:@"Test" port:port];
        success = (self.netService != nil);
    }
    if (success) {
        self.netService.delegate = self;
        
        [self.netService publishWithOptions:NSNetServiceNoAutoRename];
        
        // continues in -netServiceDidPublish: or -netService:didNotPublish: ...
    }
    
    // Clean up after failure.
    
    if ( success ) {
        assert(port != 0);
        [self serverDidStartOnPort:port];
    } else {
        [self stopServer:@"Start failed"];
        if (fd != -1) {
            junk = close(fd);
            assert(junk == 0);
        }
    }
}

- (void)stopServer:(NSString *)reason
{
    if (self.isReceiving) {
        [self stopReceiveWithStatus:@"Cancelled"];
    }
    if (self.netService != nil) {
        [self.netService stop];
        self.netService = nil;
    }
    if (self.listeningSocket != NULL) {
        CFSocketInvalidate(self.listeningSocket);
        CFRelease(self->_listeningSocket);
        self->_listeningSocket = NULL;
    }
    [self serverDidStopWithReason:reason];
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}


@end

