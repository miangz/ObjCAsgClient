//
//  LogInViewController.h
//  asignment1
//
//  Created by miang on 5/6/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,NSStreamDelegate>

@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property (copy) NSData  *data ;

- (void) sendMessage:(NSString *)string;

-(void)retrieveData:(NSURL *)url;
@end
