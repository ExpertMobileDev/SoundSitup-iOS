//
//  TrainDataBase.m
//  PerfectSitup
//
//  Created by lion on 7/25/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "TrainDataBase.h"
#import "MyUtils.h"

@interface TrainDataBase()
{
}
@end

@implementation TrainDataBase

static NSString *_userPhotoPath;

static NSString *_situpLogPath;

static NSString *_situpDBPath;

#pragma create, read and write Situp logdata

+(void)createSitupLog: (NSDate *)date
{
    /**
     local
     */
    NSDictionary *logDict;
    
    _situpLogPath = [NSString stringWithFormat:@"%@/%@",
                [MyUtils applicationDocumentsDirectory],
                fnSitupLog];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_situpLogPath forKey:keySitupLogPath];
	[defaults synchronize];

    NSLog(@"HDC: AppLogInfoPath = %@", _situpLogPath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _situpLogPath ] == YES)
        [filemgr removeItemAtPath:_situpLogPath error:nil];
    
    NSArray *challengeDate = [[NSArray alloc] initWithObjects:
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
    
    logDict = [NSDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithInt: 0], keyTotalTrainCount,
               [NSNumber numberWithInt: 0], keyTotalSitupCount,
               [NSNumber numberWithInt: 0], keyPersonalSitupRecord,
               [NSNumber numberWithInt: 0], keyPersonalSitupDuration,
               date, keyFirstTrainDate,
               date, keyLastTrainDate,
               [NSNumber numberWithInt: 0], keyLastStiupDuration,
               [NSNumber numberWithInt: 0], keyLastSitupCount,
               [NSNumber numberWithInt: 0], keyUnlockedChallengeCount,
               challengeDate, keyUnlockedChallengeDates,
               nil];
    
    [logDict writeToFile:_situpLogPath atomically:YES];
    
    /**
     delete photo
     */    
    _userPhotoPath = [NSString stringWithFormat:@"%@/%@",
                     [MyUtils applicationDocumentsDirectory],
                     fnUserPhoto];
    
    if ([filemgr fileExistsAtPath: _userPhotoPath ] == YES)
        [filemgr removeItemAtPath:_userPhotoPath error:nil];
}

+ (void)writeUserPhoto: (UIImage*)photo
{
    NSData *binaryImageData = UIImagePNGRepresentation(photo);
    [binaryImageData writeToFile:_userPhotoPath atomically:YES];
}

+ (UIImage *)readUserPhoto
{
    UIImage *userPhoto = nil;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _userPhotoPath ] == YES)
    {
        userPhoto = [UIImage imageWithContentsOfFile:_userPhotoPath];
    }
    
    return userPhoto;
}

#pragma mark - NSUserDefaults

+ (void)saveUserPhotoURL:(NSString *)url
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:url forKey:keyUserPhotoURL];
	[defaults synchronize];
}

+ (NSString *)loadUserPhotoURL
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:keyUserPhotoURL];
}

+ (NSDictionary*) readSitupLog;
{
    NSDictionary *logDict;
    
    _situpLogPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupLogPath];
    logDict = [NSDictionary dictionaryWithContentsOfFile:_situpLogPath];
    
    return logDict;
}

+ (void) writeSitupLog:(NSDictionary*)logDict;
{
    _situpLogPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupLogPath];
    [logDict writeToFile:_situpLogPath atomically:YES];
}

#pragma unlocking challenges

