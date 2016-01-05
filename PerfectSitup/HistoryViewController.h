//
//  HistoryViewController.h
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "TrainDataBase.h"


@interface HistoryViewController : UIViewController

@property (nonatomic) NSInteger viewMode;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegment;
@property (weak, nonatomic) IBOutlet UILabel *modeTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *modeCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *modeFromLbl;
@property (weak, nonatomic) IBOutlet UILabel *modeToLbl;
@property (weak, nonatomic) IBOutlet GraphView *totalGraphView;
@property (weak, nonatomic) IBOutlet GraphView *monthGraphView;
@property (weak, nonatomic) IBOutlet GraphView *weekGraphView;


- (void) loadHistory;
- (void) showHistory;

-(IBAction)segmentSwitch:(id)sender;

@end
