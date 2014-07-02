//
//  ViewController.m
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//
//http://download.finance.yahoo.com/d/quotes.csv?s=AAPL&f=snl1c1p2v&e=.csv

#import "ViewController.h"
#import "DetailViewController.h"
#import "HandleStockListViewController.h"
#import "NSStreamManager.h"
@interface ViewController ()

@end

@implementation ViewController{
    
    UIAlertView *loadingView;
    UIButton *doneBT;
    UIButton *reorderBT;
    UISwipeGestureRecognizer *recognizer;
    UISwipeGestureRecognizer *recognizer2;
    UITextField *stockListName;
    UITextField *txt;
    
    NSTimer *t;
    NSArray *csv;
    UITableView *table;
    NSMutableArray *csvArr;
    NSMutableArray *nameArr;
    
    int totalList;
    int count;
    BOOL editMode;
}
@synthesize uid;
@synthesize stockListNO;

#pragma mark manage load view
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingView = [[UIAlertView alloc] initWithTitle:@"Loading stock list\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    
    count = 0;
    editMode = NO;
    csv = [NSMutableArray new];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer2];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    submitBT.frame = CGRectMake(220, 45, 60, 35);
    [submitBT setTitle:@"ADD" forState:UIControlStateNormal];
    [submitBT addTarget:self action:@selector(submitted) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBT];
    
    UIButton *editBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editBT.frame = CGRectMake(280, 50, 35, 25);
    [editBT setTitle:@"" forState:UIControlStateNormal];
    [editBT setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [editBT addTarget:self action:@selector(editArr) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBT];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"recievedData"
                                               object:nil];
    count++;
    [self loadNewStockList];
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

#pragma mark manage stockList
-(void)loadNewStockList{
    [t invalidate];
    t = nil;
    NSLog(@"load new data");
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
}

-(void)reloadStockList{
    
    [t invalidate];
    t = nil;
    if (!(self.isViewLoaded && self.view.window)) {
        return;
    }
    NSLog(@"load new data");
    if (nameArr.count == 0 && nameArr == nil) {
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        [myManager sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];
    }else{
        NSMutableString *nameStr = [[NSMutableString alloc]init];
        for (int i = 0 ; i<nameArr.count; i++) {
            if (i>0) {
                [nameStr appendString:@"+"];
            }
            [nameStr appendString:[nameArr objectAtIndex:i]];
        }
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        [myManager sendMessage:[NSString stringWithFormat:@"getTheseStock:%@",nameStr]];
    }
    
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
    t = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self
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
    [loadingView dismissWithClickedButtonIndex:0 animated:YES];
    if (count == 0) {
        return 0;
    }
    if (csvArr.count == 0) {
        return 1;
    }
    return csvArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    
    if (csvArr.count == 0 ) {
        cell.textLabel.text = @"";
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
        cell.backgroundColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.6 alpha:1];
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
    
    NSString *string = [NSString stringWithFormat:@"moveStock:%@:%d:%d:%d",uid,stockListNO,csvArr.count-sourceIndexPath.row,csvArr.count-destinationIndexPath.row];
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:string];
    
    [table reloadData];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return editMode;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (csvArr.count == 0) {
            return;
        }
        
        NSString *string = [NSString stringWithFormat:@"removeStock:%@:%@:%d",uid,[nameArr objectAtIndex:indexPath.row],stockListNO];
        
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        [myManager sendMessage:string];
        
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
    if (editMode == YES) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You have to exit edit mode before change list!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    int swipe = 0;// 1 = left 2 = right
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
        
        loadingView = [[UIAlertView alloc] initWithTitle:@"Loading stock list\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
        [loadingView show];
        
        NSStreamManager *myManager = [NSStreamManager sharedManager];
       [myManager sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,stockListNO]];
       
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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"This stock is already in your list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil ];
        [alert show];
    }
    
    NSString *modifyStock = [NSString stringWithFormat:@"modifyStock:%@:%@:%d",uid,txt.text,stockListNO];
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:modifyStock];
}

-(void)editArr{
    HandleStockListViewController *s = [[HandleStockListViewController alloc]init];
    s.uid = uid;
    s.stockListNO = stockListNO;
    [self presentViewController:s animated:NO completion:nil];
}

-(void)reorder{
    if (csvArr.count == 0 && editMode == NO) {
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
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:[NSString stringWithFormat:@"getStockInfoOfUid:%@:%d",uid,totalList]];
    totalList++;
    stockListName.text = [NSString stringWithFormat:@"<< Stock List %d >>" , stockListNO+1];
}

-(void)signOut{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    LogInViewController *lView = [[LogInViewController alloc]init];
    [self presentViewController:lView animated:NO completion:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"recievedData"]){
        
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        NSData *message = myManager.message;
        NSString *lastRequest = myManager.lastRequest;
        NSArray *array;
        if (message != nil) {
            @try {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:message];
            }
            @catch (NSException *exception) {
                NSLog(@"ERROR : %@",exception);
            }
            @finally{
                if (array == nil) {//string
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
                            [myManager resendLastMessage];
                        message = nil;
                    }else{
                        if (lastRequest != nil) {
                            [myManager resendLastMessage];
                        }
                    }
                }else{//array
                    NSLog(@"array : %@",array);
                    if (nameArr == nil) {
                        nameArr = [[NSMutableArray alloc]init];
                    }
                    if (csvArr == nil) {
                        csvArr = [[NSMutableArray alloc]init];
                    }
                    
                    
                    NSString *str = [array firstObject];
                    if ([str length]>=17 && [[str substringToIndex:17] isEqualToString:@"getStockInfoOfUid"]) {
                        NSString *s = [str substringFromIndex:18];
                        if ([s intValue] != stockListNO) {
                            return;
                        }
                        
                        NSLog(@"*******************************");
                        NSLog(@"start update new stock list");
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
                        NSLog(@"finished update new stock list");
                        
                    }else if ([str isEqualToString:@"getTheseStock"]) {
                        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                        NSLog(@"getTheseStock");
                        NSMutableArray *checkArr = [[NSMutableArray alloc]init];
                        for (int i = 1; i < array.count ; i++) {
                            NSRange r = NSMakeRange(1, [[[array objectAtIndex:i] objectAtIndex:0]length]-2);
                            NSString *nameStock = [[[array objectAtIndex:i] objectAtIndex:0]substringWithRange:r];
                            if (![checkArr containsObject:[[array objectAtIndex:i] objectAtIndex:0]]) {
                                [checkArr insertObject:nameStock atIndex:0];
                            }
                        }
                        if ([checkArr isEqualToArray:nameArr]) {
                            [csvArr removeAllObjects];
                            for (int i = 1; i < array.count ; i++) {
                                if (![nameArr containsObject:[[array objectAtIndex:i] objectAtIndex:0]]) {
                                    [csvArr insertObject:[array objectAtIndex:i] atIndex:0];
                                }
                            }
                        }
                    }else{//modifyStock
                        NSLog(@"else");
                        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
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
                    if (editMode == NO) {
                        [table reloadData];
                        NSLog(@"update");
                    }
                    
                    [t invalidate];
                    t = nil;
                    t = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self
                                                       selector:@selector(reloadStockList) userInfo:nil repeats:NO];
                    
                    myManager.message = nil;
                }
            }
        }
    }
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
