//
//  StocklistViewController.m
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "StocklistViewController.h"

@interface StocklistViewController ()

@end

@implementation StocklistViewController{
    NSMutableArray *myIndexPath;
    UIButton *doneBT;
    UIButton *reorderBT;
}
@synthesize table;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *nameInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    return nameInit.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    
    NSArray *nameInit = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    if (indexPath.row>=nameInit.count) {
        return cell;
    }
    NSArray *nameArr = [[NSArray alloc ]initWithArray:[nameInit objectAtIndex:indexPath.row]];
    
    if (nameArr.count == 0) {
        return cell;
    }
    
    NSMutableString *str = [[NSMutableString alloc]initWithString:[nameArr objectAtIndex:0]];
    for (int i = 1; i<nameArr.count; i++) {
        [str appendString:@", "];
        [str appendString:[nameArr objectAtIndex:i]];
    }
    cell.textLabel.text = str;
    
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    
    NSArray *myCsv = [csvInit objectAtIndex:sourceIndexPath.row];
    [csvInit removeObjectAtIndex:sourceIndexPath.row];
    [csvInit insertObject:myCsv atIndex:destinationIndexPath.row];
    
    NSString *name = [nameInit objectAtIndex:sourceIndexPath.row];
    [nameInit removeObjectAtIndex:sourceIndexPath.row];
    [nameInit insertObject:name atIndex:destinationIndexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
    [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update data source array here, something like [array removeObjectAtIndex:indexPath.row];
        
        NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
        NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
        
        [csvInit removeObjectAtIndex:indexPath.row];
        [nameInit removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
        [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)back{
    [self dismissViewControllerAnimated:NO completion:nil];
    
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
    NSMutableArray *csvInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"csvArr"]];
    NSMutableArray *nameInit = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nameArr"]];
    for (int i=myIndexPath.count-1; i>=0; i--) {
        [csvInit removeObjectAtIndex:i];
        [nameInit removeObjectAtIndex:i];
        if (i == 0) {
            [myIndexPath removeAllObjects];
            [table reloadData];
            
            [[NSUserDefaults standardUserDefaults] setObject:csvInit forKey:@"csvArr"];
            [[NSUserDefaults standardUserDefaults] setObject:nameInit forKey:@"nameArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


@end