+ (NSDictionary *) unlockChallenges:(NSDictionary *)logDict To:(NSDate *)toDate
{
    int unlockedCount = [logDict[keyUnlockedChallengeCount] intValue];
    if (unlockedCount == CHALLENGE_NUM) {
        return logDict;
    }
    NSArray *oldUnlockedDates = logDict[keyUnlockedChallengeDates];
    NSMutableArray *newUnlockedDates = [[NSMutableArray alloc] initWithArray:oldUnlockedDates];
    
    NSDate * fromDate;
    if (unlockedCount == 0) {
        fromDate = logDict[keyFirstTrainDate];
    } else {
        fromDate = oldUnlockedDates[unlockedCount - 1];
    }
//    NSDate * toDate = logDict[keyLastTrainDate];
    NSDate *before;
    BOOL unlocked = NO;
    int nSitups = [TrainDataBase situpsFrom:fromDate];
    int nTrainDays = [TrainDataBase getTrainDaysFrom:fromDate];

    switch (unlockedCount + 1) {
        case 1:
            // 20 sit-ups
            if (nSitups >= 20) {
                unlocked = YES;
            }
            break;
            
        case 2:
            // 40 sit-ups
            if (nSitups >= 40) {
                unlocked = YES;
            }
            break;
            
        case 3:
            // 3 train days
            if (nTrainDays >= 3) {
                unlocked = YES;
            }
            break;
            
        case 4:
            // 5 train days
            if (nTrainDays >= 5) {
                unlocked = YES;
            }
            break;
            
        case 5:
            // 60 sit-ups
            if (nSitups >= 60) {
                unlocked = YES;
            }
            break;
            
        case 6:
            // 3 train days in a week
            before = [TrainDataBase getDateFrom:toDate before:7];
            if ([before compare:fromDate] < 0) {
                break;
            }
            nTrainDays = [TrainDataBase getTrainDaysFrom:before];
            if (nTrainDays >= 3) {
                unlocked = YES;
            }
            
            break;
            
        case 7:
            // 6 train days in 2 weeks
            before = [TrainDataBase getDateFrom:toDate before:14];
            if ([before compare:fromDate] < 0) {
                break;
            }
            nTrainDays = [TrainDataBase getTrainDaysFrom:before];
            if (nTrainDays >= 6) {
                unlocked = YES;
            }
            break;
            
        case 8:
            // 100 sit-ups
            if (nSitups >= 100) {
                unlocked = YES;
            }
            break;
            
        case 9:
            // 150 sit-ups
            if (nSitups >= 150) {
                unlocked = YES;
            }
            break;
            
        case 10:
            // 200 sit-ups
            if (nSitups >= 200) {
                unlocked = YES;
            }
            break;
            
        case 11:
            // 10 train days in 6 weeks
            before = [TrainDataBase getDateFrom:toDate before:42];
            if ([before compare:fromDate] < 0) {
                break;
            }
            nTrainDays = [TrainDataBase getTrainDaysFrom:before];
            if (nTrainDays >= 10) {
                unlocked = YES;
            }
            break;
            
        case 12:
            // 30 train days
            if (nTrainDays >= 30) {
                unlocked = YES;
            }
            break;
            
        default:
            break;
    }
    
    if (unlocked) {
        [newUnlockedDates replaceObjectAtIndex: unlockedCount withObject:toDate];
        [logDict setValue:[NSNumber numberWithInt:unlockedCount + 1] forKeyPath:keyUnlockedChallengeCount];
        [logDict setValue:newUnlockedDates forKeyPath:keyUnlockedChallengeDates];
    }
    
    return logDict;
}

+ (int) getTrainDaysFrom: (NSDate *)fromDate
{
    int nTrainDays = 0;
    
    sqlite3 *situpDB;
    sqlite3_stmt    *statement;
    _situpDBPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupDBPath];
    const char *dbpath = [_situpDBPath UTF8String];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:fromDate];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:fromDate];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *  day = [dateFormatter stringFromDate:fromDate];
    
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT COUNT(*) from (SELECT * FROM WORKOUTS WHERE (year>\"%@\") OR (year=\"%@\" AND month>\"%@\") OR (year=\"%@\" AND month=\"%@\" AND day>\"%@\") GROUP BY year, month, day) as a",
                              year, year, month, year, month, day];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(situpDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *countField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 0)];
                nTrainDays = [countField intValue];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(situpDB);
    }
    
    return nTrainDays;
}

+ (NSDate *) getDateFrom: (NSDate *)fromDate before:(int)days
{
    NSDate * date;
    
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * componentsToAdd = [cal components:NSDayCalendarUnit fromDate:fromDate];
    [componentsToAdd setDay:-1 * days];
    date = [cal dateByAddingComponents:componentsToAdd toDate:fromDate options:0];
    
    return date;
}

#pragma create, read and write Situp DataBase

