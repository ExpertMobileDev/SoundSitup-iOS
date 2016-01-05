//
//  WorkViewController.h
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"
#import "AppDelegate.h"
@interface WorkViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSDictionary * logDict;

@property(nonatomic) int nTrainCount;

@property(nonatomic, strong) UIImage *userPhoto;
@property(nonatomic, strong) NSString *userName;

@property(nonatomic) int nTotalCount;
@property(nonatomic, strong) NSDate * fromDate;
@property(nonatomic, strong) NSDate * toDate;

@property(nonatomic) int nBoardRank;
@property(nonatomic) int nUnlockedChallenges;

@property(nonatomic) int nRecordCount;
@property(nonatomic) int nRecordDuration;

@property(nonatomic) int nLastCount;
@property(nonatomic) int nLastDuration;

@property(nonatomic, strong) NSMutableData *imageData;


@property(nonatomic, strong) UIImagePickerController *imagePicker;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UIImageView *userPhotoView;
@property(nonatomic, weak) IBOutlet UILabel *userNameLbl;

@property(nonatomic, weak) IBOutlet UILabel *totalCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *fromDateLbl;
@property(nonatomic, weak) IBOutlet UILabel *toDateLbl;

@property(nonatomic, weak) IBOutlet UILabel *boardRankLbl;
@property(nonatomic, weak) IBOutlet UILabel *challengeInfoLbl;

@property(nonatomic, weak) IBOutlet UILabel *recordCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *recordDurationLbl;

@property(nonatomic, weak) IBOutlet UILabel *lastCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *lastDurationLbl;

-(IBAction)startTrain:(id)sender;
-(IBAction)capturePhoto:(id)sender;
-(IBAction)logOut:(id)sender;

-(void) initParams;

@end
