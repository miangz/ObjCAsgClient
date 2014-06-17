//
//  ViewController.m
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//
//http://download.finance.yahoo.com/d/quotes.csv?s=AAPL&f=snl1c1p2v&e=.csv

#import "ViewController.h"
#import "EditViewController.h"
#import "StocklistViewController.h"
#import "DetailViewController.h"
#import "HandleStockListViewController.h"

#import "NetworkManager.h"
#import "QNetworkAdditions.h"
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
@interface ViewController ()

@end

@implementation ViewController{
    UIAlertView *loadingView;
    int count;
    BOOL editMode;
    UIButton *doneBT;
    UIButton *reorderBT;
    UISwipeGestureRecognizer *recognizer;
    UISwipeGestureRecognizer *recognizer2;
    UITextField *stockListName;
    NSMutableData *message;
    NSTimer *t;
    
    NSString *lastRequest;
}
@synthesize uid;
@synthesize table;
@synthesize txt;
@synthesize csv;
@synthesize csvArr;
@synthesize nameArr;
@synthesize stockListNO;
@synthesize totalList;

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;
@synthesize data;


#pragma mark manage load view
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    count = 0;
    editMode = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    csv = [NSMutableArray new];
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer2];
    
    stockListName = [[UITextField alloc]initWithFrame:CGRectMake(70, 25,180, 20)];
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
    stockListName.textColor = [UIColor brownColor];
    [self.view addSubview:stockListName];
    
    UIButton *addListBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addListBT.frame = CGRectMake(230, 17, 100, 35);
    [addListBT setTitle:@"add List" forState:UIControlStateNormal];
    [addListBT addTarget:self action:@selector(addList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addListBT];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.frame.size.width, self.view.frame.size.height-84)];
    table.dataSource = self;
    table.delegate = self;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:table];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 320, 44)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    txt= [[UITextField alloc]initWithFrame:CGRectMake(55, 50, 170, 25)];
    txt.delegate = self;
    txt.backgroundColor = [UIColor lightGrayColor];
    txt.autocorrectionType = UITextAutocorrectionTypeNo;
    txt.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:txt];
    //    [txt becomeFirstResponder];
    
//    UIButton *refreshBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    refreshBT.frame = CGRectMake(10, 15, 50, 35);
//    [refreshBT setTitle:@"refresh" forState:UIControlStateNormal];
//    [refreshBT addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:refreshBT];
    
    UIButton *signOutBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signOutBT.frame = CGRectMake(5, 15, 60, 35);
    [signOutBT setTitle:@"signOut" forState:UIControlStateNormal];
    [signOutBT addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOutBT];
    
    reorderBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reorderBT.frame = CGRectMake(10, 45, 30, 35);
    [reorderBT setTitle:@"Edit" forState:UIControlStateNormal];
    [reorderBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reorderBT];
    
    doneBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBT.frame = CGRectMake(10, 45, 40, 35);
    [doneBT setTitle:@"Done" forState:UIControlStateNormal];
    [doneBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBT];
    doneBT.hidden = YES;
    
    UIButton *submitBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitBT.frame = CGRectMake(220, 45, 70, 35);
    [submitBT setTitle:@"ADD" forState:UIControlStateNormal];
    [submitBT addTarget:self action:@selector(submitted) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBT];
    
    UIButton *editBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editBT.frame = CGRectMake(290, 45, 20, 35);
    [editBT setTitle:@"..." forState:UIControlStateNormal];
    [editBT addTarget:self action:@selector(editArr) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBT];
    
}



