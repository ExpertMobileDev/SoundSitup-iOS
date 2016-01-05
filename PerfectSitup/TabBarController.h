//
//  TabBarController.h
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainDataBase.h"
enum {TAB_HISTORY = 0, TAB_WORKOUT = 1, TAB_BOARD = 2, TAB_CHALLENGE = 3};

@interface TabBarController : UITabBarController<UITabBarControllerDelegate>

@property (nonatomic) BOOL bNeedSync;



@end
