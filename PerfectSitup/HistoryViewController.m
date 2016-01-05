//
//  HistoryViewController.m
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "HistoryViewController.h"
#import "MyUtils.h"

@interface HistoryViewController ()
{
    int _nTotalCount;
    int _nMonthCount;
    int _nWeekCount;
    NSDate * _firstTrainDate;
    NSDate * _today;
    PFUser * _curUser;
}
@end

@implementation HistoryViewController

@synthesize viewMode = _viewMode;

#pragma IBAction functions

-(IBAction)segmentSwitch:(id)sender
{
    _viewMode = self.modeSegment.selectedSegmentIndex;
    [self showHistory];
}

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
    NSLog(@"%@%@", @"HDC : ", @"didload History...");
    _viewMode = VIEW_TOTAL;
    [self showHistory];
    [MyUtils setNeedUpdateHistory:NO];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT-TABBAR_HEIGHT;
    [_scrollView setContentSize:rect.size];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([MyUtils needUpdateHistory])
    {
        [self showHistory];
        [MyUtils setNeedUpdateHistory:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) showHistory
{
    NSMutableArray *situpEntries;
    NSDictionary * logDict = [TrainDataBase readSitupLog];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *today = [NSDate date];
    SitupEntry *beginEntry, *endEntry;
    
    
    switch (_viewMode) {
        case VIEW_TOTAL:
        {
            [self.modeTitleLbl setText:@"Your total sit up is"];
            [self.modeCountLbl setText:[NSString stringWithFormat:@"%d", [logDict[keyTotalSitupCount] intValue]]];
            NSDate *begin = logDict[keyFirstTrainDate];
            situpEntries = [TrainDataBase situpEntriesTotal:begin today:today];
            
            [dateFormatter setDateFormat:@"yyyy-MM"];
            beginEntry = [situpEntries firstObject];
            endEntry = [situpEntries lastObject];
            [self.modeFromLbl setText:[dateFormatter stringFromDate:beginEntry.date]];
            [self.modeToLbl setText:[dateFormatter stringFromDate:endEntry.date]];
            
            self.totalGraphView.viewMode = VIEW_TOTAL;
            self.totalGraphView.situpEntries = situpEntries;
            [self.totalGraphView setHidden:NO];
            [self.monthGraphView setHidden:YES];
            [self.weekGraphView setHidden:YES];
            
            break;
        }
        case VIEW_MONTH:
        {
            [self.modeTitleLbl setText:@"Your this month's sit up is"];
            [self.modeCountLbl setText:[NSString stringWithFormat:@"%d", [TrainDataBase situpsOnMonth:today]]];
            situpEntries = [TrainDataBase situpEntriesOnMonth:today];

            [dateFormatter setDateFormat:@"MM-dd"];
            beginEntry = [situpEntries firstObject];
            endEntry = [situpEntries lastObject];
            [self.modeFromLbl setText:[dateFormatter stringFromDate:beginEntry.date]];
            [self.modeToLbl setText:[dateFormatter stringFromDate:endEntry.date]];
            
            self.monthGraphView.viewMode = VIEW_MONTH;
            self.monthGraphView.situpEntries = situpEntries;
            [self.totalGraphView setHidden:YES];
            [self.monthGraphView setHidden:NO];
            [self.weekGraphView setHidden:YES];
            break;
        }
        case VIEW_WEEK:
        {
            [self.modeTitleLbl setText:@"Your this week's sit up is"];
            [self.modeCountLbl setText:[NSString stringWithFormat:@"%d", [TrainDataBase situpsOnWeek:today]]];
            situpEntries = [TrainDataBase situpEntriesOnWeek:today];

            [dateFormatter setDateFormat:@"MM-dd"];
            beginEntry = [situpEntries firstObject];
            endEntry = [situpEntries lastObject];
            [self.modeFromLbl setText:[NSString stringWithFormat:@"Mon %@",[dateFormatter stringFromDate:beginEntry.date]]];
            [self.modeToLbl setText:[NSString stringWithFormat:@"Sun %@",[dateFormatter stringFromDate:endEntry.date]]];

            self.weekGraphView.viewMode = VIEW_WEEK;
            self.weekGraphView.situpEntries = situpEntries;
            [self.totalGraphView setHidden:YES];
            [self.monthGraphView setHidden:YES];
            [self.weekGraphView setHidden:NO];
            break;
        }
        default:
            break;
    }
}

#pragma online load history from parse

- (void) loadHistory
{
    _curUser = [PFUser currentUser];
    _today = [NSDate date];
    [self loadTotalHistory];
    [self loadMonthHistory];
    [self loadWeekHistory];
}

- (void) loadTotalHistory
{
    [MyUtils startProgress:self];
    
    PFQuery *query;
    query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyTrainer equalTo:_curUser];
    
    PFObject *object = [query getFirstObject];
    [object fetchIfNeeded];
    
    _nTotalCount = [object[keyTotalSitupCount] intValue];
    _firstTrainDate = object[keyFirstTrainDate];
    
    self.totalGraphView.situpEntries = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy"];
    int year1 = [[dateFormatter stringFromDate:_firstTrainDate] intValue];
    int year2 = [[dateFormatter stringFromDate:_today] intValue];
    
    //situps on everymonth totally
    for (int y = year1; y <= year2; y ++) {
        for (int m = 1; m <= 12; m ++) {
            
            SitupEntry *entry = [[SitupEntry alloc]init];
            [comps setYear:y];
            [comps setMonth:m];
            entry.date = [[NSCalendar currentCalendar] dateFromComponents:comps];
            entry.count = 0;
            
            NSString * month = (m < 10)? [NSString stringWithFormat:@"0%d", m]: [NSString stringWithFormat:@"%d", m];
            query = [PFQuery queryWithClassName:cnSitupDB];
            [query whereKey:keyTrainer equalTo:_curUser];
            [query whereKey:@"YEAR" equalTo:[NSString stringWithFormat:@"%d", y]];
            [query whereKey:@"MONTH" equalTo:month];
            NSArray *objects = [query findObjects];
            for (int i = 0; i < objects.count; i++) {
                PFObject * obj = [objects objectAtIndex:i];
                [obj fetchIfNeeded];
                entry.count += [obj[@"COUNT"] intValue] ;
            }
            
            [self.totalGraphView.situpEntries addObject:entry];
        }
    }
    [MyUtils stopProgress:self];
}

