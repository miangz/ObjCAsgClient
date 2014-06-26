//
//  SignUpViewController.m
//  asignment1
//
//  Created by miang on 5/7/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkManager.h"
#import "QNetworkAdditions.h"

#import "NetworkManager.h"

#include <CFNetwork/CFNetwork.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#define kOFFSET_FOR_KEYBOARD 150.0

@interface SignUpViewController ()

@end

@implementation SignUpViewController{
    UITextField *fname;
    UITextField *lname;
    UITextField *username;
    UITextField *password;
    UITextField *rePassword;
    
    NSMutableData *message;
    UIAlertView *loadingView;
    
    NSString *lastRequest;
}

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

@synthesize data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.8 alpha:1];
    
    
    UITapGestureRecognizer *yourTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTap:)];
    [self.view addGestureRecognizer:yourTap];
    
    
    UIButton *backBT = [[UIButton alloc]initWithFrame:CGRectMake(20, 25, 60, 20)];
    [backBT setTitle:@"<Back" forState:UIControlStateNormal];
    [backBT setTitle:@"<Back" forState:UIControlStateSelected];
    [backBT setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [backBT setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backBT addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBT];
    
    UIView *whiteLine = [[UIView alloc]initWithFrame:CGRectMake(10, 49, 300, 2)];
    whiteLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:whiteLine];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 50, 256, 35)];
    label.text = @"Create an account";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:30];
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 100, 256, 35)];
    label1.text = @"Name";
    label1.textColor = [UIColor whiteColor];
    [self.view addSubview:label1];
    
    fname = [[UITextField alloc]initWithFrame:CGRectMake(30, 130, 200, 30)];
    fname.backgroundColor = [UIColor whiteColor];
    fname.placeholder = @"  First";
    [[fname layer] setBorderWidth:1.2f];
    [[fname layer] setBorderColor:[UIColor grayColor].CGColor];
    [[fname layer]setCornerRadius:4];
    fname.delegate = self;
    fname.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:fname];
    
    lname = [[UITextField alloc]initWithFrame:CGRectMake(30, 165, 200, 30)];
    lname.backgroundColor = [UIColor whiteColor];
    lname.placeholder = @"  Last";
    [[lname layer] setBorderWidth:1.2f];
    [[lname layer] setBorderColor:[UIColor grayColor].CGColor];
    [[lname layer]setCornerRadius:4];
    lname.delegate = self;
    lname.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:lname];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(30, 200, 256, 35)];
    label2.text = @"User name";
    label2.textColor = [UIColor whiteColor];
    [self.view addSubview:label2];
    
    username = [[UITextField alloc]initWithFrame:CGRectMake(30, 230, 200, 30)];
    username.backgroundColor = [UIColor whiteColor];
    [[username layer] setBorderWidth:1.2f];
    [[username layer] setBorderColor:[UIColor grayColor].CGColor];
    [[username layer]setCornerRadius:4];
    username.delegate = self;
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:username];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(30, 265, 256, 35)];
    label3.text = @"Create password";
    label3.textColor = [UIColor whiteColor];
    [self.view addSubview:label3];
    
    password = [[UITextField alloc]initWithFrame:CGRectMake(30, 295, 200, 30)];
    password.backgroundColor = [UIColor whiteColor];
    password.secureTextEntry = YES;
    [[password layer] setBorderWidth:1.2f];
    [[password layer] setBorderColor:[UIColor grayColor].CGColor];
    [[password layer]setCornerRadius:4];
    password.delegate = self;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:password];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(30, 320, 256, 35)];
    label4.text = @"Reenter password";
    label4.textColor = [UIColor whiteColor];
    [self.view addSubview:label4];
    
    rePassword = [[UITextField alloc]initWithFrame:CGRectMake(30, 350, 200, 30)];
    rePassword.backgroundColor = [UIColor whiteColor];
    rePassword.secureTextEntry = YES;
    [[rePassword layer] setBorderWidth:1.2f];
    [[rePassword layer] setBorderColor:[UIColor grayColor].CGColor];
    [[rePassword layer]setCornerRadius:4];
    rePassword.delegate = self;
    rePassword.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:rePassword];
    
    UIButton *createBT = [[UIButton alloc]initWithFrame:CGRectMake(30, 400, 150, 30)];
    createBT.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.6 alpha:1];
    [createBT setTitle:@"Create Account" forState:UIControlStateNormal];
    [createBT setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [createBT setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [createBT addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:createBT];
}
-(void)viewDidAppear:(BOOL)animated{
    [self startServer];
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.fileStream close];
    [self.networkStream close];
    [self stopServer:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) close {
    if([NSThread isMainThread]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self performSelectorOnMainThread:@selector(close)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

//handle kb
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if (sender.frame.origin.y<200) {
        if  (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
        return;
    }
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    
}
- (void)scrollTap:(UIGestureRecognizer*)gestureRecognizer {
    
    [fname resignFirstResponder];
    [lname resignFirstResponder];
    [username resignFirstResponder];
    [password resignFirstResponder];
    [rePassword resignFirstResponder];
    if (self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}
//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        NSLog(@"movedUp");
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        NSLog(@"movedDown");
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
-(void)createAccount{
    
    if (fname.text.length < 1 || lname.text.length < 1 || username.text.length < 1 ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!!" message:@"Please enter all of informations." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (password.text.length < 3) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!!" message:@"Passwords must have at least 4 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (![password.text isEqualToString:rePassword.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!!" message:@"The passwords don't match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSString *msg = [NSString stringWithFormat:@"createAnAccount:%@\t%@\t%@\t%@",fname.text,lname.text,username.text,password.text];
    [self sendMessage:msg];
}


#pragma mark - NSStreamDelegate
- (void)sendMessage:(NSString *)string{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    loadingView = [[UIAlertView alloc] initWithTitle:@"Creating an account\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    
    
        
    if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
        [self closeOutputStream];
    }
    
    [self initNetworkCommunication];
    
    //    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@" , string);
    lastRequest = nil;
    lastRequest = [[NSString alloc]initWithString:string];
	data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
	[self.networkStream write:[data bytes] maxLength:[data length]];
    });
}

- (void) initNetworkCommunication {
    NSOutputStream *    output;
    BOOL                success;
    NSNetService *      netService;
    
    netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSUpload._tcp." name:@"Test"];
    assert(netService != nil);
    
    
    success = [netService qNetworkAdditions_getInputStream:NULL outputStream:&output];
    assert(success);
    
    self.networkStream = output;
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.networkStream open];
    
    // Tell the UI we're sending.
    
    [self sendDidStart];
    
}
- (void) closeOutputStream{
    //Close and reset outputstream
    [self.networkStream setDelegate:nil];
    [self.networkStream close];
    [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.networkStream = nil;
}
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
	//NSLog(@"stream event %i", eventCode);
    
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable");
            
            [loadingView dismissWithClickedButtonIndex:0 animated:YES];
            message = nil;
            
			if (aStream == self.fileStream) {
                
                uint8_t buffer[5000];
				int len;
				
				while ([self.fileStream hasBytesAvailable]) {
					len = [self.fileStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        NSData *d = [[NSData alloc]initWithBytes:buffer length:len];
                        if (output != nil) {
                            if (message == nil) {
                                message = [NSMutableData new];
                            }
                            [message appendData:d];
                        }
					}
				}
                
                if (message != nil) {
                    
                    NSString *str = [[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding];
                    NSLog(@"string : %@",str);
                    NSRange rng = [str rangeOfString:@"Added successfully.\n" options:0];
                    if (rng.length > 0) {
                        NSLog(@"added");
                        [self close];
                    }else if(lastRequest !=nil){
                        NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                        if (rng.length > 0)
                            [self sendMessage:lastRequest];
                    }else{
                        NSRange rng = [str rangeOfString:@"Someone already has that username. Try another!" options:0];
                        if (rng.length > 0) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!" message:@"Someone already has that username. Try another!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    
                }else{
                    NSLog(@"message == nil");
                }
			}else{
                NSLog(@"not self.filestream");
            }
			break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
		default:
            break;
            
	}
}


#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Send succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        self.networkStream.delegate = nil;
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    self.bufferOffset = 0;
    self.bufferLimit  = 0;
    [self sendDidStopWithStatus:statusString];
}
//Server Receive
- (void)serverDidStartOnPort:(NSUInteger)port
{
    assert( (port != 0) && (port < 65536) );
    NSLog(@"%@", [NSString stringWithFormat:@"Started on port %zu", (size_t) port]);
}
- (void)serverDidStopWithReason:(NSString *)reason
{
    if (reason == nil) {
        reason = @"Stopped";
    }
}
- (void)receiveDidStart
{
    NSLog( @"Receiving" );
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}
- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Receive succeeded";
    }
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}