+(void)createSitupDB
{
    sqlite3 *situpDB;
    
    // Build the path to the database file
    _situpDBPath = [NSString stringWithFormat:@"%@/%@",
                     [MyUtils applicationDocumentsDirectory],
                     fnSitupDataBase];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_situpDBPath forKey:keySitupDBPath];
	[defaults synchronize];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: _situpDBPath ] == YES)
        [filemgr removeItemAtPath:_situpDBPath error:nil];
    
    const char *dbpath = [_situpDBPath UTF8String];
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt =
        "CREATE TABLE IF NOT EXISTS WORKOUTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, YEAR TEXT, MONTH TEXT, DAY TEXT, HOUR TEXT, MINUTE TEXT, SECOND TEXT, INTERVAL TEXT, COUNT TEXT)";
        
        if (sqlite3_exec(situpDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        sqlite3_close(situpDB);
    } else {
        NSLog(@"Failed to open/create database");
    }
}


+ (void) addTrainData:(NSDate*) trainDate interval:(int)trainDuration count: (int)nSitupCount;
{
    sqlite3 *situpDB;
    sqlite3_stmt    *statement;
    _situpDBPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupDBPath];
    const char *dbpath = [_situpDBPath UTF8String];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:trainDate];
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:trainDate];
    [dateFormatter setDateFormat:@"dd"];
    NSString *  day = [dateFormatter stringFromDate:trainDate];
    [dateFormatter setDateFormat:@"HH"];
    NSString *  hour = [dateFormatter stringFromDate:trainDate];
    [dateFormatter setDateFormat:@"mm"];
    NSString *  min = [dateFormatter stringFromDate:trainDate];
    [dateFormatter setDateFormat:@"ss"];
    NSString *  sec = [dateFormatter stringFromDate:trainDate];
    
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO WORKOUTS (YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, INTERVAL, COUNT) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\")", year, month, day, hour, min, sec, trainDuration, nSitupCount];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(situpDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSLog(@"Failed to add contact");
        }
        sqlite3_finalize(statement);
        sqlite3_close(situpDB);
    }
}

+ (int)  situpsOnWeek:(NSDate *)dateOfWeek
{
    int sum = 0;
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [cal components:NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:dateOfWeek];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc]init];
    
    [componentsToSubtract setDay:(0 - (([weekdayComponents weekday] + 5) % 7))];
    [componentsToSubtract setHour:0 - [weekdayComponents hour]];
    [componentsToSubtract setMinute:0 - [weekdayComponents minute]];
    [componentsToSubtract setSecond:0 - [weekdayComponents second]];
    
    NSDate * beginningofWeek = [cal dateByAddingComponents:componentsToSubtract toDate:dateOfWeek options:0];
    NSDateComponents * componentsToAdd = [cal components:NSDayCalendarUnit fromDate:beginningofWeek];
    
    for (int day = 0; day <= 6; day++) {
        
        [componentsToAdd setDay:day];
        
        NSDate * date = [cal dateByAddingComponents:componentsToAdd toDate:beginningofWeek options:0];
        sum += [TrainDataBase situpsOnDay:date];
        
    }
    
    return sum;
}


+ (int) situpsOnDay:(NSDate* )date
{
    sqlite3 *situpDB;
    sqlite3_stmt    *statement;
    _situpDBPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupDBPath];
    const char *dbpath = [_situpDBPath UTF8String];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int sum = 0;
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *  day = [dateFormatter stringFromDate:date];
    
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT sum(count) FROM WORKOUTS WHERE year=\"%@\" AND month=\"%@\" AND day=\"%@\" GROUP BY day",
                              year, month, day];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(situpDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *countField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 0)];
                sum = [countField intValue];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(situpDB);
    }
    return sum;
}

+ (int) situpsOnMonth:(NSDate* )dateOfMonth
{
    sqlite3 *situpDB;
    sqlite3_stmt    *statement;
    _situpDBPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupDBPath];
    const char *dbpath = [_situpDBPath UTF8String];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int sum = 0;
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:dateOfMonth];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:dateOfMonth];
    
    
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT sum(count) FROM WORKOUTS WHERE year=\"%@\" AND month=\"%@\" GROUP BY month",
                              year, month];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(situpDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *countField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 0)];
                sum = [countField intValue];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(situpDB);
    }
    return sum;
}