-(void)viewDidAppear:(BOOL)animated{
    loadingView = [[UIAlertView alloc] initWithTitle:@"Loading stock list\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    [self startServer];
    count++;
    
    [self loadNewStockList];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.fileStream close];
    [self.networkStream close];
    [self stopServer:nil];
    [t invalidate];
    t = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark manage stockList
-(void)loadNewStockList{
    [t invalidate];
    t = nil;
    NSLog(@"load new data");
    csvArr = nil;
    nameArr = nil;
    
    [self sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];

    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
}

-(void)reloadStockList{
    
    [t invalidate];
    t = nil;
    
    NSLog(@"load new data");
    if (nameArr.count == 0 && nameArr == nil) {
        [self sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];
    }else{
        NSMutableString *nameStr = [[NSMutableString alloc]init];
        for (int i = 0 ; i<nameArr.count; i++) {
            if (i>0) {
                [nameStr appendString:@"+"];
            }
            [nameStr appendString:[nameArr objectAtIndex:i]];
        }
        
        [self sendMessage:[NSString stringWithFormat:@"getTheseStock:%@",nameStr]];
    }
    
    csvArr = nil;
    nameArr = nil;
    
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
    t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                       selector:@selector(reloadStockList) userInfo:nil repeats:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (count == 0) {
        return 0;
    }
    if (csvArr.count == 0) {
        return 1;
    }
    
    [loadingView dismissWithClickedButtonIndex:0 animated:YES];
    return csvArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    
    //    NSLog(@"indexPath : %d csv : %@",indexPath.row,csv);
    
    if (csvArr.count == 0 ) {
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.text = @"Don't have any stock? add new one ^";
        cell.backgroundColor = [UIColor lightGrayColor];
        
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSArray *arr = [csvArr objectAtIndex:indexPath.row] ;
    
    
    if (arr.count < 5) {
        return cell;
    }
    
    NSString *ticker = [[arr objectAtIndex:0]substringFromIndex:1];
    
    NSString *name = [[arr objectAtIndex:1]substringFromIndex:1];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[ticker substringToIndex:ticker.length-1],[name substringToIndex:name.length-1]];
    
    NSString *change = [arr objectAtIndex:4];
    if ([[arr objectAtIndex:3] floatValue]<0 || [[arr objectAtIndex:4] floatValue]<0) {
        cell.backgroundColor = [UIColor redColor];
    }else if([[arr objectAtIndex:3] floatValue]>0 || [[arr objectAtIndex:4] floatValue]>0) {
        cell.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.6 alpha:1];//[UIColor cyanColor];
    }else{
        cell.backgroundColor = [UIColor grayColor];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t%@\t%@%%\t%@",[arr objectAtIndex:2],[arr objectAtIndex:3],change,[arr objectAtIndex:5]];
    cell.detailTextLabel.textColor = [UIColor darkTextColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (csvArr.count == 0) {
        return NO;
    }
    if (indexPath.row == 0) // Don't move the first row
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSArray *myCsv = [csvArr objectAtIndex:sourceIndexPath.row];
    [csvArr removeObjectAtIndex:sourceIndexPath.row];
    [csvArr insertObject:myCsv atIndex:destinationIndexPath.row];
    
    NSString *name = [nameArr objectAtIndex:sourceIndexPath.row];
    [nameArr removeObjectAtIndex:sourceIndexPath.row];
    [nameArr insertObject:name atIndex:destinationIndexPath.row];
    
    
    NSString *string = [NSString stringWithFormat:@"moveStock:%@:%d:%d:%d",uid,stockListNO,sourceIndexPath.row,destinationIndexPath.row];

    [self sendMessage:string];
    
    [table reloadData];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editMode == NO) {
        return UITableViewCellEditingStyleNone;
    }
    // Detemine if it's in editing mode
//    if (csvArr.count == 0 )
//    {
//        return UITableViewCellEditingStyleNone;
//    }
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update data source array here, something like [array removeObjectAtIndex:indexPath.row];
        if (csvArr.count == 0) {
            return;
        }
        
        NSString *string = [NSString stringWithFormat:@"removeStock:%@:%@:%d",uid,[nameArr objectAtIndex:indexPath.row],stockListNO];
        
        [self sendMessage:string];
        
        [csvArr removeObjectAtIndex:indexPath.row];
        [nameArr removeObjectAtIndex:indexPath.row];
        [table reloadData];
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (nameArr.count<1 ) {
        return;
    }
    DetailViewController *d = [[DetailViewController alloc]init];
    NSLog(@"nameArr : %@",nameArr);
    d.csv = [csvArr objectAtIndex:indexPath.row];
    d.stockName = [nameArr objectAtIndex:indexPath.row];
    [self presentViewController:d animated:NO completion:nil];
}


#pragma mark - UIGestureRecognizerDelegate
-(void)handleSwipeFrom:(id)sender {
    int swipe = 0;// 1 = left 2 = right
//    NSArray *csvInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    if(sender == recognizer2){
        if (stockListNO<totalList-1) {
            stockListNO++;
            swipe = 1;
        }
    }else if(sender == recognizer){
        if (stockListNO>0) {
            stockListNO--;
            swipe = 2;
        }
    }
    [txt resignFirstResponder];
    if (swipe>0) {
        csvArr = nil;
        nameArr = nil;
       [self sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];
       
        csv = [NSMutableArray new];
        
        stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
        if (swipe == 1) {
            [self leftReload];
        }else{
            [self rightReload];
        }
    }
}

