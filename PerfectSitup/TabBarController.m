//
//  TabBarController.m
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "TabBarController.h"
#import <Parse/Parse.h>
#import "MyUtils.h"
#import "UpgradeViewController.h"
#import "HistoryViewController.h"
#import "WorkViewController.h"
#import "BoardViewController.h"
#import "ChallengeViewController.h"

@interface TabBarController ()
{
    UITabBar * _tabBar;
    CGSize _barSize;
    UpgradeViewController * _upgradeView;
    HistoryViewController * _historyView;
    WorkViewController * _workoutView;
    BoardViewController * _boardView;
    ChallengeViewController * _challengeView;
}
@end

@implementation TabBarController


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
    NSLog(@"%@%@", @"HDC : ", @"didload Tabbar...");    
    [MyUtils setNeedUpdateHistory:YES];
    [MyUtils setNeedUpdateWorkout:YES];
    [MyUtils setNeedUpdateBoard:YES];
    [MyUtils setNeedUpdateChallenge:YES];
    
    [self setSelectedIndex:TAB_WORKOUT];
    
    _tabBar = [self tabBar];
    _barSize.width = 320;
    _barSize.height = 49;
    UIImage *image = [UIImage imageNamed:@"tabbar_workout.png"];
    [_tabBar setBackgroundImage:[MyUtils imageWithImage:image scaledToSize:_barSize]];
    
    self.delegate = self;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tabbarcontrollerdelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
    NSLog(@"selected");
    
    if (self.selectedIndex == TAB_HISTORY) {
        UIImage *image = [UIImage imageNamed:@"tabbar_records.png"];
        [_tabBar setBackgroundImage:[MyUtils imageWithImage:image scaledToSize:_barSize]];
    } else if (self.selectedIndex == TAB_WORKOUT) {
        UIImage *image = [UIImage imageNamed:@"tabbar_workout.png"];
        [_tabBar setBackgroundImage:[MyUtils imageWithImage:image scaledToSize:_barSize]];
    } else if (self.selectedIndex == TAB_BOARD) {
        
        NSLog(@"BoardViewController selected");
        
        NSArray * childViewControllers = [self viewControllers];
        WorkViewController * workTab = (WorkViewController*) [childViewControllers objectAtIndex:TAB_WORKOUT];
        BoardViewController * boardTab = (BoardViewController *) viewController;
        
        if (workTab && [MyUtils needUpdateBoard]) {
            boardTab.userName = workTab.userName;
            if (workTab.userPhoto)
                boardTab.userPhoto = workTab.userPhoto;
            else
                boardTab.userPhoto = [UIImage imageNamed:@"photo.png"];
            
            boardTab.nUserSitupRank = workTab.nBoardRank;
            boardTab.nUserSitup = workTab.nTotalCount;
            boardTab.nUserRecord = workTab.nRecordCount;
        }
        UIImage *image = [UIImage imageNamed:@"tabbar_board.png"];
        [_tabBar setBackgroundImage:[MyUtils imageWithImage:image scaledToSize:_barSize]];
    } else if (self.selectedIndex == TAB_CHALLENGE) {
        UIImage *image = [UIImage imageNamed:@"tabbar_challenge.png"];
        [_tabBar setBackgroundImage:[MyUtils imageWithImage:image scaledToSize:_barSize]];
    }
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
