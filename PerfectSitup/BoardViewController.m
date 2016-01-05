//
//  BoardViewController.m
//  PerfectSitup
//
//  Created by lion on 7/24/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardTableModeCell.h"
#import "BoardTableRankCell.h"
#import "MyUtils.h"
#import "TrainDataBase.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

@synthesize nTrainerNum = _nTrainerNum;
@synthesize nCellNum = _nCellNum;

@synthesize userName = _userName;
@synthesize userPhoto = _userPhoto;

@synthesize nUserSitup = _nUserSitup;
@synthesize nUserSitupRank = _nUserSitupRank;

@synthesize nUserRecord = _nUserRecord;
@synthesize nUserRecordRank = _nUserRecordRank;

@synthesize situpRankData = _situpRankData;
@synthesize recordRankData = _recordRankData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear: animated];
    
    if ([MyUtils needUpdateBoard]) {
        [self initDataSource];
        [self.boardTableView reloadData];
        [MyUtils setNeedUpdateBoard:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT-TABBAR_HEIGHT;
    [_scrollView setContentSize:rect.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma initialize

- (void) initDataSource
{
    _nTrainerNum = TOP_RANK_NUM + 1;
    _nCellNum = (_nTrainerNum + 1) * 2;

    _photoURLs = [[NSMutableArray alloc]init];
    _photoLinks = [[NSMutableArray alloc]init];
    
    [MyUtils startProgress:self];
    PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyTrainer notEqualTo:[PFUser currentUser]];
    [query orderByDescending:keyTotalSitupCount];
    query.limit = TOP_RANK_NUM;
    
    //get top rank trainer data by totalsitup
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        if (!error) {
            
            int rank = 0;
            _situpRankData = [[NSMutableArray alloc]init];
            NSDictionary * rankData;
            NSDictionary * userData = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt: _nUserSitupRank], @"RANK",
                        _userPhoto, @"PHOTO",
                        _userName, @"NAME",
                        [NSNumber numberWithInt:_nUserSitup], @"COUNT", nil];

            for (PFObject * object in objects) {
                
                rank++;
                if (rank == _nUserSitupRank) {
                    
                    [_situpRankData addObject:userData];
                    rank++;
                }
                PFUser *trainer = object[keyTrainer];
                [trainer fetchIfNeeded];
                UIImage * photo = [UIImage imageNamed:@"photo.png"];
                if (object[keyPhoto]) {
                    
                    PFFile *imageFile = object[keyPhoto];
                    NSMutableData *imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
                    NSURL *photoURL = [NSURL URLWithString:imageFile.url];
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:photoURL
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                          timeoutInterval:2.0f];
                    // Run network request asynchronously
                    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    if (urlConnection) {
                        NSDictionary * photoLink = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    imageData, @"DATA",
                                                    _situpRankData, @"ARRAY",
                                                    [NSNumber numberWithInt: rank-1], @"ID",
                                                    nil];
                        [_photoURLs addObject:urlConnection];
                        [_photoLinks addObject:photoLink];
                    }

                }
                rankData = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt: rank], @"RANK",
                            photo, @"PHOTO",
                            trainer.username, @"NAME",
                            object[keyTotalSitupCount], @"COUNT", nil];
                
                [_situpRankData addObject:rankData];
            }
            if (_nUserSitupRank > TOP_RANK_NUM) {
                [_situpRankData addObject:userData];
            }
            [self.boardTableView reloadData];
            [MyUtils stopProgress:self];
        } else {
            
            [MyUtils parseErrorTxtHandler:@"Loading SitUps LeaderBoard info failed." error:error delegate:self];
            [MyUtils stopProgress:self];
        }
    }];
    
    [MyUtils startProgress:self];
    query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyPersonalSitupRecord greaterThan:[NSNumber numberWithInt:_nUserRecord]];
    
    //get user rank by record
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            
            _nUserRecordRank = count + 1;
            
            //get top rank trainer data by personalrecord
            PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
            [query whereKey:keyTrainer notEqualTo:[PFUser currentUser]];
            [query orderByDescending:keyPersonalSitupRecord];
            query.limit = TOP_RANK_NUM;
            [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
                if (!error) {
                    int rank = 0;
                    _recordRankData = [[NSMutableArray alloc]init];
                    NSDictionary *rankData;
                    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt: _nUserRecordRank], @"RANK",
                                _userPhoto, @"PHOTO",
                                _userName, @"NAME",
                                [NSNumber numberWithInt:_nUserRecord], @"COUNT", nil];
                    for (PFObject * object in objects) {
                        
                        rank++;
                        if (rank == _nUserRecordRank) {
                            
                            [_recordRankData addObject:userData];
                            rank++;
                        }
                        PFUser *trainer = object[keyTrainer];
                        [trainer fetchIfNeeded];
                        UIImage * photo = [UIImage imageNamed:@"photo.png"];
                        if (object[keyPhoto]) {
                            
                            PFFile *imageFile = object[keyPhoto];
                            NSMutableData *imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
                            NSURL *photoURL = [NSURL URLWithString:imageFile.url];
                            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:photoURL
                                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                                  timeoutInterval:2.0f];
                            // Run network request asynchronously
                            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                            if (urlConnection) {
                                NSDictionary * photoLink = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            imageData, @"DATA",
                                                            _recordRankData, @"ARRAY",
                                                            [NSNumber numberWithInt: rank-1], @"ID",
                                                            nil];
                                [_photoURLs addObject:urlConnection];
                                [_photoLinks addObject:photoLink];
                            }
                        }
                        rankData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: rank], @"RANK",
                                    photo, @"PHOTO",
                                    trainer.username, @"NAME",
                                    object[keyPersonalSitupRecord], @"COUNT", nil];
                        [_recordRankData addObject:rankData];
                    }
                    if (_nUserSitupRank > TOP_RANK_NUM) {
                        [_recordRankData addObject:userData];
                    }
                    [self.boardTableView reloadData];
                    [MyUtils stopProgress:self];
                } else {
                    [MyUtils parseErrorTxtHandler:@"Loading Record LeaderBoard info failed." error:error delegate:self];
                    [MyUtils stopProgress:self];
                }
            }];
        } else {
            
            [MyUtils parseErrorTxtHandler:@"Getting user Record rank failed." error:error delegate:self];
            [MyUtils stopProgress:self];
        }
    }];
}

