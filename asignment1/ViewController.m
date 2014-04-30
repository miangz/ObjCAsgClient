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

@interface ViewController ()

@end

@implementation ViewController{
    int count;
    BOOL editMode;
    UIButton *doneBT;
    UIButton *reorderBT;
    UISwipeGestureRecognizer *recognizer;
    UISwipeGestureRecognizer *recognizer2;
    UITextField *stockListName;
    NSMutableData *message;
}

@synthesize table;
@synthesize txt;
@synthesize csv;
@synthesize csvArr;
@synthesize nameArr;
@synthesize stockListNO;

@synthesize outputStream;
@synthesize inputStream;
@synthesize data;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    count = 0;
    editMode = NO;
    
    
    NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    if (csvInit.count == 0) {
        csvArr = [[NSMutableArray alloc]init];
        nameArr = [[NSMutableArray alloc]init];
    }else{
        csvArr = [[NSMutableArray alloc]initWithArray:[csvInit objectAtIndex:stockListNO]];
        nameArr = [[NSMutableArray alloc]initWithArray:[nameInit objectAtIndex:stockListNO]];
    }
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
    
    UIButton *refreshBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    refreshBT.frame = CGRectMake(10, 15, 50, 35);
    [refreshBT setTitle:@"refresh" forState:UIControlStateNormal];
    [refreshBT addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBT];
    
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
    if (count>0) {
        [self loadNewStockList];
    }
    count++;
}

