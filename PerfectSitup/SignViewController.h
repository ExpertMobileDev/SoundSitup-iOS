//
//  SignViewController.h
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUtils.h"

@interface SignViewController : UIViewController<UITextFieldDelegate, LoginSignupDelegate>

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextField *nameText;
@property(nonatomic, weak) IBOutlet UITextField *emailText;
@property(nonatomic, weak) IBOutlet UITextField *passwordText;
@property(nonatomic, weak) IBOutlet UITextField *repeatText;


-(IBAction)signupEmail:(id)sender;

-(IBAction)gotoLogIn:(id)sender;


@end
