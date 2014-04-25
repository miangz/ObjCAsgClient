//
//  EditViewController.m
//  asignment1
//
//  Created by miang on 4/10/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "EditViewController.h"
#import "ViewController.h"
@interface EditViewController ()

@end

@implementation EditViewController{
    NSMutableArray *myIndexPath;
}
@synthesize nameArr;
@synthesize csvArr;
@synthesize table;
@synthesize stockListNO;

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
    myIndexPath = [[NSMutableArray alloc]init];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-20)];
    table.dataSource = self;
    table.delegate = self;
    table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:table];
    
    
    UIButton *deleteBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteBT.frame = CGRectMake(230, 25, 70, 35);
    [deleteBT setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBT addTarget:self action:@selector(removeCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBT];
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBT.frame = CGRectMake(20, 25, 70, 35);
    [backBT setTitle:@"back" forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return nameArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    
    
    cell.textLabel.text = [nameArr objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
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



-(void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
    
}
-(void)removeCell{
    
    for (int i=myIndexPath.count-1; i>=0; i--) {
        [nameArr removeObjectAtIndex:[[myIndexPath objectAtIndex:i]row]];
        [csvArr removeObjectAtIndex:[[myIndexPath objectAtIndex:i]row]];
        if (i == 0) {
            
            [myIndexPath removeAllObjects];
            [table reloadData];
            
            NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
            NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
            
            [csvInit replaceObjectAtIndex:stockListNO withObject:csvArr];
            [nameInit replaceObjectAtIndex:stockListNO withObject:nameArr];
            [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
            [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"csvArr : %@",csvArr);
        }
    }
}

@end
