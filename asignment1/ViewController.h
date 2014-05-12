//
//  ViewController.h
//  ProfilerClock
//
//  Created by miang on 4/4/14.
//  Copyright (c) 2014 miang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,NSStreamDelegate>


@property NSString *uid;
@property NSArray *csv;
@property UITableView *table;
@property UITextField *txt;
@property NSMutableArray *csvArr;
@property NSMutableArray *nameArr;
@property int stockListNO;


@property (nonatomic, assign, readonly ) BOOL               isSending;
@property (nonatomic, strong, readwrite) NSOutputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, assign, readonly ) uint8_t *          buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;
@property (copy) NSData  *data ;

- (void) sendMessage:(NSString *)string;
-(void)retrieveData:(NSURL *)url;

@end
