//
//  LogInViewController.m
//  asignment1
//
//  Created by miang on 5/6/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "LogInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SignUpViewController.h"
#import "ViewController.h"

#import "NetworkManager.h"
#import "QNetworkAdditions.h"
#import "NetworkManager.h"
#include <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#define kOFFSET_FOR_KEYBOARD 80.0

@interface LogInViewController ()

@end

@implementation LogInViewController{
    
    UIButton *checkbox;
    BOOL checkBoxSelected;
    UITextField *username;
    UITextField *password;
    
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
    UITapGestureRecognizer *yourTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTap:)];
    [self.view addGestureRecognizer:yourTap];
    
    //Miang-Stock
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.6 alpha:1];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(32, 100, 256, 40)];
    label.text = @"Miang-Stock";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:35];
    [self.view addSubview:label];
    
    username = [[UITextField alloc]initWithFrame:CGRectMake(30, 180, 260, 30)];
    username.backgroundColor = [UIColor whiteColor];
    username.placeholder = @"  username";
    [[username layer] setBorderWidth:1.2f];
    [[username layer] setBorderColor:[UIColor grayColor].CGColor];
    [[username layer]setCornerRadius:4];
    username.delegate = self;
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:username];
    
    password = [[UITextField alloc]initWithFrame:CGRectMake(30, 220, 260, 30)];
    password.backgroundColor = [UIColor whiteColor];
    password.placeholder = @"  password";
    password.secureTextEntry = YES;
    [[password layer] setBorderWidth:1.2f];
    [[password layer] setBorderColor:[UIColor grayColor].CGColor];
    [[password layer]setCornerRadius:4];
    password.delegate =self;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:password];
    
    //checkbox
    checkbox = [[UIButton alloc] initWithFrame:CGRectMake(35,265,20,20)];
    
    checkBoxSelected = YES;
    [checkbox setSelected:checkBoxSelected];
    [[checkbox layer] setBorderWidth:1.5f];
    [[checkbox layer] setBorderColor:[UIColor grayColor].CGColor];
    
                [checkbox setBackgroundImage:[UIImage imageNamed:@"unchecked.jpg"]
                                    forState:UIControlStateNormal];
                [checkbox setBackgroundImage:[UIImage imageNamed:@"checked.jpg"]
                                    forState:UIControlStateSelected];
                [checkbox setBackgroundImage:[UIImage imageNamed:@"checked.jpg"]
                                    forState:UIControlStateHighlighted];
                checkbox.adjustsImageWhenHighlighted=YES;
    [checkbox addTarget:self action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkbox];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(70, 265, 150, 20)];
    label1.text = @"Keep me signed in";
    label1.textColor = [UIColor whiteColor];
    [self.view addSubview:label1];
    
    UIButton *signInBT = [[UIButton alloc]initWithFrame:CGRectMake(30, 300, 100, 30)];
    signInBT.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.5 alpha:1];
    [signInBT setTitle:@"Sign in" forState:UIControlStateNormal];
    [signInBT setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [signInBT setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [signInBT addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:signInBT];
    
//    UIButton *forgotBT = [[UIButton alloc]initWithFrame:CGRectMake(30, 360, 148, 30)];
//    [forgotBT setTitle:@"Forgot password?" forState:UIControlStateNormal];
//    [forgotBT setTitle:@"Forgot password?" forState:UIControlStateSelected];
//    [forgotBT setTitleColor:[UIColor darkGrayColor]forState:UIControlStateNormal];
//    [forgotBT setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [self.view addSubview:forgotBT];
    
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(30, 393, 200, 20)];
    label2.text = @"Don't have an account?";
    label2.textColor = [UIColor darkGrayColor];//[UIColor colorWithRed:0.1 green:0.4 blue:0.3 alpha:1];
    [self.view addSubview:label2];
    
    UIButton *signUpBT = [[UIButton alloc]initWithFrame:CGRectMake(210, 393, 80, 20)];
    [signUpBT setTitle:@"Sign up" forState:UIControlStateNormal];
    [signUpBT setTitle:@"Sign up" forState:UIControlStateSelected];
    [signUpBT setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [signUpBT setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [signUpBT addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signUpBT];
    
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
                
-(void)checkboxSelected:(id)sender{
    checkBoxSelected = !checkBoxSelected;
    [checkbox setSelected:checkBoxSelected];
}


#pragma mark - Navigation
-(void)signIn{
    NSLog(@"sign in");
    NSString *msg = [NSString stringWithFormat:@"signIn:%@\t%@",username.text,password.text];
    [self sendMessage:msg];
}
-(void)signUp{
    NSLog(@"sign up");
    SignUpViewController *sView = [[SignUpViewController alloc]init];
    [self presentViewController:sView animated:YES completion:nil];
}

#pragma mark - handle keyboard
- (void)scrollTap:(UIGestureRecognizer*)gestureRecognizer {
    
    [username resignFirstResponder];
    [password resignFirstResponder];
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
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

//handle kb
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
        return;
    }
}

#pragma mark - NSStreamDelegate
- (void)sendMessage:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    loadingView = [[UIAlertView alloc] initWithTitle:@"Signing in\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    
    
        
        if ([self.networkStream streamStatus]==NSStreamStatusOpen) {
            [self closeOutputStream];
        }
    
    [self initNetworkCommunication];
    
//    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@" , string);
    lastRequest = [NSString stringWithFormat:@"%@",string];
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
            NSLog(@"RECEIVING");
            
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
                    
                    [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                    NSString *str = [[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding];
                    NSLog(@"string : %@",str);
                    NSRange rng = [str rangeOfString:@"Signed in successfully.\n" options:0];
                    if (rng.length > 0) {
                        NSLog(@"Signed in successfully.");
                        ViewController *view = [[ViewController alloc]init];
                        view.uid = username.text;
                        if (checkBoxSelected) {
                            [[NSUserDefaults standardUserDefaults]setObject:username.text forKey:@"uid"];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                        }
                        [self presentViewController:view animated:YES completion:nil];
                    }else{
                        NSRange rng = [str rangeOfString:@"Username or password is not correct.\n" options:0];
                        if (rng.length > 0) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!" message:@"Username or password is not correct.\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }else if(lastRequest != nil){
                            NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                            if (rng.length > 0)
                                [self sendMessage:lastRequest];
                        }
                    }
                    message = nil;
                    
                }
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
    
    LogInViewController  *  obj;
    
#pragma unused(type)
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(address)
    // assert(address == NULL);
    assert(data != NULL);
    
    obj = (__bridge LogInViewController *) info;
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

- (BOOL)isSending
{
    return (self.networkStream != nil);
}


@end