-(void)viewDidDisappear:(BOOL)animated{
    [outputStream close];
    [inputStream close];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadNewStockList{
    csvArr = nil;
    nameArr = nil;
    NSArray *csvInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSArray *nameInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    if (csvInit.count == 0) {
        csvArr = [[NSMutableArray alloc]init];
        nameArr = [[NSMutableArray alloc]init];
    }else{
        csvArr = [[NSMutableArray alloc]initWithArray:[csvInit objectAtIndex:stockListNO]];
        nameArr = [[NSMutableArray alloc]initWithArray:[nameInit objectAtIndex:stockListNO]];
    }
    csv = [NSMutableArray new];
    
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
    
    [table  reloadData];
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
    
    
    return csvArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //    NSLog(@"indexPath : %d csv : %@",indexPath.row,csv);
    
    if (csvArr.count == 0 ) {
        return cell;
    }
    
    NSArray *arr = [csvArr objectAtIndex:indexPath.row] ;
    
    
    if (arr.count < 5) {
        return cell;
    }
    
    NSString *ticker = [[arr objectAtIndex:0]substringFromIndex:1];
    
    NSString *name = [[arr objectAtIndex:1]substringFromIndex:1];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[ticker substringToIndex:ticker.length-1],[name substringToIndex:name.length-1]];
    
    NSString *change = [[arr objectAtIndex:4]substringFromIndex:1];
    change = [change substringToIndex:change.length-2];
    if ([change floatValue]<0) {
        cell.backgroundColor = [UIColor redColor];
    }else if([change floatValue]>0) {
        cell.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.6 alpha:1];//[UIColor cyanColor];
    }else{
        cell.backgroundColor = [UIColor grayColor];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t%@\t%@%%\t%@",[arr objectAtIndex:2],[arr objectAtIndex:3],change,[arr objectAtIndex:5]];
    cell.detailTextLabel.textColor = [UIColor darkTextColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update data source array here, something like [array removeObjectAtIndex:indexPath.row];
        
        
        NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
        NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
        
        [csvArr removeObjectAtIndex:indexPath.row];
        [nameArr removeObjectAtIndex:indexPath.row];
        
        [csvInit replaceObjectAtIndex:stockListNO withObject:csvArr];
        [nameInit replaceObjectAtIndex:stockListNO withObject:nameArr];
        [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
        [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailViewController *d = [[DetailViewController alloc]init];
    NSLog(@"nameArr : %@",nameArr);
    d.stockName = [nameArr objectAtIndex:indexPath.row];
    [self presentViewController:d animated:NO completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
-(void)handleSwipeFrom:(id)sender {
    int swipe = 0;// 1 = left 2 = right
    NSArray *csvInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    if(sender == recognizer2){
        if (stockListNO<csvInit.count-1) {
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
        NSArray *csvInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
        NSArray *nameInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
        if (csvInit.count == 0) {
            csvArr = [[NSMutableArray alloc]init];
            nameArr = [[NSMutableArray alloc]init];
        }else{
            csvArr = [[NSMutableArray alloc]initWithArray:[csvInit objectAtIndex:stockListNO]];
            nameArr = [[NSMutableArray alloc]initWithArray:[nameInit objectAtIndex:stockListNO]];
        }
        csv = [NSMutableArray new];
        
        stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
        if (swipe == 1) {
            [self leftReload];
        }else{
            [self rightReload];
        }
    }
}



#pragma yahoo
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

#pragma mark - NSStreamDelegate
- (void)sendMessage:(NSString *)string{
    if ([inputStream streamStatus]==NSStreamStatusOpen) {
        [inputStream close];
        [outputStream close];
    }
    
    [self initNetworkCommunication];
    
    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@\n" , s);
	data = [[NSData alloc] initWithData:[s dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    
}

- (void) initNetworkCommunication {
    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 1337, &readStream, &writeStream);
	
	inputStream = (__bridge_transfer NSInputStream *)readStream;
	outputStream = (__bridge_transfer NSOutputStream *)writeStream;
	[outputStream setDelegate:self];
	[inputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    //SSL
    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                      forKey:NSStreamSocketSecurityLevelKey];
    [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                       forKey:NSStreamSocketSecurityLevelKey];
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                              [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                              kCFNull,kCFStreamSSLPeerName,
                              nil];
    
    CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    //
	[inputStream open];
	[outputStream open];
    
}
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
	//NSLog(@"stream event %i", eventCode);
    
    static int c = 0;
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            NSLog(@"RECEIVING");
            
			if (aStream == inputStream) {
                
                uint8_t buffer[5000];
				int len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
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
                            NSLog(@"string : %@",[[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding]);
                        }else{
                            NSLog(@"array :%@",array);
                        }
                        message = nil;
                    }
                }
			}
			break;
            
        case NSStreamEventHasSpaceAvailable:
            
            //            NSLog(@"NSStreamEventHasSpaceAvailable");
            if (aStream == outputStream) {
                if (c == 0) {
                    [self sendMessage:@"Hello\n"];
                    c++;
                }
                
            }
            break;
		default:
			NSLog(@"Unknown event %@,%@",aStream,inputStream);
            break;
            
	}
}

-(void)submitted{
    NSString *str = [NSString stringWithFormat:@"http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=snl1c1p2v&e=.csv",txt.text];
    NSURL *url = [NSURL URLWithString:str];
    
    [self retrieveData:url];
}

-(void)editArr{
    //    EditViewController *e = [[EditViewController alloc]init];
    //    e.stockListNO = stockListNO;
    //    e.csvArr = [[NSMutableArray alloc]initWithArray:csvArr];
    //    e.nameArr = [[NSMutableArray alloc]initWithArray:nameArr];
    //    [self presentViewController:e animated:YES completion:nil];
    StocklistViewController *s = [[StocklistViewController alloc]init];
    [self presentViewController:s animated:NO completion:nil];
}

-(void)reorder{
    if (editMode == YES) {
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
    NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    csvArr = nil;
    nameArr = nil;
    
    csvArr = [[NSMutableArray alloc]init];
    nameArr = [[NSMutableArray alloc]init];
    [csvInit addObject:csvArr];
    [nameInit addObject:nameArr];
    
    stockListNO = csvInit.count-1;
    [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
    [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [table reloadData];
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
}

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
