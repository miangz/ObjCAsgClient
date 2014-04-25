//
//  ViewController.h
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>



@property NSArray *csv;
@property UITableView *table;
@property UITextField *txt;
@property NSMutableArray *csvArr;
@property NSMutableArray *nameArr;
@property int stockListNO;

-(void)retrieveData:(NSURL *)url;

@end