+ (int)  situpsFrom:(NSDate* )date
{
    sqlite3 *situpDB;
    sqlite3_stmt    *statement;
    _situpDBPath = [[NSUserDefaults standardUserDefaults] objectForKey:keySitupDBPath];
    const char *dbpath = [_situpDBPath UTF8String];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int sum = 0;
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd"];
    NSString *  day = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"HH"];
    NSString *  hour = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"mm"];
    NSString *  min = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"ss"];
    NSString *  sec = [dateFormatter stringFromDate:date];
    
    if (sqlite3_open(dbpath, &situpDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT SUM(COUNT) FROM WORKOUTS WHERE (year>\"%@\") OR (year=\"%@\" AND month>\"%@\") OR (year=\"%@\" AND month=\"%@\" AND day>\"%@\") OR (year=\"%@\" AND month=\"%@\" AND day=\"%@\" AND hour>\"%@\") OR (year=\"%@\" AND month=\"%@\" AND day=\"%@\" AND hour=\"%@\" AND minute>\"%@\") OR (year=\"%@\" AND month=\"%@\" AND day=\"%@\" AND hour=\"%@\" AND minute=\"%@\" AND second>\"%@\")",
                              year, year, month, year, month, day, year, month, day, hour, year, month, day, hour, min, year, month, day, hour, min, sec];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(situpDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *countField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 0)];
                sum = [countField intValue];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(situpDB);
    }
    return sum;
}

+ (NSMutableArray*)  situpEntriesOnWeek:(NSDate *)dateOfWeek
{
    NSMutableArray *situpEntries = [[NSMutableArray alloc]init];
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [cal components:NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:dateOfWeek];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc]init];
    
    [componentsToSubtract setDay:(0 - (([weekdayComponents weekday] + 5) % 7))];
    [componentsToSubtract setHour:0 - [weekdayComponents hour]];
    [componentsToSubtract setMinute:0 - [weekdayComponents minute]];
    [componentsToSubtract setSecond:0 - [weekdayComponents second]];
    
    NSDate * beginningofWeek = [cal dateByAddingComponents:componentsToSubtract toDate:dateOfWeek options:0];
    NSDateComponents * componentsToAdd = [cal components:NSDayCalendarUnit fromDate:beginningofWeek];
    
    for (int day = 0; day <= 6; day++) {
        
        [componentsToAdd setDay:day];
        
        SitupEntry *entry = [[SitupEntry alloc]init];
        entry.date = [cal dateByAddingComponents:componentsToAdd toDate:beginningofWeek options:0];
        entry.count = [TrainDataBase situpsOnDay:entry.date];
        
        [situpEntries addObject:entry];
    }
    
    return situpEntries;
}

+ (NSMutableArray*)  situpEntriesOnMonth:(NSDate* )dateOfMonth
{
    NSMutableArray *situpEntries = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    int daysofMonth = 31;
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:dateOfMonth];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:dateOfMonth];
    
    for (int day = 1; day <= daysofMonth; day++) {
        
        SitupEntry *entry = [[SitupEntry alloc]init];
        [comps setYear:[year intValue]];
        [comps setMonth:[month intValue]];
        [comps setDay:day];
        entry.date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        entry.count = [TrainDataBase situpsOnDay:entry.date];
        
        [situpEntries addObject:entry];
    }
    
    return situpEntries;
}

+ (NSMutableArray*)  situpEntriesTotal:(NSDate* )dateFrom today:(NSDate*) dateTo
{
    NSMutableArray *situpEntries = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    int year1 = [[dateFormatter stringFromDate:dateFrom] intValue];
    int year2 = [[dateFormatter stringFromDate:dateTo] intValue];
    
    for (int y = year1; y <= year2; y ++) {
        for (int m = 1; m <= 12; m ++) {
            
            SitupEntry *entry = [[SitupEntry alloc]init];
            [comps setYear:y];
            [comps setMonth:m];
            entry.date = [[NSCalendar currentCalendar] dateFromComponents:comps];
            entry.count = [TrainDataBase situpsOnMonth:entry.date];
            
            [situpEntries addObject:entry];
        }
    }
    
    return situpEntries;
}

@end
