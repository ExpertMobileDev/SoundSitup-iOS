//
//  GraphView.h
//  PerfectSitup
//
//  Created by lion on 7/28/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SitupEntry.h"

#define MIN_BAR_HEIGHT 1
enum {VIEW_TOTAL = 0, VIEW_MONTH = 1, VIEW_WEEK = 2};

@interface GraphView : UIView

@property (strong, nonatomic) NSMutableArray *barViews;
@property (strong, nonatomic) NSArray *weekDay;

@property (strong, nonatomic) NSMutableArray *situpEntries;
@property (strong, nonatomic) NSString *beginDate;
@property (strong, nonatomic) NSString *endDate;

@property (assign, nonatomic) CGFloat margin;
@property (assign, nonatomic) int viewMode;

@property (assign, nonatomic) CGFloat guideLineWidth;
@property (assign, nonatomic) CGFloat guideLineYOffset;
@property (strong, nonatomic) UIColor *guideLineColor;

@property (assign, nonatomic) CGFloat graphLineWidth;
@property (strong, nonatomic) UIColor *graphLineColor;

@property (assign, nonatomic) CGFloat dotSize;
@property (strong, nonatomic) UIColor *dotColor;

@property (assign, nonatomic) CGFloat axisLineWidth;
@property (strong, nonatomic) UIColor *axisLineColor;


@property (assign, nonatomic) CGFloat gridLineWidth;
@property (strong, nonatomic) UIColor *gridLineColor;

@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIFont *labelFont;
@property (strong, nonatomic) UIFont *dateFont;


- (void)redrawRect;

@end
