//
//  NSStreamManager.h
//  asignment1
//
//  Created by miang on 7/1/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStreamManager : NSObject<NSStreamDelegate,NSNetServiceDelegate>

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

@property NSString *lastRequest;
@property NSMutableData *message;
@property (copy) NSData  *data ;
- (void) sendMessage:(NSString *)string;
- (void) resendLastMessage;
- (void)startServer;
- (void) stopServer:(NSString *)reason;

+ (id)sharedManager;

@end