- (void) loadMonthHistory
{
    [MyUtils startProgress:self];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:_today];
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:_today];
    
    //situps on month
    _nMonthCount = 0;
    
    //situps on everyday of month
    NSDate * endofMonth = [MyUtils endOfMonth:_today];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    [dateFormatter setDateFormat:@"dd"];
    int endDay = [[dateFormatter stringFromDate:endofMonth] intValue];
    
    for (int d = 1; d <= endDay; d++) {
        SitupEntry *entry = [[SitupEntry alloc]init];
        [comps setYear:[year intValue]];
        [comps setMonth:[month intValue]];
        [comps setDay:d];
        entry.date = [[NSCalendar currentCalendar] dateFromComponents:comps];
        entry.count = 0;
        
        NSString * day = (d < 10)? [NSString stringWithFormat:@"0%d", d]: [NSString stringWithFormat:@"%d", d];
        PFQuery *query = [PFQuery queryWithClassName:cnSitupDB];
        [query whereKey:keyTrainer equalTo:_curUser];
        [query whereKey:@"YEAR" equalTo:year];
        [query whereKey:@"MONTH" equalTo:month];
        [query whereKey:@"DAY" equalTo:day];
        NSArray *objects = [query findObjects];
        for (int i = 0; i < objects.count; i++) {
            PFObject * obj = [objects objectAtIndex:i];
            [obj fetchIfNeeded];
            entry.count += [obj[@"COUNT"] intValue] ;
        }
        [self.monthGraphView.situpEntries addObject:entry];
        _nMonthCount += entry.count;
    }
    [MyUtils stopProgress:self];
}

- (void) loadWeekHistory
{
    [MyUtils startProgress:self];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:_today];
    [dateFormatter setDateFormat:@"MM"];
    NSString *  month = [dateFormatter stringFromDate:_today];
    
    //situps on week
    _nWeekCount = 0;
    
    //situps on everyday of week
    NSDate *beginofWeek = [MyUtils beginOfWeek:_today];
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * componentsToAdd = [cal components:NSDayCalendarUnit fromDate:beginofWeek];
    
    for (int d = 0; d <= 6; d++) {
        
        [componentsToAdd setDay:d];
        
        SitupEntry *entry = [[SitupEntry alloc]init];
        entry.date = [cal dateByAddingComponents:componentsToAdd toDate:beginofWeek options:0];
        entry.count = 0;
        
        [dateFormatter setDateFormat:@"dd"];
        NSString *  day = [dateFormatter stringFromDate:entry.date];
        
        PFQuery *query = [PFQuery queryWithClassName:cnSitupDB];
        [query whereKey:keyTrainer equalTo:_curUser];
        [query whereKey:@"YEAR" equalTo:year];
        [query whereKey:@"MONTH" equalTo:month];
        [query whereKey:@"DAY" equalTo:day];
        NSArray *objects = [query findObjects];
        for (int i = 0; i < objects.count; i++) {
            PFObject * obj = [objects objectAtIndex:i];
            [obj fetchIfNeeded];
            entry.count += [obj[@"COUNT"] intValue] ;
        }
        [self.weekGraphView.situpEntries addObject:entry];
        _nWeekCount += entry.count;
        
    }
    [MyUtils stopProgress:self];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
////    self.graphView.situpEntries = [TrainDataBase situpsOnMonth:[NSDate date]];
//}
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
