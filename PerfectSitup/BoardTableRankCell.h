//
//  BoardTableRankCell.h
//  PerfectSitup
//
//  Created by lion on 8/7/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RANK_CELL_HEIGHT 43

@interface BoardTableRankCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *userRankLbl;
@property(nonatomic, weak) IBOutlet UIImageView *userPhotoView;
@property(nonatomic, weak) IBOutlet UIImageView *userPhotoEdge;
@property(nonatomic, weak) IBOutlet UILabel *userNameLbl;
@property(nonatomic, weak) IBOutlet UILabel *userCountLbl;

@end
