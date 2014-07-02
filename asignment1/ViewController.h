//
//  ViewController.h
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInViewController.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property NSString *uid;
@property int stockListNO;

@end
