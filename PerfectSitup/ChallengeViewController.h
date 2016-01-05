//
//  ChallengeViewController.h
//  PerfectSitup
//
//  Created by lion on 7/24/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeViewController : UIViewController

@property (nonatomic) int nUnlocked;
@property (nonatomic, strong) NSArray *unlockedDates;

@property (nonatomic, strong) UIImage *lockedImage;
@property (nonatomic, strong) UIImage *unlockedImage;
@property (nonatomic, strong) NSArray *challengeTitles;
@property (nonatomic, strong) NSArray *challengeDetails;

@property (nonatomic, strong) NSArray *titleLabels;
@property (nonatomic, strong) NSArray *imageViews;

//Outlet properties

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UILabel *notifyLabel;

@property(nonatomic, weak) IBOutlet UILabel *challengeTitle1;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle2;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle3;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle4;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle5;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle6;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle7;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle8;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle9;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle10;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle11;
@property(nonatomic, weak) IBOutlet UILabel *challengeTitle12;

@property(nonatomic, weak) IBOutlet UIImageView *challengeImage1;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage2;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage3;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage4;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage5;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage6;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage7;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage8;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage9;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage10;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage11;
@property(nonatomic, weak) IBOutlet UIImageView *challengeImage12;

-(IBAction)showChallengeDetail:(id)sender;

@end
