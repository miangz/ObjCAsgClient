//
//  ViewController.h
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,NSStreamDelegate>



@property NSArray *csv;
@property UITableView *table;
@property UITextField *txt;
@property NSMutableArray *csvArr;
@property NSMutableArray *nameArr;
@property int stockListNO;

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property (copy) NSData  *data ;

- (void) sendMessage:(NSString *)string;

-(void)retrieveData:(NSURL *)url;

@end