#pragma tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nCellNum;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *modeCellId = @"ModeCell";
    static NSString *rankCellId = @"RankCell";
    
    if (indexPath.row == 0 || indexPath.row == _nCellNum / 2) {
        BoardTableModeCell *cell = (BoardTableModeCell*)[tableView dequeueReusableCellWithIdentifier:modeCellId];
        if (cell == nil) {
            cell = [[BoardTableModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:modeCellId];
        }
        if (indexPath.row == 0)
            [cell.rankModeLbl setText:@"SITUPS"];
        else
            [cell.rankModeLbl setText:@"RECORD"];
        return cell;
    } else {
        BoardTableRankCell *cell = (BoardTableRankCell*)[tableView dequeueReusableCellWithIdentifier:rankCellId];
        if (cell == nil) {
            cell = [[BoardTableRankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rankCellId];
        }
        [cell.userRankLbl setText:[NSString stringWithFormat:@"%d", indexPath.row % (_nCellNum / 2)]];
        [cell.userPhotoView setImage:[UIImage imageNamed:@"photo.png"]];
        [cell.userNameLbl setText:@""];
        [cell.userCountLbl setText:@""];
        if (indexPath.row < _nCellNum / 2) {
            
            int index = indexPath.row;
            [cell.userPhotoEdge setImage:[UIImage imageNamed:[NSString stringWithFormat:@"table_situps_photo_edge%d", index]]];
            if (index <= _situpRankData.count ) {
                
                NSDictionary *rankData = [_situpRankData objectAtIndex:index - 1];
//                if ([_userName isEqualToString: rankData[@"NAME"]]) {
//                    
//                    cell.backgroundView.backgroundColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//                    cell.userRankLbl.textColor = [UIColor darkTextColor];
//                    cell.userNameLbl.textColor = [UIColor darkTextColor];
//                    cell.userCountLbl.textColor = [UIColor darkTextColor];
//                }else {
//                    
//                    cell.backgroundView.backgroundColor = [UIColor darkGrayColor];
//                    cell.userRankLbl.textColor = [UIColor groupTableViewBackgroundColor];
//                    cell.userNameLbl.textColor = [UIColor groupTableViewBackgroundColor];
//                    cell.userCountLbl.textColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//                }
                [cell.userRankLbl setText:[NSString stringWithFormat:@"%d", [rankData[@"RANK"] intValue]]];
                [cell.userPhotoView setImage:rankData[@"PHOTO"]];
                [cell.userNameLbl setText:rankData[@"NAME"]];
                [cell.userCountLbl setText:[NSString stringWithFormat:@"%d", [rankData[@"COUNT"] intValue]]];
            }
        } else if (indexPath.row < _nCellNum) {
            
            int index = indexPath.row - _nCellNum / 2;
            [cell.userPhotoEdge setImage:[UIImage imageNamed:[NSString stringWithFormat:@"table_records_photo_edge%d", index]]];
            if (index <= _recordRankData.count ) {
                
                NSDictionary *rankData = [_recordRankData objectAtIndex:index - 1];
//                if ([_userName isEqualToString: rankData[@"NAME"]]) {
//
//                    cell.backgroundView.backgroundColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//                    cell.userRankLbl.textColor = [UIColor darkTextColor];
//                    cell.userNameLbl.textColor = [UIColor darkTextColor];
//                    cell.userCountLbl.textColor = [UIColor darkTextColor];
//                } else {
//
//                    cell.backgroundView.backgroundColor = [UIColor darkGrayColor];
//                    cell.userRankLbl.textColor = [UIColor groupTableViewBackgroundColor];
//                    cell.userNameLbl.textColor = [UIColor groupTableViewBackgroundColor];
//                    cell.userCountLbl.textColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//                }
                [cell.userRankLbl setText:[NSString stringWithFormat:@"%d", [rankData[@"RANK"] intValue]]];
                [cell.userPhotoView setImage:rankData[@"PHOTO"]];
                [cell.userNameLbl setText:rankData[@"NAME"]];
                [cell.userCountLbl setText:[NSString stringWithFormat:@"%d", [rankData[@"COUNT"] intValue]]];
            }
        }
        return cell;
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == 0 || indexPath.row == _nCellNum / 2)
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    else
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (indexPath.row == 0 || indexPath.row == _nCellNum / 2)
        return MODE_CELL_HEIGHT;
    else
        return RANK_CELL_HEIGHT;
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    NSInteger index = [_photoURLs indexOfObject:connection];
    NSDictionary *photoLink = [_photoLinks objectAtIndex:index];
    NSMutableData *imageData = photoLink[@"DATA"];
    [imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // All data has been downloaded, now we can set the image in the header image view
    NSInteger index = [_photoURLs indexOfObject:connection];
    NSDictionary *photoLink = [_photoLinks objectAtIndex:index];
    NSMutableData *imageData = photoLink[@"DATA"];
    UIImage * photo = [UIImage imageWithData:imageData];
    
    NSDictionary *oldRankData = [photoLink[@"ARRAY"] objectAtIndex:[photoLink[@"ID"] intValue]];
    NSDictionary *newRankData = [NSDictionary dictionaryWithObjectsAndKeys:
                oldRankData[@"RANK"], @"RANK",
                photo, @"PHOTO",
                oldRankData[@"NAME"], @"NAME",
                oldRankData[@"COUNT"], @"COUNT", nil];
    [photoLink[@"ARRAY"] replaceObjectAtIndex:[photoLink[@"ID"] intValue] withObject:newRankData];
    [self.boardTableView reloadData];
}

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
