//
//  ResetPWViewController.h
//  PerfectSitup
//
//  Created by lion on 8/19/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPWViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UITextField *emailText;

-(IBAction)resetPassword:(id)sender;
-(IBAction)cancel:(id)sender;

@end
