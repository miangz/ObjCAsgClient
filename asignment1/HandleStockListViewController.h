//
//  HandleStockListViewController.h
//  asignment1
//
//  Created by miang on 6/13/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HandleStockListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property NSString *uid;
@property int stockListNO;

@end
