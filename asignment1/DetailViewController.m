//
//  DetailViewController.m
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController{
    NSArray *data;
}
@synthesize stockName;

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"start load");
        UIColor *color;
        NSString *str = [NSString stringWithFormat:@"http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=snl1c1p2vp0o0m0w0m3&e=.csv",stockName];
        NSURL *url = [NSURL URLWithString:str];
        NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
        data = [reply componentsSeparatedByString:@","];
        NSLog(@"receive reply :%@",data);
        
        //set layout
        //name
        UITextField *name = [[UITextField alloc]initWithFrame:CGRectMake(20, 60, 200, 17)];
        name.font = [UIFont boldSystemFontOfSize:17];
        NSRange r = NSMakeRange(1,[[data objectAtIndex:1] length]-2);
        NSRange rn = NSMakeRange(1,[[data objectAtIndex:0] length]-2);
        name.text = [NSString stringWithFormat:@"%@ (%@)",[[data objectAtIndex:1] substringWithRange:r],[[data objectAtIndex:0] substringWithRange:rn]];
        name.enabled = NO;
        [self.view addSubview:name];
        
        //price
        UITextField * price = [[UITextField alloc]initWithFrame:CGRectMake(20, 80, 120, 30)];
        price.font = [UIFont boldSystemFontOfSize:30];
        NSRange rp = NSMakeRange(0, [[data objectAtIndex:2]length]);
        price.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:2]substringWithRange:rp]];
        price.enabled = NO;
        [self.view addSubview:price];
        
        // change (percent change)
        int y = [[data objectAtIndex:2]length]*20 ;
        UITextField * change = [[UITextField alloc]initWithFrame:CGRectMake(y, 85, 150, 30)];
        NSRange rc = NSMakeRange(0, [[data objectAtIndex:3]length]);
        NSRange rc2 = NSMakeRange(2, [[data objectAtIndex:4]length]-3);
        change.text = [NSString stringWithFormat:@"%@(%@)",[[data objectAtIndex:3]substringWithRange:rc],[[data objectAtIndex:4]substringWithRange:rc2]];
        
        if ([[[data objectAtIndex:3]substringWithRange:rc]floatValue]>0) {
            color = [UIColor colorWithRed:31.0/255.0 green:187.0/255.0 blue:166.0/255.0 alpha:1.0];
        }else if ([[[data objectAtIndex:3]substringWithRange:rc]floatValue]<0) {
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
        NSRange rpcl = NSMakeRange(0, [[data objectAtIndex:6]length]);
        pClose.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:6]substringWithRange:rpcl]];
        pClose.enabled = NO;
        pClose.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:pClose];
        
        //open
        UITextField *t2  = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 180, 17)];
        t2.text = @"Open: ";
        t2.enabled = NO;
        [self.view addSubview:t2];
        
        UITextField * open = [[UITextField alloc]initWithFrame:CGRectMake(20, 150, 280, 17)];
        NSRange rO = NSMakeRange(0, [[data objectAtIndex:7]length]);
        open.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:7]substringWithRange:rO]];
        open.enabled = NO;
        open.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:open];
        
        //50d Moving Average:
        UITextField *t3  = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 180, 17)];
        t3.text = @"50d Moving Average: ";
        t3.enabled = NO;
        [self.view addSubview:t3];
        
        UITextField * movAvg = [[UITextField alloc]initWithFrame:CGRectMake(20, 175, 280, 17)];
        NSRange rMA = NSMakeRange(0, [[data objectAtIndex:10]length]-2);
        movAvg.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:10]substringWithRange:rMA]];
        movAvg.enabled = NO;
        movAvg.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:movAvg];
        
        //rangeDay
        UITextField *t4  = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 180, 17)];
        t4.text = @"Day's Range: ";
        t4.enabled = NO;
        [self.view addSubview:t4];
        
        UITextField * rangeDay = [[UITextField alloc]initWithFrame:CGRectMake(20, 200, 280, 17)];
        NSRange rR = NSMakeRange(1, [[data objectAtIndex:8]length]-2);
        rangeDay.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:8]substringWithRange:rR]];
        rangeDay.enabled = NO;
        rangeDay.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:rangeDay];
        
        //rangeYear
        UITextField *t5  = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 180, 17)];
        t5.text = @"52wk Range: ";
        t5.enabled = NO;
        [self.view addSubview:t5];
        
        UITextField * rangeYear = [[UITextField alloc]initWithFrame:CGRectMake(20, 225, 280, 17)];
        NSRange rRY = NSMakeRange(1, [[data objectAtIndex:9]length]-2);
        rangeYear.text = [NSString stringWithFormat:@"%@",[[data objectAtIndex:9]substringWithRange:rRY]];
        rangeYear.enabled = NO;
        rangeYear.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:rangeYear];
        
        //Volume
        UITextField *t6  = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 180, 17)];
        t6.text = @"Volume: ";
        t6.enabled = NO;
        [self.view addSubview:t6];
        
        UITextField * vol = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 280, 17)];
        vol.text = [NSString stringWithFormat:@"%@",[data objectAtIndex:5]];
        vol.enabled = NO;
        vol.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:vol];
        NSLog(@"endLoad");
        
    });
    [self initGraph];
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBT.frame = CGRectMake(5, 25, 70, 35);
    [backBT setTitle:@"<Back" forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initGraph{
    //Graph
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"start load graph");
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(  NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        int end = (int)[components day];
        [components setMonth:([components month] - 1)];
        int start = (int)[components day];
        
        NSString *str = [NSString stringWithFormat:@"http://ichart.finance.yahoo.com/table.csv?s=%@&a=02&b=%d&c=2014&d=03&e=%d&f=2014&g=d&ignore=.csv",stockName,start,end];
        NSURL *url = [NSURL URLWithString:str];
        NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
        NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc]init];
        [charSet addCharactersInString:@","];
        [charSet addCharactersInString:@"\n"];
        data = [reply componentsSeparatedByCharactersInSet:charSet];
        NSLog(@"*********************\ndata :%@",data);
        
        self.ArrayOfValues = [[NSMutableArray alloc] init];
        self.ArrayOfDates = [[NSMutableArray alloc] init];
        for (int i = 1; (i*7)+7 < data.count; i++) {
            [self.ArrayOfValues insertObject:[data objectAtIndex:i*7+6] atIndex:0];//(arc4random() % 70000)]];
            [self.ArrayOfDates addObject:@""];
            
        }
        
        //Another Graph
        self.myGraph = [[BEMSimpleLineGraphView alloc]initWithFrame:CGRectMake(0, 280, 320, 200)];
        self.myGraph.enableTouchReport = YES;
        self.myGraph.colorTop = [UIColor lightGrayColor];//[UIColor colorWithRed:0.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0];;
        self.myGraph.colorBottom = [UIColor colorWithRed:0.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0];;
        self.myGraph.colorLine = [UIColor whiteColor];
        self.myGraph.colorXaxisLabel = [UIColor whiteColor];
        self.myGraph.widthLine = 3.0;
        self.myGraph.enableTouchReport = NO;
        self.myGraph.enableBezierCurve = YES;
        self.myGraph.delegate = self;
        [self.view addSubview:self.myGraph];
        NSLog(@"end load graph");
        
        UITextField *txtMonth = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-10, 60, 10)];
        txtMonth.font = [UIFont boldSystemFontOfSize:10];
        txtMonth.textColor = [UIColor whiteColor];
        txtMonth.text = @"avg 1 month";
        [self.view addSubview:txtMonth];
    });
}

-(void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.ArrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.ArrayOfValues objectAtIndex:index] floatValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 1;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    return [self.ArrayOfDates objectAtIndex:index];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    //    self.labelValues.text = [NSString stringWithFormat:@"%@", [self.ArrayOfValues objectAtIndex:index]];
    //    self.labelDates.text = [NSString stringWithFormat:@"in %@", [self.ArrayOfDates objectAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        //        self.labelValues.alpha = 0.0;
//        //        self.labelDates.alpha = 0.0;
//    } completion:^(BOOL finished){
//        //
//        //        self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
//        //        self.labelDates.text = [NSString stringWithFormat:@"between 2000 and %@", [self.ArrayOfDates lastObject]];
//        
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            //            self.labelValues.alpha = 1.0;
//            //            self.labelDates.alpha = 1.0;
//        } completion:nil];
//    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    //    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
    //    self.labelDates.text = [NSString stringWithFormat:@"between 2000 and %@", [self.ArrayOfDates lastObject]];
}


@end
