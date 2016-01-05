//
//  MyUtils.h
//  PerfectSitup
//
//  Created by lion on 8/4/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPHONE_5_HEIGHT 568
#define IPHONE_4_HEIGHT 480
#define TABBAR_HEIGHT 49
#define IS_IPHONE_4 ( fabs( (double) [[UIScreen mainScreen] bounds].size.height-(double)IPHONE_4_HEIGHT) < DBL_EPSILON )
#define IS_IPHONE_5 ( fabs( (double) [[UIScreen mainScreen] bounds].size.height-(double)IPHONE_5_HEIGHT) < DBL_EPSILON )

@protocol LoginSignupDelegate <NSObject>

@optional

-(void)LoginOrSignup;

@end

@interface MyUtils : NSObject

@property(nonatomic, strong) id<LoginSignupDelegate> loginSignupDelegate;

@property(nonatomic, strong) NSString * userName;
@property(nonatomic, strong) NSMutableData * imageData;

-(void) loadUserDB :(id/*LoginSignupDelegate*/)delegate isFbuser:(BOOL) isfb isTwuser:(BOOL) istw;

+ (id)sharedObject;

+ (void) setNeedUpdateHistory:(BOOL) need;
+ (BOOL) needUpdateHistory;

+ (void) setNeedUpdateWorkout:(BOOL) need;
+ (BOOL) needUpdateWorkout;

+ (void) setNeedUpdateBoard:(BOOL) need;
+ (BOOL) needUpdateBoard;

+ (void) setNeedUpdateChallenge:(BOOL) need;
+ (BOOL) needUpdateChallenge;

+ (NSDate *) endOfMonth:(NSDate *) date;
+ (NSDate *) beginOfWeek:(NSDate *) date;

+ (NSString*)applicationDocumentsDirectory;
+ (void)startProgress:(id)controller;
+ (void)stopProgress:(id)controller;
+ (void)parseErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;
+ (void)facebookErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;
+ (void)twitterErrorHandler:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;
+ (void)parseErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;
+ (void)facebookErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;
+ (void)twitterErrorTxtHandler:(NSString *)title error:(NSError *)error delegate:(id /*<UIAlertViewDelegate>*/) delegate;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
