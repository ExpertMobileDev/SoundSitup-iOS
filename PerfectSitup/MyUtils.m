//
//  MyUtils.m
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "MyUtils.h"
#import "TrainDataBase.h"

@implementation MyUtils

static BOOL bNeedUpdateHistory = YES;
static BOOL bNeedUpdateWorkout = YES;
static BOOL bNeedUpdateBoard = YES;
static BOOL bNeedUpdateChallenge = YES;

+ (id)sharedObject
{
    
    static MyUtils *myUtils = nil;
    if (myUtils == nil) {
        myUtils = [[MyUtils alloc] init];
    }
    return myUtils;
}

-(void) loadUserDB :(id/*LoginSignupDelegate*/)delegate isFbuser:(BOOL) isfb isTwuser:(BOOL) istw
{
    NSDate * date = [NSDate date];
    PFUser * user = [PFUser currentUser];
    self.loginSignupDelegate = delegate;
    //create local database
    [TrainDataBase createSitupLog: date];
    [TrainDataBase createSitupDB];
    [TrainDataBase saveUserPhotoURL:NOPhotoURL];
    
    
    if (user.isNew == YES) {
        if (isfb) {
            NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,picture,email,id";
            
            FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
            
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
                    
                    NSString *name = [userData objectForKey:@"name"];
                    user.username = name;
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            [self createParseDatabase:user delegate:delegate date:date];
                        } else {
                            [MyUtils stopProgress:self.loginSignupDelegate];
                            [MyUtils parseErrorTxtHandler:@"Updating User info by Facebook profile failed." error:error delegate:delegate];
                        }
                    }];
                    
//                    // get the FB user's profile image
//                    NSDictionary *dicFacebookPicture = [userData objectForKey:@"picture"];
//                    NSDictionary *dicFacebookData = [dicFacebookPicture objectForKey:@"data"];
//                    NSString *sUrlPic= [dicFacebookData objectForKey:@"url"];
//                    
//                    _userName = name;
//                    _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
//                    NSURL *photoURL = [NSURL URLWithString:sUrlPic];
//                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:photoURL
//                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                                          timeoutInterval:2.0f];
//                    // Run network request asynchronously
//                    NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//                    if (!urlConnection) {
//                        NSLog(@"Failed to download picture");
//                    }
                }
                else {
                    [MyUtils facebookErrorTxtHandler:@"Getting Facebook user profile failed." error:error delegate:delegate];
                }
            }];

        } else if (istw) {
            
            NSString * requestString = @"https://api.twitter.com/1.1/account/verify_credentials.json";
            
            NSURL *verify = [NSURL URLWithString:requestString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
            [[PFTwitterUtils twitter] signRequest:request];
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:&error];
            
            
            if ( error == nil){
                NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"%@",result);
                
                // does this thign help?
                [user setUsername:[result objectForKey:@"screen_name"]];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [self createParseDatabase:user delegate:delegate date:date];
                    } else {
                        [MyUtils stopProgress:self.loginSignupDelegate];
                        [MyUtils parseErrorTxtHandler:@"Updating User info by Twitter profile failed." error:error delegate:delegate];
                    }
                }];
                
