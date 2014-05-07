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
@interface LogInViewController ()

@end

@implementation LogInViewController{
    
    UIButton *checkbox;
    BOOL checkBoxSelected;
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
    self.navigationController.navigationBarHidden = YES;
    
    //Miang-Stock
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.6 alpha:1];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(32, 100, 256, 40)];
    label.text = @"Miang-Stock";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:35];
    [self.view addSubview:label];
    
    UITextField *username = [[UITextField alloc]initWithFrame:CGRectMake(30, 180, 260, 30)];
    username.backgroundColor = [UIColor whiteColor];
    username.placeholder = @"  username";
    [[username layer] setBorderWidth:1.2f];
    [[username layer] setBorderColor:[UIColor grayColor].CGColor];
    [[username layer]setCornerRadius:4];
    [self.view addSubview:username];
    
    UITextField *password = [[UITextField alloc]initWithFrame:CGRectMake(30, 220, 260, 30)];
    password.backgroundColor = [UIColor whiteColor];
    password.placeholder = @"  password";
    [[password layer] setBorderWidth:1.2f];
    [[password layer] setBorderColor:[UIColor grayColor].CGColor];
    [[password layer]setCornerRadius:4];
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
}
-(void)signUp{
    NSLog(@"sign up");
    SignUpViewController *sView = [[SignUpViewController alloc]init];
    [self presentViewController:sView animated:YES completion:nil];
    
}



@end
