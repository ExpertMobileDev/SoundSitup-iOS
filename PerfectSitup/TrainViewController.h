//
//  TrainViewController.h
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "LCVoice.h"
#import "WorkViewController.h"

/**
 Accelerate
 */
#import <Accelerate/Accelerate.h>

@interface TrainViewController : UIViewController<LCVoiceDelegate, AVAudioPlayerDelegate>

@property (nonatomic,strong)  WorkViewController *workView;

@property (nonatomic) int nSitupCount;
@property (nonatomic) int nTotalCount;
@property (nonatomic) int nTodayCount;
@property (nonatomic) int nPersonalRecord;
@property(nonatomic) NSTimeInterval *situpTime;


@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UILabel *situpCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *situpLbl;
@property(nonatomic, weak) IBOutlet UILabel *totalCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *todayCountLbl;
@property(nonatomic, weak) IBOutlet UILabel *personalRecordLbl;
@property(nonatomic, weak) IBOutlet UIImageView *muteSoundBtn;



/**
 The lcvoice
 */
@property(nonatomic,retain) LCVoice * voice;


-(IBAction)closeTrainView:(id)sender;
-(IBAction)muteSound:(id)sender;

@end
