//
//  SignUpViewController.h
//  asignment1
//
//  Created by miang on 5/7/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,NSStreamDelegate,NSNetServiceDelegate>


@property (nonatomic, assign, readonly ) BOOL               isStarted;
@property (nonatomic, assign, readonly ) BOOL               isReceiving;
@property (nonatomic, strong, readwrite) NSNetService *     netService;
@property (nonatomic, assign, readwrite) CFSocketRef        listeningSocket;

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