-(void)submitted{
    loadingView = [[UIAlertView alloc] initWithTitle:@"Loading stock list\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    if ([nameArr containsObject:txt.text]) {
//        NSLog(@"\nnameArr : %@\ncsvArr : %@\nstockNO : %d\ntotalNO : %d",nameArr,csvArr,stockListNO,totalList);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"This stock is already in your list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil ];
        [alert show];
    }
    
//    NSLog(@"nameArr : %@",nameArr);
    NSString *name = [NSString stringWithFormat:@"modifyStock:%@:%@:%d",uid,txt.text,stockListNO];
//    NSLog(@"name: %@",name);
    [self sendMessage:name];
}

-(void)editArr{
//    StocklistViewController *s = [[StocklistViewController alloc]init];
    HandleStockListViewController *s = [[HandleStockListViewController alloc]init];
    s.uid = uid;
    s.stockListNO = stockListNO;
    [self presentViewController:s animated:NO completion:nil];
}

-(void)reorder{
    if (csvArr.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Don't have stock to edit!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (editMode == YES) {
        [self loadNewStockList];
        editMode = NO;
        table.editing = NO;
        doneBT.hidden = YES;
        reorderBT.hidden = NO;
    }else{
        editMode = YES;
        table.editing = YES;
        doneBT.hidden = NO;
        reorderBT.hidden = YES;
    }
}

-(void)addList{
    csvArr = nil;
    nameArr = nil;
    
    csvArr = [[NSMutableArray alloc]init];
    nameArr = [[NSMutableArray alloc]init];
    stockListNO = totalList;
    [table reloadData];
    [self sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,totalList]];
    totalList++;
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
}

-(void)signOut{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    LogInViewController *lView = [[LogInViewController alloc]init];
    [self presentViewController:lView animated:NO completion:nil];
}

#pragma yahoo
-(void)refreshData{
    if (nameArr.count == 0 ) {
        return;
    }
    
    NSLog(@"start refresh");
    NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *str = [NSMutableString stringWithFormat:@"http://download.finance.yahoo.com/d/quotes.csv?s=%@",[nameArr objectAtIndex:0]];
        for (int i = 1 ; i<nameArr.count; i++) {
            [str appendString:[NSString stringWithFormat:@"+%@",[nameArr objectAtIndex:i]]];
        }
        
        [str appendString:@"&f=snl1c1p2v&e=.csv"];
        
        nameArr = nil;
        csvArr = nil;
        nameArr = [[NSMutableArray alloc]init];
        csvArr = [[NSMutableArray alloc]init];
        
        NSURL *url = [NSURL URLWithString:str];
        NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
        
        NSArray *reply2 = [reply componentsSeparatedByString:@"\n"];
        
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0 ; i<reply2.count; i++) {
            NSArray *a = [[reply2 objectAtIndex:i] componentsSeparatedByString:@","];
            if (a.count>2) {
                [array addObject:a];
                NSString *name = [[a objectAtIndex:0]substringFromIndex:1];
                name = [name substringToIndex:name.length-1];
                [nameArr addObject:name];
            }
        }
        
        
        csvArr = [[NSMutableArray alloc]initWithArray:array];
        
        txt.text = @"";
        if (csvInit.count==0) {
            [csvInit addObject:csvArr];
            [nameInit addObject:nameArr];
        }else{
            [csvInit replaceObjectAtIndex:stockListNO withObject:csvArr];
            [nameInit replaceObjectAtIndex:stockListNO withObject:nameArr];
        }
        [table reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
        [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"finish refresh");
    });
}
#pragma mark - NSStreamDelegate
-(void)retrieveData:(NSURL *)url{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //CSV from URL http://stackoverflow.com/questions/2465689/how-do-i-use-a-csv-file-received-from-a-url-query-in-objective-c
        NSString *reply = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
        csv = [reply componentsSeparatedByString:@","];
        
        //not found
        if (csv.count == 1 || [[csv objectAtIndex:2]intValue]==0) {
            return;
        }
        
        NSString *name = [[csv objectAtIndex:0]substringFromIndex:1];
        name = [name substringToIndex:name.length-1];
        if (![nameArr containsObject:name] ) {
            [nameArr insertObject:name atIndex:0];
            [csvArr insertObject:csv atIndex:0];
            [table reloadData];
            
            NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
            NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
            if (csvInit.count==0) {
                [csvInit addObject:csvArr];
                [nameInit addObject:nameArr];
            }else{
                [csvInit replaceObjectAtIndex:stockListNO withObject:csvArr];
                [nameInit replaceObjectAtIndex:stockListNO withObject:nameArr];
            }
            [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
            [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.txt.text = @"";
        }
    });
}

