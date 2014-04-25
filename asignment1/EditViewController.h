//
//  EditViewController.h
//  asignment1
//
//  Created by miang on 4/10/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property UITableView *table;
@property NSMutableArray *nameArr;
@property NSMutableArray *csvArr;
@property int stockListNO;
@end
