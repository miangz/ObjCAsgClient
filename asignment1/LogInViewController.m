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

#import "NSStreamManager.h"

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
                
-(void)checkboxSelected:(id)sender{
    checkBoxSelected = !checkBoxSelected;
    [checkbox setSelected:checkBoxSelected];
}


#pragma mark - Navigation
-(void)signIn{
    
    loadingView = [[UIAlertView alloc] initWithTitle:@"Signing in\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] ;
    [loadingView show];
    
    NSString *msg = [NSString stringWithFormat:@"signIn:%@\t%@",username.text,password.text];    
    NSStreamManager *myManager = [NSStreamManager sharedManager];
    [myManager sendMessage:msg];
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

- (void) receiveNotification:(NSNotification *) notification
{    
    if ([[notification name] isEqualToString:@"recievedData"]){
        NSStreamManager *myManager = [NSStreamManager sharedManager];
        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
        message = myManager.message;
        NSString *str = [[NSString alloc]initWithData:message encoding:NSASCIIStringEncoding];
        NSLog(@"string : %@",str);
        NSRange rng = [str rangeOfString:@"Signed in successfully.\n" options:0];
        if (rng.length > 0) {
            NSLog(@"Signed in successfully.");
            myManager.message = nil;
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
            }else if(myManager.lastRequest != nil){
                NSRange rng = [str rangeOfString:@"Please repeat your request again!!!\n" options:0];
                BOOL checkLastRequest = [[myManager.lastRequest substringToIndex:6]isEqualToString:@"signIn"];
                if (rng.length > 0 && checkLastRequest){
                    [myManager resendLastMessage];
                    myManager.message = nil;
                }
            }
        }

    }
}

@end