//                _userName = user.username;
//                _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
//                NSString *sUrlPic= [result objectForKey:@"profile_image_url_https"];
//                NSURL *photoURL = [NSURL URLWithString:sUrlPic];
//                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:photoURL
//                                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                                      timeoutInterval:2.0f];
//                // Run network request asynchronously
//                NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//                if (!urlConnection) {
//                    NSLog(@"Failed to download picture");
//                }
            }
            else {
                [MyUtils twitterErrorTxtHandler:@"Getting Twitter user profile failed." error:error delegate:delegate];
            }

        } else {
            //create parse database
            [self createParseDatabase:user delegate:delegate date:date];
        }
    } else {
        //read parse database
        PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
        [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                //write photo
                PFFile *imageFile = object[keyPhoto];
                if (imageFile) {
                    [TrainDataBase saveUserPhotoURL:imageFile.url];
                }
                
                //write local database
                NSDictionary * logDict = [TrainDataBase readSitupLog];
                [logDict setValue: object[keyTotalTrainCount] forKeyPath:keyTotalTrainCount];
                [logDict setValue: object[keyTotalSitupCount] forKeyPath:keyTotalSitupCount];
                [logDict setValue: object[keyPersonalSitupRecord] forKeyPath:keyPersonalSitupRecord];
                [logDict setValue: object[keyPersonalSitupDuration] forKeyPath:keyPersonalSitupDuration];
                [logDict setValue: object[keyFirstTrainDate] forKeyPath:keyFirstTrainDate];
                [logDict setValue: object[keyLastTrainDate] forKeyPath:keyLastTrainDate];
                [logDict setValue: object[keyLastSitupCount] forKeyPath:keyLastSitupCount];
                [logDict setValue: object[keyLastStiupDuration] forKeyPath:keyLastStiupDuration];
                if (object[keyUnlockedChallengeCount] && object[keyUnlockedChallengeDates]) {
                    [logDict setValue: object[keyUnlockedChallengeCount] forKeyPath:keyUnlockedChallengeCount];
                    [logDict setValue: object[keyUnlockedChallengeDates] forKeyPath:keyUnlockedChallengeDates];
                }
                [TrainDataBase writeSitupLog:logDict];
                
                
                //read parse database
                PFQuery *query = [PFQuery queryWithClassName:cnSitupDB];
                [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
                query.limit = 1000;
                [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
                    if (!error) {
                        NSDictionary * logDict = [TrainDataBase readSitupLog];
                        //write local database
                        for (int i = 0; i < objects.count; i++) {
                            PFObject * obj = [objects objectAtIndex:i];
                            [TrainDataBase addTrainData:obj[@"DATE"]
                                               interval:[obj[@"DURATION"] intValue]
                                                  count:[obj[@"COUNT"] intValue]];
                            if (object[keyUnlockedChallengeCount] == nil) {
                                logDict = [TrainDataBase unlockChallenges:logDict To:obj[@"DATE"]];
                            }
                        }
                        [TrainDataBase writeSitupLog:logDict];
                        PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
                        [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
                        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (!error) {
                                object[keyUnlockedChallengeCount] = logDict[keyUnlockedChallengeCount];
                                object[keyUnlockedChallengeDates] = logDict[keyUnlockedChallengeDates];
                                [object saveEventually];
                            } else {
                            }
                        }];
                        [MyUtils stopProgress:self.loginSignupDelegate];
                        [self.loginSignupDelegate LoginOrSignup];
                    } else {
                        [MyUtils stopProgress:self.loginSignupDelegate];
                        [MyUtils parseErrorTxtHandler:@"Loading user situp DB failed." error:error delegate:delegate];
                    }
                }];
            } else {
                [MyUtils stopProgress:self.loginSignupDelegate];
                [MyUtils parseErrorTxtHandler:@"Loading user info failed." error:error delegate:delegate];
            }
        }];
        
    }
}

-(void)createParseDatabase:(PFUser*)user delegate:(id/*LoginSignupDelegate*/)delegate date:(NSDate*)date
{
    PFObject *situpScore = [PFObject objectWithClassName:cnSitupSocre];
    NSArray *challengeDates = [[NSArray alloc] initWithObjects:
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              date,
                              nil];
    
    situpScore[keyTrainer] = user;
    situpScore[keyTotalTrainCount] = @0;
    situpScore[keyTotalSitupCount] = @0;
    situpScore[keyPersonalSitupRecord] = @0;
    situpScore[keyPersonalSitupDuration] = @0;
    situpScore[keyFirstTrainDate] = date;
    situpScore[keyLastTrainDate] = date;
    situpScore[keyLastSitupCount] = @0;
    situpScore[keyLastStiupDuration] = @0;
    situpScore[keyUnlockedChallengeCount] = @0;
    situpScore[keyUnlockedChallengeDates] = challengeDates;
    
    [situpScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [MyUtils stopProgress:self.loginSignupDelegate];
            [self.loginSignupDelegate LoginOrSignup];
        } else {
            [MyUtils stopProgress:self.loginSignupDelegate];
            [MyUtils parseErrorTxtHandler:@"Creating user info failed." error:error delegate:delegate];
        }
    }];

}
-(void)doFaceBookUserHasLoggedIn
{
//    NSString *requestPath = @"me/?fields=name,location,gender,birthday,relationship_status,picture,email,id";
//    
//    FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
//    
//    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
//            
//            NSString *name = [userData objectForKey:@"name"];
//            
//            NSString *email = [userData objectForKey:@"email"];
//            
//            NSString *sID = [userData objectForKey:@"id"];
//            
//            // get the FB user's profile image
//            NSDictionary *dicFacebookPicture = [userData objectForKey:@"picture"];
//            NSDictionary *dicFacebookData = [dicFacebookPicture objectForKey:@"data"];
//            NSString *sUrlPic= [dicFacebookData objectForKey:@"url"];
//            UIImage* imgProfile = [UIImage imageWithData:
//                                  [NSData dataWithContentsOfURL:
//                                  [NSURL URLWithString: sUrlPic]]];
//            
//            //do something interesting with this data...
//            
//            //...
//            
//            // now request FB friend list
//            FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/friends"];
//            
//            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                            if (!error) {
//                                NSArray *data = [result objectForKey:@"data"];
//            
//                                if (data) {
//                                    //we now have an array of NSDictionary entries contating friend data
//                                    for (NSMutableDictionary *friendData in data) {
//                                        // do something interesting with the friend data...
//            
//                                    }
//                                }
//                                
//                            }
//                        }];
//        }
//    }];
}

