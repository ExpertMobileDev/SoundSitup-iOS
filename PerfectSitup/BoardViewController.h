//
//  BoardViewController.h
//  PerfectSitup
//
//  Created by lion on 7/24/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOP_RANK_NUM 3

@interface BoardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int nTrainerNum;
@property (nonatomic) int nCellNum;

@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) UIImage * userPhoto;

@property (nonatomic) int nUserSitupRank;
@property (nonatomic) int nUserSitup;

@property (nonatomic) int nUserRecordRank;
@property (nonatomic) int nUserRecord;

@property (nonatomic, strong) NSMutableArray *photoURLs;
@property (nonatomic, strong) NSMutableArray *photoLinks;

@property (nonatomic, strong) NSMutableArray *situpRankData;
@property (nonatomic, strong) NSMutableArray *recordRankData;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITableView *boardTableView;

@end
