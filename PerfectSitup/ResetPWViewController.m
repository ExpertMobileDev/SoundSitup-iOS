//
//  ResetPWViewController.m
//  PerfectSitup
//
//  Created by lion on 8/19/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "ResetPWViewController.h"
#import "LogViewController.h"
#import "Parse/Parse.h"

@interface ResetPWViewController ()

@end

@implementation ResetPWViewController

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
    // Do any additional setup after loading the view.
    self.emailText.delegate = self;
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT;
    [_scrollView setContentSize:rect.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) nsStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma textFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    return YES;
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = MIN(keyboardSize.height,keyboardSize.width);
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = rect.size.height - height;
    [_scrollView setFrame:rect];
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    return YES;
}

#pragma IBActions


-(IBAction)resetPassword:(id)sender
{
    NSString *email;
    if ([_emailText.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (![self nsStringIsValidEmail:_emailText.text])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is not valid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        email = _emailText.text;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    [MyUtils startProgress:self];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        [MyUtils stopProgress:self];
        if (succeeded) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Password resetting request is sent!\nGo to email and reset password, please." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self gotoLogin];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:[NSString stringWithFormat:@"Password resetting request is failed!\nNo user found with email '%@'.", email] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];    
}

-(IBAction)cancel:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    [self gotoLogin	];
}

-(void)gotoLogin
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
