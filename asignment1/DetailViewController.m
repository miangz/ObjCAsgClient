//
//  DetailViewController.m
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "DetailViewController.h"
#import "NSStreamManager.h"
#import "DetailView.h"

@interface DetailViewController ()

@end

@implementation DetailViewController{
    CPTXYGraph *graph;
    float min;
    float max;
    int count;
    NSMutableArray *ArrayOfValues;
    
    UITextField * price;
    UITextField * change;
    
    NSTimer *t;
}

@synthesize stockName;
@synthesize csv;


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
    count = 0;
    if (ArrayOfValues == nil) {
        ArrayOfValues = [[NSMutableArray alloc]init];
    }
    
    max = -1;
    min = 99999999;
    
    [ArrayOfValues addObject:[csv objectAtIndex:2]];
    [ArrayOfValues addObject:[csv objectAtIndex:2]];
    NSString *value = [ArrayOfValues lastObject];
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
-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"recievedData"
                                               object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [t invalidate];
    t = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [t invalidate];
    t = nil;
    
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:[NSString stringWithFormat:@"getStockDetail:%@",stockName]];
    t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateGraph) userInfo:nil repeats:NO];
}
-(void)initData{
    
    //set layout
    //name
    DetailView *dv = [[DetailView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [dv initWithCSV:csv];
    [self.view addSubview:dv];
    
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
    
    float secondLast = [[ArrayOfValues objectAtIndex:ArrayOfValues.count-2]floatValue];
    float last = [[ArrayOfValues lastObject]floatValue];
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
        
    });
}

#pragma Core plot graph
-(void)createCorePlotGraph{
    
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    float h = self.view.frame.size.height - 480;
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 280, 320, 200+h)];
    hostingView.collapsesLayers = NO;
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
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(0);//fill under graph to 0
    
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
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [ArrayOfValues count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if (fieldEnum == CPTScatterPlotFieldX) {
        return [NSNumber numberWithInt:index];
    }
    return [ArrayOfValues objectAtIndex:index];
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    return NO;
}
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"recievedData"]){
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        NSArray *array;
        
        if (myManager.message != nil) {
            @try {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:myManager.message];
                            }
            @catch (NSException *exception) {
                        NSLog(@"ERROR : %@",exception);
            }
            @finally{
                if (array == nil) {
                    NSString *str = [[NSString alloc]initWithData:myManager.message encoding:NSASCIIStringEncoding];
                    NSLog(@"string : %@",str);
                    NSRange rng = [str rangeOfString:@"stock not found" options:0];
                    if (rng.length > 0) {
                        NSLog(@"stock not found");
                    }else if(myManager.lastRequest != nil){
                        NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                        if (rng.length > 0)
                            [myManager resendLastMessage];
                    }
                }else if([[array objectAtIndex:0]isEqualToString:@"getStockDetail"]){
                    NSLog(@"array :%@",array);
                    NSString *ticker = [[[array objectAtIndex:1]objectAtIndex:0] substringFromIndex:1];
                    NSString *cutTicker = [NSString stringWithFormat:@"%@",[ticker substringToIndex:ticker.length-1]];
                    if (![[cutTicker lowercaseString] isEqualToString:[stockName lowercaseString]]) {
                        return;
                    }
                    if (ArrayOfValues == nil) {
                        ArrayOfValues = [[NSMutableArray alloc]init];
                    }
                    NSArray *dataOfStock = [array objectAtIndex:1];
                    [ArrayOfValues addObject:[dataOfStock objectAtIndex:2]];
                    NSString *value = [ArrayOfValues lastObject];
                    if (max<[value floatValue]) {
                        max = [value floatValue];
                        [self setupPlotSpace];
                    }
                    if (min>[value floatValue]) {
                        min = [value floatValue];
                        [self setupPlotSpace];
                    }
                    
                    if (ArrayOfValues.count>10) {
                        [ArrayOfValues removeObjectAtIndex:0];
                    }
                    if (count == 0) {
                        count++;
                    }
                    [self updateData:[array objectAtIndex:1]];
                    [graph reloadData];
                    
                    [t invalidate];
                    t = nil;
                    t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateGraph) userInfo:nil repeats:NO];
                }
            }
        }
    }
}

@end

