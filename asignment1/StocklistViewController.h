//
//  StocklistViewController.h
//  asignment1
//
//  Created by miang on 4/16/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StocklistViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property UITableView *table;
@property NSString *uid;
@end