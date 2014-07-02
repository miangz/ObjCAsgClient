//
//  HandleStockListViewController.m
//  asignment1
//
//  Created by miang on 6/13/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//
#import "ViewController.h"
#import "HandleStockListViewController.h"
#import "NSStreamManager.h"
@interface HandleStockListViewController ()

@end

@implementation HandleStockListViewController{
    NSMutableArray *stockList;
    NSMutableArray *myIndexPath;
    int count;
    
    UITableView *table;
    UIButton *doneBT;
    UIButton *reorderBT;
}
@synthesize stockListNO;
@synthesize uid;

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
    
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    NSString *req = [NSString stringWithFormat:@"getAllStockList:%@",uid];
    [myManager sendMessage:req];
    
    myIndexPath = [[NSMutableArray alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-20)];
    table.dataSource = self;
    table.delegate = self;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:table];
    
    UIButton *deleteBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteBT.frame = CGRectMake(280, 25, 35, 35);
    [deleteBT setTitle:@"" forState:UIControlStateNormal];
    [deleteBT setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteBT addTarget:self action:@selector(removeCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBT];
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBT.frame = CGRectMake(10, 25, 70, 35);
    [backBT setTitle:@"<Back" forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
    
    reorderBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reorderBT.frame = CGRectMake(90, 25, 30, 35);
    [reorderBT setTitle:@"Edit" forState:UIControlStateNormal];
    [reorderBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reorderBT];
    
    doneBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBT.frame = CGRectMake(90, 25, 40, 35);
    [doneBT setTitle:@"Done" forState:UIControlStateNormal];
    [doneBT addTarget:self action:@selector(reorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBT];
    doneBT.hidden = YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"recievedData"
                                               object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return stockList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    NSString *str = [stockList objectAtIndex:indexPath.row];
    
    int l = 1;
    int index = indexPath.row;
    while (index>10) {
        index /=10;
        l++;
    }
    if (str.length<l+1) {
        cell.textLabel.text = @"This list is empty.";
        return cell;
    }
    str = [str substringFromIndex:l+1];
    cell.textLabel.text = [str stringByReplacingOccurrencesOfString:@"+" withString:@","];;
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    int source = sourceIndexPath.row;
    int des = destinationIndexPath.row;
    if (source == stockListNO) {
        stockListNO = destinationIndexPath.row;
    }else if(source < stockListNO && des > stockListNO){
        stockListNO--;
    }else if(source > stockListNO && des <= stockListNO){
        stockListNO++;
    }
    NSString *change = [stockList objectAtIndex:sourceIndexPath.row];
    [stockList removeObjectAtIndex:sourceIndexPath.row];
    [stockList insertObject:change atIndex:destinationIndexPath.row];
    [self reorderListFrom:sourceIndexPath to:destinationIndexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row == stockListNO) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You can't delete the viewing list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }else if(indexPath.row < stockListNO){
            stockListNO--;
        }
        NSString *string = [NSString stringWithFormat:@"removeList:%@:%d",uid,indexPath.row];
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        [myManager sendMessage:string];
        [stockList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == stockListNO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You can't delete the viewing list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if([myIndexPath containsObject: indexPath] ){
        UITableViewCell *formerSelectedcell = [tableView cellForRowAtIndexPath:indexPath];
        // finding the already selected cell
        [formerSelectedcell setAccessoryType:UITableViewCellAccessoryNone];
        [myIndexPath removeObject:indexPath];
    }else {
        // 'select' the new cell
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        if (myIndexPath.count == 0) {
            [myIndexPath addObject:indexPath];
        }
        else{
            for (int i=0;i<myIndexPath.count;i++) {
                if ([[myIndexPath objectAtIndex:i]row]>indexPath.row) {
                    [myIndexPath insertObject:indexPath atIndex:i];
                    return;
                }else if(i==myIndexPath.count-1){
                    [myIndexPath addObject:indexPath];
                    return;
                }
            }
            
            
        }
    }
    
}


#pragma mark manage button

-(void)back{
    ViewController *view = [[ViewController alloc]init];
    view.uid = uid;
    view.stockListNO = stockListNO;
    [self presentViewController:view animated:YES completion:nil];
}

-(void)reorder{
    if (table.editing == YES) {
        table.editing = NO;
        doneBT.hidden = YES;
        reorderBT.hidden = NO;
    }else{
        table.editing = YES;
        doneBT.hidden = NO;
        reorderBT.hidden = YES;
    }
}

-(void)removeCell{
    NSMutableString *string = [[NSMutableString alloc]initWithString:@"removeList:"];
    [string appendString:uid];
    [string appendString:@":"];
    for (int i=myIndexPath.count-1; i>=0; i--) {
        NSIndexPath *index = [myIndexPath objectAtIndex:i];
        [stockList removeObjectAtIndex:index.row];
        if (i != myIndexPath.count-1) {
            [string appendString:@"+"];
        }
        if (index.row < stockListNO) {
            stockListNO--;
        }
        [string appendString:[NSString stringWithFormat:@"%d",index.row]];
        if (i == 0) {
            [myIndexPath removeAllObjects];
            [table reloadData];
            NSStreamManager *myManager = [NSStreamManager sharedManager];
            [myManager sendMessage:string];
        }
    }
}

-(void)reorderListFrom:(NSIndexPath *)sourceIndexPath to:(NSIndexPath *)destinationIndexPath{
    
    NSString *string = [NSString stringWithFormat:@"reorderList:%@:%d:%d",uid,sourceIndexPath.row,destinationIndexPath.row];
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:string];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"recievedData"]){
        NSArray *array;
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        
        if (myManager.message != nil) {
            @try {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:myManager.message];
                
            }
            @catch (NSException *exception) {
                NSLog(@"TRY unarchiveObjectWithData ERROR : %@",exception);
            }
            @finally{
                if (array == nil) {
                    NSString *str = [[NSString alloc]initWithData:myManager.message encoding:NSASCIIStringEncoding];
                    NSLog(@"string : %@",str);
                    
                    if (count > 0) {
                        return;
                    }
                    
                    NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                    if (rng.length > 0){
                        [myManager resendLastMessage];
                    }
                }else{
                    NSLog(@"array : %@",array);
                    if ([[array objectAtIndex:0]isEqualToString:@"getAllStockList"]) {
                        stockList = nil;
                        stockList = [[NSMutableArray alloc]initWithArray:[array objectAtIndex:1]];
                        
                        //sort stocklist
                        NSMutableArray *sortArr = [[NSMutableArray alloc]initWithArray:stockList];
                        
                        for (int n = 0; n<sortArr.count; n++) {
                            NSString *s = [sortArr objectAtIndex:n];
                            NSArray *a = [s componentsSeparatedByString:@"+"];
                            if (n != [[a objectAtIndex:0]intValue]-1) {
                                [stockList replaceObjectAtIndex:[[a objectAtIndex:0]intValue]-1 withObject:[sortArr objectAtIndex:n]];
                            }
                        }
                        
                        [table reloadData];
                        count++;
                    }
                }
            }
        }
    }
}
@end