- (void)sendMessage:(NSString *)string{
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self.networkStream close];
    }
    
    [self initNetworkCommunication];
    
    //    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@" , string);
    lastRequest = [[NSString alloc]initWithString:string];
	data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
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
    
//    static int c = 0;
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            
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
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning!!" message:@"stock not found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alert show];
                                message = nil;
                            }else if(lastRequest !=nil){
                                NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                                if (rng.length > 0)
                                    [self sendMessage:lastRequest];
                                message = nil;
                            }
                        }else{
                            NSLog(@"array : %@",array);
                            if (nameArr == nil) {
                                nameArr = [[NSMutableArray alloc]init];
                            }
                            if (csvArr == nil) {
                                csvArr = [[NSMutableArray alloc]init];
                            }
                           
                            
                            NSString *str = [array firstObject];
                            if ([str isEqualToString:@"getStockInfoOfUid"]) {
                                
                                [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                                NSLog(@"getStockInfoOfUid");
                                totalList = [[array lastObject]intValue];
                                [nameArr removeAllObjects];
                                [csvArr removeAllObjects];
                                for (int i = 1; i < array.count-1 ; i++) {
                                    NSRange r = NSMakeRange(1, [[[array objectAtIndex:i] objectAtIndex:0]length]-2);
                                    NSString *nameStock = [[[array objectAtIndex:i] objectAtIndex:0]substringWithRange:r];
                                    if (![nameArr containsObject:[[array objectAtIndex:i] objectAtIndex:0]]) {
                                        [nameArr insertObject:nameStock atIndex:0];
                                        [csvArr insertObject:[array objectAtIndex:i] atIndex:0];
                                    }
                                }
                                
                            }else if ([str isEqualToString:@"getTheseStock"]) {
                                [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                                NSLog(@"getStockInfoOfUid");
                                [nameArr removeAllObjects];
                                [csvArr removeAllObjects];
                                for (int i = 1; i < array.count ; i++) {
                                    NSRange r = NSMakeRange(1, [[[array objectAtIndex:i] objectAtIndex:0]length]-2);
                                    NSString *nameStock = [[[array objectAtIndex:i] objectAtIndex:0]substringWithRange:r];
                                    if (![nameArr containsObject:[[array objectAtIndex:i] objectAtIndex:0]]) {
                                        [nameArr insertObject:nameStock atIndex:0];
                                        [csvArr insertObject:[array objectAtIndex:i] atIndex:0];
                                    }
                                }
                                
                            }
                            else{//modifyStock
                                NSLog(@"else");
                                NSArray *a = [array objectAtIndex:1];
                                if(a.count>1 && ((int)[[a objectAtIndex:0]length])-2 > 0){
                                    NSRange r = NSMakeRange(1, [[a objectAtIndex:0]length]-2);
                                    NSString *nameStock = [[a objectAtIndex:0]substringWithRange:r];
                                    if (![nameArr containsObject:nameStock]) {
                                        [nameArr insertObject:txt.text atIndex:0];
                                        [csvArr insertObject:a atIndex:0];
                                    }
                                }
                            }
                            
                            [table reloadData];
                            
                            [t invalidate];
                            t = nil;
                            t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                                           selector:@selector(reloadStockList) userInfo:nil repeats:NO];
                            
                            message = nil;
                        }
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
    
    
//    [self.fileStream open];
    
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
    
    ViewController  *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge ViewController *) info;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == txt) {
        [self submitted];
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [txt resignFirstResponder];
}


- (void)rightReload
{
    [table reloadData];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [[table layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    
    
}
- (void)leftReload
{
    [table reloadData];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [[table layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    
    
}
@end
