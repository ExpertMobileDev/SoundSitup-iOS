//
//  WorkViewController.m
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "WorkViewController.h"
#import "TrainViewController.h"
#import "MyUtils.h"

@interface WorkViewController ()
{
    TrainViewController * _trainView;
}
@end

@implementation WorkViewController

@synthesize logDict = _logDict;

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
    NSLog(@"%@%@", @"HDC : ", @"didload Workout...");
    
    //user photo
    self.userPhoto = nil;
    [self.userPhotoView setImage:[UIImage imageNamed:@"photo_back.png"]];
    
    //user train data
    [self initParams];
    [MyUtils setNeedUpdateWorkout:NO];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT-TABBAR_HEIGHT;
    [_scrollView setContentSize:rect.size];

}

- (void)loadUserPhoto
{
    if (self.userPhoto == nil) {
        NSString *url = [TrainDataBase loadUserPhotoURL];
        if ([url isEqualToString:NOPhotoURL] == NO) {
            _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            NSURL *photoURL = [NSURL URLWithString:url];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:photoURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadUserPhoto];
    if ([MyUtils needUpdateWorkout]) {
        [self initParams];
        [MyUtils setNeedUpdateWorkout:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma my defined actions

-(IBAction)startTrain:(id)sender
{
    NSLog(@"%@%@", @"HDC : ", @"start Train...");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _trainView =(TrainViewController*) [storyboard instantiateViewControllerWithIdentifier:@"TrainViewControllerID"];
    _trainView.workView = self;
    [self presentViewController:_trainView animated:NO completion:nil];
}

-(IBAction)capturePhoto:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take a new photo",
                            @"Choose from existing",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}

-(IBAction)logOut:(id)sender
{
    [PFUser logOut];
    UIViewController * parentView;
    parentView  = [self parentViewController];
    [parentView dismissViewControllerAnimated:NO completion:nil];
}

#pragma UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
   
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.imagePicker.delegate = self;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];

                    break;
                case 1:
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    self.imagePicker.delegate = self;
                    [self presentViewController:self.imagePicker animated:YES completion:nil];

                    break;
                default:
                    break;
            }

            break;

        }
        default:
            break;
    }
}

#pragma UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage* imageToSave = nil;
    imageToSave = [info objectForKey:UIImagePickerControllerEditedImage];
    if(imageToSave==nil)
    {
        imageToSave = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(imageToSave==nil)
    {
        imageToSave = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    //At this point you have the selected image in originalImage
    if (imageToSave != nil) {
        CGRect imageRect = [self.userPhotoView frame];
        CGSize imageSize = imageRect.size;
        self.userPhoto = [MyUtils imageWithImage:imageToSave scaledToSize:imageSize];
        [self.userPhotoView setImage:imageToSave];
        [self uploadUserPhoto];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
    
#pragma my defined functions

-(void) initParamsFromParse
{
    [MyUtils startProgress:self];

    PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFUser *trainer = object[keyTrainer];
            [trainer fetchIfNeeded];
            [self.userNameLbl setText:trainer.username];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            
            self.nTrainCount = [object[keyTotalTrainCount] intValue];
            self.nTotalCount = [object[keyTotalSitupCount] intValue];
            
            self.fromDate = object[keyFirstTrainDate];
            if (self.nTrainCount > 0) {
                self.toDate = object[keyLastTrainDate];
            }else {
                self.toDate = [NSDate date];
                object[keyLastTrainDate] = self.toDate;
                [object saveEventually];
             }
            
            self.nRecordCount = [object[keyPersonalSitupRecord] intValue];
            self.nRecordDuration = [object[keyPersonalSitupDuration] intValue];
            
            self.nLastCount = [object[keyLastSitupCount] intValue];
            self.nLastDuration = [object[keyLastStiupDuration] intValue];
            
            //set outlet properties
            [self.totalCountLbl setText:[NSString stringWithFormat:@"%d", self.nTotalCount]];
            
            [self.fromDateLbl setText:[dateFormatter stringFromDate:self.fromDate]];
            [self.toDateLbl setText:[dateFormatter stringFromDate:self.toDate]];
            
            
            [self.recordCountLbl setText:[NSString stringWithFormat:@"%d", self.nRecordCount]];
            [self.recordDurationLbl setText:[NSString stringWithFormat:@"%d : %2d", self.nRecordDuration/60, self.nRecordDuration%60]];
            
            [self.lastCountLbl setText:[NSString stringWithFormat:@"%d", self.nLastCount]];
            [self.lastDurationLbl setText:[NSString stringWithFormat:@"%d : %2d", self.nLastDuration/60, self.nLastDuration%60 ]];
            
            PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
            [query whereKey:keyTotalSitupCount greaterThan:[NSNumber numberWithInt:self.nTotalCount]];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    self.nBoardRank = count + 1;//leaderboard
                    NSString *rankText;
                    if (self.nBoardRank == 1) {
                        rankText = @"Now you are 1st place in board.";
                    } else if (self.nBoardRank == 2) {
                        rankText = @"Now you are 2nd place in board.";
                    } else if (self.nBoardRank == 3) {
                        rankText = @"Now you are 3rd place in board.";
                    } else {
                        rankText = [NSString stringWithFormat:@"Now you are %dth place in board.", self.nBoardRank];
                    }
                    [self.boardRankLbl setText:rankText];
                    [MyUtils stopProgress:self];
                } else {
                    [MyUtils parseErrorHandler:error delegate:self];
                    [MyUtils stopProgress:self];
                }
            }];
        } else {
            [MyUtils parseErrorHandler:error delegate:self];
            [MyUtils stopProgress:self];
        }
    }];
}

