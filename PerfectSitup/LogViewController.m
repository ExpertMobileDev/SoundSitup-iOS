//
//  LogViewController.m
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "LogViewController.h"
#import "SignViewController.h"
#import "ResetPWViewController.h"
#import "TabBarController.h"
#import "Parse/Parse.h"

@interface LogViewController ()
{
    MyUtils * _myUtils;
}
@end

@implementation LogViewController

@synthesize nameText  = _nameText;
@synthesize emailText  = _emailText;
@synthesize passwordText  = _passwordText;


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
    NSLog(@"%@%@", @"HDC : ", @"didload LoginView...");
    

    self.nameText.delegate = self;
    self.emailText.delegate = self;
    self.passwordText.delegate = self;
    
    _myUtils = [MyUtils sharedObject];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT;
    [_scrollView setContentSize:rect.size];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PFUser * user = [PFUser currentUser];
    if  (user) {
        NSLog(@"%@%@", @"HDC : ", @"User already Logged in...");
        //        [self LoginOrSignup];
        [MyUtils startProgress:self];
        [_myUtils loadUserDB:self isFbuser:NO isTwuser:NO];
        
        // hide controls
        _nameText.hidden = YES;
        _passwordText.hidden = YES;
        _nameEdge.hidden = YES;
        _passwordEdge.hidden = YES;
        _forgotBtn.hidden = YES;
        _logsignEdge.hidden = YES;
        _loginBtn.hidden = YES;
        _signupBtn.hidden = YES;
        _seperator.hidden = YES;
        _facebookBtn.hidden = YES;
        _twitterBtn.hidden = YES;
        _loadLbl.hidden = NO;
    }
    else
    {
        _nameText.hidden = NO;
        _passwordText.hidden = NO;
        _nameEdge.hidden = NO;
        _passwordEdge.hidden = NO;
        _forgotBtn.hidden = NO;
        _logsignEdge.hidden = NO;
        _loginBtn.hidden = NO;
        _signupBtn.hidden = NO;
        _seperator.hidden = NO;
        _facebookBtn.hidden = NO;
        _twitterBtn.hidden = NO;
        _loadLbl.hidden = YES;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#pragma login functions

-(void)connectWithLogin:(NSString *)name /*andEmail:(NSString *)email*/ andPasswd:(NSString *)passwd
{
    [MyUtils startProgress:self];
    [PFUser logInWithUsernameInBackground:name password:passwd
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        if (user) {
                                            // login success. Load user database
                                            [_myUtils loadUserDB:self isFbuser:NO isTwuser:NO];
                                        } else {
                                            // The login failed. Check error to see why.
                                            [MyUtils stopProgress:self];
                                            [MyUtils parseErrorTxtHandler:@"Log in Failed!" error:error delegate:self];
                                        }
                                    }];
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

#pragma outlet functions

-(IBAction)loginFacebook:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];

    [MyUtils startProgress:self];
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"user_about_me",
                                 @"user_relationships",@"user_birthday",@"user_location",
                                 @"offline_access", @"email", @"publish_stream", nil];
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [MyUtils stopProgress:self];
            [MyUtils facebookErrorTxtHandler:@"Login with facebook Failed!" error:error delegate:self];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            //Facebook login success. Load user database
            [_myUtils loadUserDB:self isFbuser:YES isTwuser:NO];
        }
    }];
    
}



-(IBAction)loginTwitter:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    [MyUtils startProgress:self];
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            [MyUtils stopProgress:self];
            [MyUtils twitterErrorHandler:error delegate:self];
            return;
        } else  {
            if (user.isNew) {
                NSLog(@"User with twitter signed up and logged in!");
            } else {
                NSLog(@"User with twitter logged in!");
            }
            [_myUtils loadUserDB:self isFbuser:NO isTwuser:YES];
        }
    }];}

-(IBAction)loginEmail:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    if ([_nameText.text isEqualToString:@""])
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Username is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
//    else if ([_emailText.text isEqualToString:@""])
//    {
//        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert1 show];
//        return;
//    }
//    else if (![self nsStringIsValidEmail:_emailText.text])
//    {
//        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is not valid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert1 show];
//        return;
//    }
    else if ([_passwordText.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Password is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        [self connectWithLogin:_nameText.text /*andEmail:_emailText.text*/ andPasswd:_passwordText.text];
    }

}

-(IBAction)gotoSignUp:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignViewController * signupView =(SignViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SignViewControllerID"];
    [self presentViewController:signupView animated:NO completion:nil];
}

-(IBAction)forgotPassword:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResetPWViewController * resetView =(ResetPWViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ResetPWViewControllerID"];
    [self presentViewController:resetView animated:NO completion:nil];
}

#pragma loginSignupDelegate

-(void) LoginOrSignup
{
    // Do stuff after successful login.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TabBarController * mainView =(TabBarController*) [storyboard instantiateViewControllerWithIdentifier:@"TabBarControllerID"];
    [self presentViewController:mainView animated:NO completion:nil];
}

@end
