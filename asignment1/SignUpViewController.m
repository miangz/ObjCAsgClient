//
//  SignUpViewController.m
//  asignment1
//
//  Created by miang on 5/7/2557 BE.
//  Copyright (c) 2557 miang. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSStreamManager.h"

#define kOFFSET_FOR_KEYBOARD 150.0

@interface SignUpViewController ()

@end

@implementation SignUpViewController{
    UITextField *fname;
    UITextField *lname;
    UITextField *username;
    UITextField *password;
    UITextField *rePassword;
    
    UIAlertView *loadingView;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"recievedData"
                                               object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        NSLog(@"movedUp");
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        NSLog(@"movedDown");
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
    
    loadingView = [[UIAlertView alloc] initWithTitle:@"Creating an account\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:msg];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"recievedData"]){
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        NSString *str = [[NSString alloc]initWithData:myManager.message encoding:NSASCIIStringEncoding];
        NSLog(@"string : %@",str);
        NSRange rng = [str rangeOfString:@"Added successfully.\n" options:0];
        if (rng.length > 0) {
            myManager.message = nil;
            NSLog(@"added");
            [self close];
        }else if(myManager.lastRequest !=nil){
            NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
            if (rng.length > 0){
                [myManager resendLastMessage];
            }
        }else{
            NSRange rng = [str rangeOfString:@"Someone already has that username. Try another!" options:0];
            if (rng.length > 0) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR!!" message:@"Someone already has that username. Try another!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }

    }
}


@end
