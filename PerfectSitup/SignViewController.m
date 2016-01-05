//
//  SignViewController.m
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "SignViewController.h"
#import "TabBarController.h"

#define minPasswordLen 8

@interface SignViewController ()
{
    MyUtils * _myUtils;
}
@end

@implementation SignViewController

@synthesize nameText = _nameText;
@synthesize emailText = _emailText;
@synthesize passwordText = _passwordText;
@synthesize repeatText = _repeatText;

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
    NSLog(@"%@%@", @"HDC : ", @"didload SignupView...");
    
    self.nameText.delegate = self;
    self.emailText.delegate = self;
    self.passwordText.delegate = self;
    self.repeatText.delegate = self;
    
    _myUtils = [MyUtils sharedObject];

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

-(void)connectWithSignup:(NSString *)name andEmail:(NSString *)email andPasswd:(NSString *)passwd
{
    PFUser *user = [PFUser user];
    user.username = name;
    user.password = passwd;
    user.email = email;
    
    [MyUtils startProgress:self];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            // Hooray! Let them use the app now.
            NSLog(@"User with email signed up and logged in!");            
            [_myUtils loadUserDB:self isFbuser:NO isTwuser:NO];
        } else {
            [MyUtils stopProgress:self];
            [MyUtils parseErrorTxtHandler:@"Sign up Failed!" error:error delegate:self];
            // Show the errorString somewhere and let the user try again.
        }
    }];
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

-(IBAction)signupEmail:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    if ([_nameText.text isEqualToString:@""])
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Username is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
    else if ([_emailText.text isEqualToString:@""])
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
    else if (![self nsStringIsValidEmail:_emailText.text])
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Email is not valid!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
    else if ([_passwordText.text isEqualToString:@""])
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Password is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
    else if ([_repeatText.text isEqualToString:_passwordText.text] == NO)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"Confirm password does not match with password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert1 show];
        return;
    }
    else
    {
        [self connectWithSignup:_nameText.text andEmail:_emailText.text andPasswd:_passwordText.text];
    }
    
}

-(IBAction)gotoLogIn:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma loginSignupDelegate

-(void) LoginOrSignup
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame: rect];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SoundSitup" message:@"You signed up successfully! Please verify your email for SoundSitup." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    // Do stuff after successful login.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TabBarController * mainView =(TabBarController*) [storyboard instantiateViewControllerWithIdentifier:@"TabBarControllerID"];
    [self presentViewController:mainView animated:NO completion:nil];
}

@end
