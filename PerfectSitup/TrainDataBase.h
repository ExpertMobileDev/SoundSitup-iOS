//
//  TrainDataBase.h
//  PerfectSitup
//
//  Created by lion on 7/25/14.
//  Copyright (c) 2014 speech. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AppDelegate.h"
#import "SitupEntry.h"
#import <Parse/Parse.h>

#define CHALLENGE_NUM 12

#define cnSitupSocre @"SitupScore"
#define cnSitupDB @"SitupDB"

#define fnSitupDataBase @"situp.db"

#define fnSitupLog @"situp.log"

#define fnUserPhoto @"myPhoto"

// User Name
#define keyTrainer @"trainer"

// User Name
#define keyPhoto @"photo"

// User Total Sit ups
#define keyTotalTrainCount @"totalTrainCount"

// User Total Sit ups
#define keyTotalSitupCount @"totalSitupCount"

// User Max Sit ups Record
#define keyPersonalSitupRecord @"personalSitupRecord"
#define keyPersonalSitupDuration @"personalSitupDuration"

// User First Train Info
#define keyFirstTrainDate @"firstTrainDate"

// User Last Train Info
#define keyLastTrainDate @"lastTrainDate"
#define keyLastStiupDuration @"lastSitupDuration"
#define keyLastSitupCount @"lastSitupCount"

// User challenge unlock info
#define keyUnlockedChallengeCount @"unlockedChallengeCount"
#define keyUnlockedChallengeDates @"unlockedChallengeDates"

// User Photo URL info
#define keyUserPhotoURL @"USER_PHOTO_URL"
#define NOPhotoURL @"NO_PHOTO_URL"

#define keySitupLogPath @"SITUP_LOG_PATH"
#define keySitupDBPath @"SITUP_DB_PATH"
#define keyUserPhotoPath @"USER_PHOTO_PATH"

@interface TrainDataBase : NSObject

+ (void)writeUserPhoto: (UIImage*) photo;
+ (UIImage *)readUserPhoto;

+ (void)saveUserPhotoURL:(NSString *)url;
+ (NSString *)loadUserPhotoURL;

+(void)createSitupLog: (NSDate *)date;
+ (NSDictionary*) readSitupLog;
+ (void) writeSitupLog:(NSDictionary*)logDict;

+ (NSDictionary *) unlockChallenges:(NSDictionary *)logDict To:(NSDate *)toDate;
+ (int) getTrainDaysFrom: (NSDate *)fromDate;
+ (NSDate *) getDateFrom: (NSDate *)fromDate before:(int)days;

+ (void) createSitupDB;
+ (void) addTrainData:(NSDate*) trainDate interval:(int)trainDuration count: (int)nSitupCount;

+ (int)  situpsOnDay:(NSDate* )date;
+ (int)  situpsOnWeek:(NSDate* )dateOfWeek;
+ (int)  situpsOnMonth:(NSDate* )dateOfMonth;
+ (int)  situpsFrom:(NSDate* )date;
+ (NSMutableArray*)  situpEntriesOnWeek:(NSDate* )dateOfWeek;
+ (NSMutableArray*)  situpEntriesOnMonth:(NSDate* )dateOfMonth;
+ (NSMutableArray*)  situpEntriesTotal:(NSDate* )dateFrom today:(NSDate*) dateTo;

@end