-(void) initParams
{
    [MyUtils startProgress:self];

    PFUser * user = [PFUser currentUser];
    self.userName = user.username;
    [self.userNameLbl setText:self.userName];
    
    _logDict = [TrainDataBase readSitupLog];
 	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
	[dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    self.nTrainCount = [_logDict[keyTotalTrainCount] intValue];
    self.nTotalCount = [_logDict[keyTotalSitupCount] intValue];
    
    self.fromDate = _logDict[keyFirstTrainDate];
    self.toDate = _logDict[keyLastTrainDate];
    
    
    self.nRecordCount = [_logDict[keyPersonalSitupRecord] intValue];
    self.nRecordDuration = [_logDict[keyPersonalSitupDuration] intValue];
    
    self.nLastCount = [_logDict[keyLastSitupCount] intValue];
    self.nLastDuration = [_logDict[keyLastStiupDuration] intValue];
    
    //set outlet properties
    [self.totalCountLbl setText:[NSString stringWithFormat:@"%d", self.nTotalCount]];
    
    [self.fromDateLbl setText:[dateFormatter stringFromDate:self.fromDate]];
    [self.toDateLbl setText:[dateFormatter stringFromDate:self.toDate]];
    
    [self.boardRankLbl setText:@"Now you are"];
    
    self.nUnlockedChallenges = [_logDict[keyUnlockedChallengeCount] intValue];

    if (self.nUnlockedChallenges == 0) {
        [self.challengeInfoLbl setText:@"You unlocked no challenges."];
    } else {
        [self.challengeInfoLbl setText:[NSString stringWithFormat:@"You unlocked %d challenges.", self.nUnlockedChallenges]];
    }

    int m, s;
    [self.recordCountLbl setText:[NSString stringWithFormat:@"%d", self.nRecordCount]];
    m = self.nRecordDuration / 60;
    s = self.nRecordDuration % 60;
    if (m == 0)
        [self.recordDurationLbl setText:[NSString stringWithFormat:@"%ds", s]];
    else
        [self.recordDurationLbl setText:[NSString stringWithFormat:@"%dm %ds", m, s]];
    
    [self.lastCountLbl setText:[NSString stringWithFormat:@"%d", self.nLastCount]];
    m = self.nLastDuration / 60;
    s = self.nLastDuration % 60;
    if (m == 0)
        [self.lastDurationLbl setText:[NSString stringWithFormat:@"%ds", s]];
    else
        [self.lastDurationLbl setText:[NSString stringWithFormat:@"%dm %ds", m, s]];
    
    PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyTotalSitupCount greaterThan:[NSNumber numberWithInt:self.nTotalCount]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.nBoardRank = count + 1;//leaderboard
            NSString *rankText;
            if (self.nBoardRank == 1) {
                rankText = @"Now you are 1st place in board.";
            } else if (self.nBoardRank == 2) {
                rankText = @"Now you are 2nd place in board.";
            } else if (self.nBoardRank == 3) {
                rankText = @"Now you are 3rd place in board.";
            } else {
                rankText = [NSString stringWithFormat:@"Now you are %dth place in board.", self.nBoardRank];
            }
            [self.boardRankLbl setText:rankText];
            [MyUtils stopProgress:self];
        } else {
            [self.boardRankLbl setText:[NSString stringWithFormat:@"Now you are last place in board."]];
            [MyUtils parseErrorTxtHandler:@"Getting user SitUps rank failed." error:error delegate:self];
            [MyUtils stopProgress:self];
        }
    }];
}

- (void)uploadUserPhoto
{
    
    NSData *imageData = UIImageJPEGRepresentation(self.userPhoto, 1.0f);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg", self.userName] data:imageData];
    // Save PFFile
    [MyUtils startProgress:self];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
            [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    object[keyPhoto] = imageFile;
                    [object saveEventually];
                    [TrainDataBase saveUserPhotoURL:imageFile.url];
                    [MyUtils stopProgress:self];
                } else {
                    [MyUtils stopProgress:self];
                }                    
            }];
        }
    }];
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [_imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // All data has been downloaded, now we can set the image in the header image view
    self.userPhoto = [UIImage imageWithData:_imageData];
    [self.userPhotoView setImage:self.userPhoto];
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