+ (void) setNeedUpdateHistory:(BOOL) need
{
    bNeedUpdateHistory = need;
}
+ (BOOL) needUpdateHistory
{
    return bNeedUpdateHistory;
}

+ (void) setNeedUpdateWorkout:(BOOL) need
{
    bNeedUpdateWorkout = need;
}
+ (BOOL) needUpdateWorkout
{
    return bNeedUpdateWorkout;
}

+ (void) setNeedUpdateBoard:(BOOL) need
{
    bNeedUpdateBoard = need;
}
+ (BOOL) needUpdateBoard
{
    return bNeedUpdateBoard;
}

+ (void) setNeedUpdateChallenge:(BOOL) need
{
    bNeedUpdateChallenge = need;
}
+ (BOOL) needUpdateChallenge
{
    return bNeedUpdateChallenge;
}

#pragma manipulate date

+ (NSDate *) dateByAddingMonths: (NSInteger) monthsToAdd toDate:(NSDate *) date
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth: monthsToAdd];
    
    return [calendar dateByAddingComponents: months toDate: date options: 0];
}

+ (NSDate *) endOfMonth:(NSDate *) date
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1 toDate: date];
    NSDateComponents * plusOneMonthDateComponents = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [[calendar dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // One second before the start of next month
    
    return endOfMonth;
}

+ (NSDate *) beginOfWeek:(NSDate *) date
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [cal components:NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc]init];
    
    [componentsToSubtract setDay:(0 - (([weekdayComponents weekday] + 5) % 7))];
    [componentsToSubtract setHour:0 - [weekdayComponents hour]];
    [componentsToSubtract setMinute:0 - [weekdayComponents minute]];
    [componentsToSubtract setSecond:0 - [weekdayComponents second]];
    
    NSDate * beginningofWeek = [cal dateByAddingComponents:componentsToSubtract toDate:date options:0];
    return beginningofWeek;
}

#pragma mark - Utility

+ (NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (void)startProgress:(id)controller
{
    if ([controller isKindOfClass:[UIViewController class]]) {
        UIView *delegateView = ((UIViewController *)controller).view;
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[delegateView viewWithTag:1000000];
        if (!spinner) {
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinner.center = delegateView.center;
            spinner.color = [UIColor whiteColor];
            [delegateView addSubview:spinner];
            spinner.tag = 1000000;
            [spinner startAnimating];
            delegateView.userInteractionEnabled = NO;
        }
    }
}

+ (void)stopProgress:(id)controller
{
    if ([controller isKindOfClass:[UIViewController class]]) {
        UIView *delegateView = ((UIViewController *)controller).view;
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[delegateView viewWithTag:1000000];
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        delegateView.userInteractionEnabled = YES;
    }
}

#pragma mark - NSUserDefaults


+ (void)parseErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server connection error!"
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)parseErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)facebookErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook connection error!"
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)facebookErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)twitterErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter connection error!"
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)twitterErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[error userInfo][@"error"]
                                                   delegate:delegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [_imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // All data has been downloaded, now we can set the image in the header image view
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg", _userName] data:_imageData];
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
            [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    
                    object[keyPhoto] = imageFile;
                    [object saveEventually];
                    [TrainDataBase saveUserPhotoURL:imageFile.url];
                    [MyUtils setNeedUpdateWorkout:YES];
                } else {
                    
                }
            }];
        }
    }];

}

@end
