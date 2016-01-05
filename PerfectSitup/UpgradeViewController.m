//
//  UpgradeViewController.m
//  PerfectSitup
//
//  Created by lion on 7/24/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "UpgradeViewController.h"
#import "MyUtils.h"

@interface UpgradeViewController ()

@end

@implementation UpgradeViewController

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
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT-TABBAR_HEIGHT;
    [_scrollView setContentSize:rect.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)upgradeProVersion:(id)sender
{
    NSString * strUrl = @"http://itunes.apple.com/ca/app/instaphotoblend-free-layer/id718010268?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
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

@end