- (void)startReceive:(int)fd
{
    CFReadStreamRef     readStream;
    
    assert(fd >= 0);
    
    
    [self.fileStream open];
    
    // Open a stream based on the existing socket file descriptor.  Then configure
    // the stream for async operation.
    
    CFStreamCreatePairWithSocket(NULL, fd, &readStream, NULL);
    assert(readStream != NULL);
    
    self.fileStream = (__bridge NSInputStream *) readStream;
    
    CFRelease(readStream);
    
    [self.fileStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    self.fileStream.delegate = self;
    [self.fileStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.fileStream open];
    
    // Tell the UI we're receiving.
    
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
{
    if (self.fileStream != nil) {
        self.fileStream.delegate = nil;
        [self.fileStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.fileStream close];
        self.fileStream = nil;
    }
    if (self.networkStream != nil) {
        [self.networkStream close];
        self.networkStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
}


- (BOOL)isStarted
{
    return (self.netService != nil);
}

- (BOOL)isReceiving
{
    return (self.fileStream != nil);
}
- (void)acceptConnection:(int)fd
{
    [self startReceive:fd];
}

static void AcceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
// Called by CFSocket when someone connects to our listening socket.
// This implementation just bounces the request up to Objective-C.
{
    NSLog(@"AcceptCallback");
    
    SignUpViewController  *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge SignUpViewController *) info;
    assert(obj != nil);
    
    assert(s == obj->_listeningSocket);
#pragma unused(s)
    
    [obj acceptConnection:*(int *)data];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
// A NSNetService delegate callback that's called if our Bonjour registration
// fails.  We respond by shutting down the server.
//
// This is another of the big simplifying assumptions in this sample.
// A real server would use the real name of the device for registrations,
// and handle automatically renaming the service on conflicts.  A real
// client would allow the user to browse for services.  To simplify things
// we just hard-wire the service name in the client and, in the server, fail
// if there's a service name conflict.
{
#pragma unused(sender)
    assert(sender == self.netService);
#pragma unused(errorDict)
    
    [self stopServer:@"Registration failed"];
}

- (void)startServer
{
    BOOL                success;
    int                 err;
    int                 fd;
    int                 junk;
    struct sockaddr_in  addr;
    NSUInteger          port;
    
    // Create a listening socket and use CFSocket to integrate it into our
    // runloop.  We bind to port 0, which causes the kernel to give us
    // any free port, then use getsockname to find out what port number we
    // actually got.
    
    port = 0;
    
    fd = socket(AF_INET, SOCK_STREAM, 0);
    success = (fd != -1);
    
    if (success) {
        memset(&addr, 0, sizeof(addr));
        addr.sin_len    = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port   = 0;
        addr.sin_addr.s_addr = INADDR_ANY;
        err = bind(fd, (const struct sockaddr *) &addr, sizeof(addr));
        success = (err == 0);
    }
    if (success) {
        err = listen(fd, 5);
        success = (err == 0);
    }
    if (success) {
        socklen_t   addrLen;
        
        addrLen = sizeof(addr);
        err = getsockname(fd, (struct sockaddr *) &addr, &addrLen);
        success = (err == 0);
        
        if (success) {
            assert(addrLen == sizeof(addr));
            port = ntohs(addr.sin_port);
        }
    }
    if (success) {
        CFSocketContext context = { 0, (__bridge void *) self, NULL, NULL, NULL };
        
        assert(self->_listeningSocket == NULL);
        self->_listeningSocket = CFSocketCreateWithNative(
                                                          NULL,
                                                          fd,
                                                          kCFSocketAcceptCallBack,
                                                          AcceptCallback,
                                                          &context
                                                          );
        success = (self->_listeningSocket != NULL);
        
        if (success) {
            CFRunLoopSourceRef  rls;
            
            fd = -1;        // listeningSocket is now responsible for closing fd
            
            rls = CFSocketCreateRunLoopSource(NULL, self.listeningSocket, 0);
            assert(rls != NULL);
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
            
            CFRelease(rls);
        }
    }
    
    // Now register our service with Bonjour.  See the comments in -netService:didNotPublish:
    // for more info about this simplifying assumption.
    
    if (success) {
        self.netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_x-SNSDownload._tcp." name:@"Test" port:port];
        success = (self.netService != nil);
    }
    if (success) {
        self.netService.delegate = self;
        
        [self.netService publishWithOptions:NSNetServiceNoAutoRename];
        
        // continues in -netServiceDidPublish: or -netService:didNotPublish: ...
    }
    
    // Clean up after failure.
    
    if ( success ) {
        assert(port != 0);
        [self serverDidStartOnPort:port];
    } else {
        [self stopServer:@"Start failed"];
        if (fd != -1) {
            junk = close(fd);
            assert(junk == 0);
        }
    }
}

- (void)stopServer:(NSString *)reason
{
    if (self.isReceiving) {
        [self stopReceiveWithStatus:@"Cancelled"];
    }
    if (self.netService != nil) {
        [self.netService stop];
        self.netService = nil;
    }
    if (self.listeningSocket != NULL) {
        CFSocketInvalidate(self.listeningSocket);
        CFRelease(self->_listeningSocket);
        self->_listeningSocket = NULL;
    }
    [self serverDidStopWithReason:reason];
}


@end
