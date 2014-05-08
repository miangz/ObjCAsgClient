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
}

@synthesize outputStream;
@synthesize inputStream;
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
    
    UIButton *forgotBT = [[UIButton alloc]initWithFrame:CGRectMake(30, 360, 148, 30)];
    [forgotBT setTitle:@"Forgot password?" forState:UIControlStateNormal];
    [forgotBT setTitle:@"Forgot password?" forState:UIControlStateSelected];
    [forgotBT setTitleColor:[UIColor darkGrayColor]forState:UIControlStateNormal];
    [forgotBT setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:forgotBT];
    
    
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


#pragma mark - NSStreamDelegate
- (void)sendMessage:(NSString *)string{
    loadingView = [[UIAlertView alloc] initWithTitle:@"Signing in\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height - 50);
    [indicator startAnimating];
    [loadingView addSubview:indicator];
    
    
    if ([inputStream streamStatus]==NSStreamStatusOpen) {
        [inputStream close];
        [outputStream close];
    }
    
    [self initNetworkCommunication];
    
    NSString *s = [[NSString alloc]initWithFormat:@"%@\n",string];
    NSLog(@"I said: %@\n" , s);
	data = [[NSData alloc] initWithData:[s dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    
}

- (void) initNetworkCommunication {
    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 1337, &readStream, &writeStream);
	
	inputStream = (__bridge_transfer NSInputStream *)readStream;
	outputStream = (__bridge_transfer NSOutputStream *)writeStream;
	[outputStream setDelegate:self];
	[inputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    //SSL
    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                      forKey:NSStreamSocketSecurityLevelKey];
    [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
                       forKey:NSStreamSocketSecurityLevelKey];
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                              [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                              kCFNull,kCFStreamSSLPeerName,
                              nil];
    
    CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    //
	[inputStream open];
	[outputStream open];
    
}
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
	//NSLog(@"stream event %i", eventCode);
    
    static int c = 0;
    
	switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
            NSLog(@"RECEIVING");
            
			if (aStream == inputStream) {
                
                uint8_t buffer[5000];
				int len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
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
                    NSRange rng = [str rangeOfString:@"Signed in successfully." options:0];
                    if (rng.length > 0) {
                        NSLog(@"Signed in successfully.");
                        ViewController *view = [[ViewController alloc]init];
                        [self presentViewController:view animated:YES completion:nil];
                    }else{
                        NSRange rng = [str rangeOfString:@"Username or password is not correct.\n" options:0];
                        if (rng.length > 0) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!" message:@"Username or password is not correct.\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    message = nil;
                    
                }
			}
			break;
            
        case NSStreamEventHasSpaceAvailable:
            break;
		default:
			NSLog(@"Unknown event %@,%@",aStream,inputStream);
            break;
            
	}
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



@end
