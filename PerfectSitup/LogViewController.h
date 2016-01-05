//
//  LogViewController.h
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUtils.h"

@interface LogViewController : UIViewController<UITextFieldDelegate, LoginSignupDelegate>

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextField *nameText;
@property(nonatomic, weak) IBOutlet UITextField *emailText;
@property(nonatomic, weak) IBOutlet UITextField *passwordText;
@property(nonatomic, weak) IBOutlet UIImageView *nameEdge;
@property(nonatomic, weak) IBOutlet UIImageView *emailEdge;
@property(nonatomic, weak) IBOutlet UIImageView *passwordEdge;
@property(nonatomic, weak) IBOutlet UIImageView *logsignEdge;
@property(nonatomic, weak) IBOutlet UIImageView *seperator;
@property(nonatomic, weak) IBOutlet UIButton *forgotBtn;
@property(nonatomic, weak) IBOutlet UIButton *loginBtn;
@property(nonatomic, weak) IBOutlet UIButton *signupBtn;
@property(nonatomic, weak) IBOutlet UIButton *facebookBtn;
@property(nonatomic, weak) IBOutlet UIButton *twitterBtn;
@property(nonatomic, weak) IBOutlet UILabel *loadLbl;


-(IBAction)loginFacebook:(id)sender;
-(IBAction)loginTwitter:(id)sender;
-(IBAction)loginEmail:(id)sender;

-(IBAction)gotoSignUp:(id)sender;
-(IBAction)forgotPassword:(id)sender;

@end
