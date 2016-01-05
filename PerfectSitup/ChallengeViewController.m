//
//  ChallengeViewController.m
//  PerfectSitup
//
//  Created by lion on 7/24/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "ChallengeViewController.h"
#import "MyUtils.h"
#import "TrainDataBase.h"

@interface ChallengeViewController ()

@end

@implementation ChallengeViewController

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
    [self initParams];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([MyUtils needUpdateChallenge]) {
        
        NSDictionary * logDict = [TrainDataBase readSitupLog];
        _nUnlocked = [logDict[keyUnlockedChallengeCount] intValue];
        if (_nUnlocked == 0) {
            [_notifyLabel setText:@"You unlocked no challenges."];
        } else {
            [_notifyLabel setText:[NSString stringWithFormat:@"You unlocked %d challenges.", _nUnlocked]];
        }
        _unlockedDates = logDict[keyUnlockedChallengeDates];
        for (int n = 0; n < CHALLENGE_NUM; n++) {
            
            UILabel * titleLbl = _titleLabels[n];
            UIImageView * imageView = _imageViews[n];
            if (n < _nUnlocked) {

                [titleLbl setText:_challengeTitles[n]];
                [imageView setImage:_unlockedImage];
            } else {
                
                [titleLbl setText:[NSString stringWithFormat:@"Challenge %d", n+1]];
                [imageView setImage:_lockedImage];
            }
        }
        
        [MyUtils setNeedUpdateChallenge:NO];
    }
}
- (void) initParams
{
    _nUnlocked = 0;
    _unlockedDates = NULL;
    _lockedImage = [UIImage imageNamed:@"challenge_locked"];
    _unlockedImage = [UIImage imageNamed:@"challenge_unlocked"];
    _challengeTitles = [[NSArray alloc] initWithObjects:
                        @"20 sit-ups",
                        @"40 sit-ups",
                        @"3 train days",
                        @"5 train days",
                        @"60 sit-ups",
                        @"3 days in a week",
                        @"6 days in 2 weeks",
                        @"100 sit-ups",
                        @"150 sit-ups",
                        @"200 sit-ups",
                        @"10 days in 6 weeks",
                        @"30 train days",
                        nil];
    _challengeDetails = [[NSArray alloc] initWithObjects:
                        @"You did 20 sit-ups.",
                        @"You did 40 sit-ups.",
                        @"You trained 3 days.",
                        @"You trained 5 days.",
                        @"You did 60 sit-ups.",
                        @"You trained 3 days in a week.",
                        @"You trained 6 days in 2 weeks.",
                        @"You did 100 sit-ups.",
                        @"You did 150 sit-ups.",
                        @"You did 200 sit-ups.",
                        @"You trained 10 days in 6 weeks.",
                        @"You trained 30 days.",
                        nil];
    _titleLabels = [[NSArray alloc] initWithObjects:
                    _challengeTitle1,
                    _challengeTitle2,
                    _challengeTitle3,
                    _challengeTitle4,
                    _challengeTitle5,
                    _challengeTitle6,
                    _challengeTitle7,
                    _challengeTitle8,
                    _challengeTitle9,
                    _challengeTitle10,
                    _challengeTitle11,
                    _challengeTitle12,
                    nil];
    _imageViews = [[NSArray alloc] initWithObjects:
                    _challengeImage1,
                    _challengeImage2,
                    _challengeImage3,
                    _challengeImage4,
                    _challengeImage5,
                    _challengeImage6,
                    _challengeImage7,
                    _challengeImage8,
                    _challengeImage9,
                    _challengeImage10,
                    _challengeImage11,
                    _challengeImage12,
                    nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma IBAction functions

-(IBAction)showChallengeDetail:(id)sender;
{
    UIButton * button = sender;
    for (int n = 0; n < CHALLENGE_NUM; n++) {
        if ([button.restorationIdentifier isEqualToString:[NSString stringWithFormat:@"Button%d", n+1]])
        {
            if (n < _nUnlocked) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString * date = [dateFormatter stringFromDate:_unlockedDates[n]];
                NSString * msg = [NSString stringWithFormat:@"You unlocked challenge %d on %@.\n%@", n+1, date, _challengeDetails[n]];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congratulations !" message: msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Challenge Info." message:_challengeTitles[n] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            break;
        }
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
