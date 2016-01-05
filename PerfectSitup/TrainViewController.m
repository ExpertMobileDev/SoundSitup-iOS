//
//  TrainViewController.m
//  PerfectSitup
//
//  Created by lion on 7/21/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "TrainViewController.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "MyUtils.h"

#define _nReadyTime 5

//Thresholds
#define _fMinPower -30.0f
#define _fLowDeltaPower 5.0f
#define _fMidDeltaPower 5.0f
#define _fHighDeltaPower 7.0f

#define _fMinPauseTime 5.0f

#define _fMinDeltaTime 0.5f
#define _fMaxDeltaTime 2.5f

#define USE_EZAUDIO
#undef USE_EZAUDIO

@interface TrainViewController ()
{
    // FFT
    COMPLEX_SPLIT _A;
    FFTSetup      _FFTSetup;
    BOOL          _isFFTSetup;
    vDSP_Length   _log2n;

    // LCVoice
    NSMutableArray* _powerArray;
    
    //time
    NSDate * _upTime;
    NSDate * _downTime;
    NSDate * _currentTime;
    NSDate * _checkTime;
    NSDate * _beginTime;
    NSDate * _endTime;
    int _trainDuration;
    
    //Average Power
    float _averageP;
    int _numberP;
    
    //power
    float _preP;
    float _curP;
    
    float _maxMag;
    
    //flag
    BOOL _isUpDetected;
    BOOL _isDownDetected;
    BOOL _isDetecting;
    BOOL _isPreparing;

}
@property (nonatomic) BOOL isMute;
@property (nonatomic) BOOL isPlayingFile;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property int restTime;
@property (nonatomic, strong) NSTimer *readyTimer;
@property (nonatomic, strong) NSTimer *secondTimer;

@property (nonatomic) BOOL isRecordingFile;

@property (nonatomic) BOOL isMicOn;

//Main thread
@property NSThread* detectThread;
@property NSThread* countThread;


@end

@implementation TrainViewController

@synthesize workView = _workView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"%@%@", @"HDC : ", @"init TrainViewController...");

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@%@", @"HDC : ", @"didload Train...");
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    [_scrollView setFrame:rect];
    rect.size.height = IPHONE_5_HEIGHT;
    [_scrollView setContentSize:rect.size];
    
    // disable automatic screen lock
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    //set data from db
    self.nPersonalRecord = _workView.nRecordCount;
    self.nTotalCount = _workView.nTotalCount;
    self.nTodayCount = [TrainDataBase situpsOnDay:[NSDate date]];
    
    self.nSitupCount = 0;
    self.isMute = NO;
    self.isPlayingFile = NO;
    [self readyToStart];
    /*
     Customizing the audio plot's look
     */
    // Setup time domain audio plot
//    self.audioPlotTime.backgroundColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//    self.audioPlotTime.color           = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.0];
//    self.audioPlotTime.shouldFill      = YES;
//    self.audioPlotTime.shouldMirror    = YES;
//    self.audioPlotTime.plotType        = EZPlotTypeRolling;
    
    // Setup frequency domain audio plot
//    self.audioPlotFreq.backgroundColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//    self.audioPlotFreq.color           = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
//    self.audioPlotFreq.shouldFill      = YES;
//    self.audioPlotFreq.plotType        = EZPlotTypeRolling;
    
    // Setup frequency domain audio plot
//    self.audioPlotPeak.backgroundColor = [UIColor colorWithRed: 1 green: 0.828 blue: 0.0 alpha: 1];
//    self.audioPlotPeak.color           = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
//    self.audioPlotPeak.shouldFill      = YES;
//    self.audioPlotPeak.plotType        = EZPlotTypeRolling;
    
    /*
     Create LCVoice
     */
    self.voice = [[LCVoice alloc] init];
    self.voice.lcvoiceDelegate = self;
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/%@",
                                     [MyUtils applicationDocumentsDirectory],
                                     @"LCTest.caf"]];
    
    _powerArray = [[NSMutableArray alloc] init];
    
//    [self createFileWithName:@"power.txt"];
//    [self createFileWithName:@"logP.txt"];

    
//    self.detectThread = [[NSThread alloc] initWithTarget:self selector:@selector(detectSitup) object:nil];
//    self.countThread = [[NSThread alloc] initWithTarget:self selector:@selector(countSitup) object:nil];
    
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma myfunctions

-(void)readyToStart
{
    [self playAudioFile:@"get_ready" ofType:@"mp3"];
    
    [self.situpLbl setText:@"READY"];
    [self.situpCountLbl setText:[NSString stringWithFormat:@"%d", _nReadyTime]];
    [self.totalCountLbl setText:[NSString stringWithFormat:@"%d", self.nTotalCount]];
    [self.todayCountLbl setText:[NSString stringWithFormat:@"%d", self.nTodayCount]];
    [self.personalRecordLbl setText:[NSString stringWithFormat:@"PERSONAL RECORD  %d", self.nPersonalRecord]];

    self.restTime = _nReadyTime;
    self.readyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateReadyTime)
                                                     userInfo:nil
                                                      repeats:YES];
    _isPreparing = YES;
    _numberP = 0;
    _averageP = 0;
    
}

-(void)playAudioFile:(NSString*)fname ofType:(NSString*) type
{
    [self stopAudioFile];
    
    if (self.isMute == NO) {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:fname ofType: type];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        self.audioPlayer.delegate = self;
        [self.voice pauseRecording];
        NSLog(@"HDC: VLVoice Recording paused.");
        [self.audioPlayer play];
        self.isPlayingFile = YES;
    }
}

-(void)stopAudioFile
{
    if (self.isPlayingFile == YES) {
        [self.audioPlayer stop];
        self.isPlayingFile = NO;
    }
}

- (void)updateReadyTime
{
    if (self.restTime > 0) {
        self.restTime --;
        [self.situpCountLbl setText:[NSString stringWithFormat:@"%d", self.restTime]];
        if (self.restTime == 3) {
            [self playAudioFile:@"three" ofType:@"mp3"];
        } else if (self.restTime == 2) {
            [self playAudioFile:@"two" ofType:@"mp3"];
        } else if (self.restTime == 1) {
            [self playAudioFile:@"one" ofType:@"mp3"];
        } else if (self.restTime == 0) {
            /*
             Start Train
             */
            [self playAudioFile:@"go" ofType:@"mp3"];
            [self.situpLbl setText:@"SITUPS"];
            
            _beginTime = [NSDate date];
            _checkTime = [NSDate date];
            
            [self.readyTimer invalidate];
            self.readyTimer = nil;
            
            _isPreparing = NO;
            [_powerArray removeAllObjects];
            _isUpDetected = NO;
            _isDownDetected = NO;
            _isDetecting = NO;
//            [self.detectThread start];
//            [self.countThread start];
            
            self.secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(checkSitupStatus)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
}

-(void)checkSitupStatus
{
    NSDate *current = [NSDate date];
    NSTimeInterval delta = [current timeIntervalSinceDate:_checkTime];
    if (delta > _fMinPauseTime)
    {
        _checkTime = current;
        if (_isMute == NO)
            [self playAudioFile:@"continue" ofType:@"mp3"];
    }
}

-(void) updateLocalDB
{
    // Add train record in sqlite DB
    [TrainDataBase addTrainData:_beginTime interval:_trainDuration count: self.nSitupCount];

    // Update situpLog data
    [_workView.logDict setValue:[NSNumber numberWithInt:_workView.nTrainCount + 1] forKeyPath:keyTotalTrainCount];
    [_workView.logDict setValue:[NSNumber numberWithInt:self.nTotalCount] forKeyPath:keyTotalSitupCount];
    [_workView.logDict setValue:_beginTime forKeyPath:keyLastTrainDate];
    [_workView.logDict setValue:[NSNumber numberWithInt:self.nSitupCount] forKeyPath:keyLastSitupCount];
    [_workView.logDict setValue:[NSNumber numberWithInt:_trainDuration] forKeyPath:keyLastStiupDuration];
    if (_workView.nRecordCount < self.nPersonalRecord) {
        [_workView.logDict setValue:[NSNumber numberWithInt:self.nPersonalRecord] forKeyPath:keyPersonalSitupRecord];
        [_workView.logDict setValue:[NSNumber numberWithInt:_trainDuration] forKeyPath:keyPersonalSitupDuration];
    }
    
    // Update unlocked challenge info
    _workView.logDict = [TrainDataBase unlockChallenges: _workView.logDict To:_beginTime];
    
    // Write updated situpLog data
    [TrainDataBase writeSitupLog:_workView.logDict];
}

#pragma parse update DB
-(void) updateSitupDB
{
    [MyUtils startProgress:self];
    
    PFQuery *query = [PFQuery queryWithClassName:cnSitupSocre];
    [query whereKey:keyTrainer equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            object[keyTotalTrainCount] = [NSNumber numberWithInt:[object[keyTotalTrainCount] intValue] + 1];
            object[keyTotalSitupCount] = [NSNumber numberWithInt:self.nTotalCount];
            
            object[keyLastTrainDate] = _beginTime;
            object[keyLastSitupCount] = [NSNumber numberWithInt:self.nSitupCount];
            object[keyLastStiupDuration] = [NSNumber numberWithInt:_trainDuration];
           
            if ([object[keyPersonalSitupRecord] intValue] < self.nPersonalRecord) {
                object[keyPersonalSitupRecord] = [NSNumber numberWithInt:self.nPersonalRecord];
                object[keyPersonalSitupDuration] = [NSNumber numberWithInt:_trainDuration];
            }
            
            object[keyUnlockedChallengeCount] = _workView.logDict[keyUnlockedChallengeCount];
            object[keyUnlockedChallengeDates] = _workView.logDict[keyUnlockedChallengeDates];
           
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    // add train data to situpDB
                    PFObject * situpDB = [PFObject objectWithClassName:cnSitupDB];
                    
                    situpDB[keyTrainer] = [PFUser currentUser];
                    situpDB[@"DATE"] = _beginTime;
                    situpDB[@"DURATION"] = [NSNumber numberWithInt:_trainDuration];
                    situpDB[@"COUNT"] = [NSNumber numberWithInt:self.nSitupCount];
                    
                    [situpDB saveEventually];
                    [MyUtils stopProgress:self];
                    [self dismissViewControllerAnimated:NO completion:nil];

                } else {
                    [MyUtils parseErrorTxtHandler:@"Saving SitUp info failed." error:error delegate:self];
                    [MyUtils stopProgress:self];
                    [self dismissViewControllerAnimated:NO completion:nil];
                }
            }];
        } else {
            [MyUtils parseErrorTxtHandler:@"Updating triain info failed." error:error delegate:self];
            [MyUtils stopProgress:self];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

#pragma main methods for detect&count situp threads
-(void)countSitup
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.situpCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nSitupCount]];
        [self.totalCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nTotalCount]];
        [self.todayCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nTodayCount]];
        if (self.nPersonalRecord < self.nSitupCount) {
            self.nPersonalRecord = self.nSitupCount;
            [self.personalRecordLbl setText:[NSString stringWithFormat:@"PERSONAL RECORD  %d", self.nPersonalRecord]];
        }
    });
    
    [self playAudioFile:@"count_beep" ofType:@"mp3"];
}

-(void)detectSitup
{
    NSNumber *power;
    
//    NSLog(@"HDC: detectThread started!");
    _isDetecting = YES;
    while (_powerArray.count > 0) {
        
        power = (NSNumber*)[_powerArray objectAtIndex:0];
        [_powerArray removeObjectAtIndex:0];
        
        _curP = [power floatValue];
        _currentTime = [NSDate date];
        
        if (_isUpDetected == YES &&
            [_currentTime timeIntervalSinceDate:_upTime] > _fMaxDeltaTime) {
                _isUpDetected = NO;
                NSLog(@"HDC: Up canceled!");
        }
        
        //                if (_curP -_preP > 3)
        //                    NSLog(@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP);
        
        if (_curP - _averageP > _fHighDeltaPower) {
            if (_curP > _fMinPower && _curP - _preP > _fMidDeltaPower) {
                
                //detected a peak
                if (_isUpDetected == NO) {
                    
                    //set situp-up
                    _isUpDetected = YES;
                    _upTime = _currentTime;
                    _isDownDetected = NO;
                    NSLog(@"HDC: Up detected!");
                }
                else {
                    if ([_currentTime timeIntervalSinceDate:_upTime] < _fMinDeltaTime) {
                        
                        //reset situp-up
                        _upTime = _currentTime;
                        NSLog(@"HDC: Up moved!");
                    } else {
                        
                        //set situp-down
                        _isDownDetected = YES;
                        _downTime = _currentTime;
                        _isUpDetected = NO;
                        
                        //detected one situp
                        [self countSitup];
                        NSLog(@"HDC: Down detected!");
                        
                    }
                }
                
                //reset pausetime
                _checkTime = _currentTime;
                
                //                        NSLog(@"HDC: _curP = %.0f _averageP = %.0f", _curP, _averageP);
                //                        NSLog(@"HDC: _curP - _averageP = %.0f, _curP - _preP = %.0f", _curP - _averageP, _curP - _preP);
            }
            //                    else if (_curP - _preP > _fHighDeltaPower)
            //                        NSLog(@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP);
        }
        else if (_curP - _averageP < _fLowDeltaPower) {
            _averageP = (_averageP * _numberP + _curP) / (_numberP + 1);
            _numberP++;
        }
        _preP = _curP;
        
    }
    _isDetecting = NO;
//    NSLog(@"HDC: detectThread finished!");
}


//-(void)countSitup
//{
//    NSLog(@"HDC: countThread started!");
//    while (_exitThread == NO) {
//        if (_showCount == YES) {
//
//            _showCount = NO;
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [self.situpCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nSitupCount]];
//                [self.totalCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nTotalCount]];
//                [self.todayCountLbl setText:[NSString stringWithFormat:@"%d", ++self.nTodayCount]];
//                if (self.nPersonalRecord < self.nSitupCount) {
//                    self.nPersonalRecord = self.nSitupCount;
//                    [self.personalRecordLbl setText:[NSString stringWithFormat:@"PERSONAL RECORD  %d", self.nPersonalRecord]];
//                }
//            });
//            
//            [self playAudioFile:@"count_beep" ofType:@"mp3"];
////            NSLog(@"HDC: SitupCount: %d", self.nSitupCount);
//            [NSThread sleepForTimeInterval:0.001];
//        }
//        [NSThread sleepForTimeInterval:0.001];
//    }
//    NSLog(@"HDC: countThread finished!");
//}
//
//-(void)detectSitup
//{
//    NSNumber *power;
//    NSTimeInterval deltaT;
//    
//    NSLog(@"HDC: detectThread started!");
//    
//    while (_exitThread == NO) {
//        while (_pauseThread == NO) {
//            [NSThread sleepForTimeInterval:0.001];
//            while (_powerArray.count > 0) {
//                
//                power = (NSNumber*)[_powerArray objectAtIndex:0];
//                [_powerArray removeObjectAtIndex:0];
//                _curP = [power floatValue];
//                
//                _currentTime = [NSDate date];
//                if (_isDetected == YES) {
//                    deltaT = [_currentTime timeIntervalSinceDate:_detectedTime];
//                    _isDetected = (deltaT < _fMinDeltaTime)? YES : NO;
////                    NSLog(@"HDC: interval = %.2fs", deltaT);
//                }
//                
////                if (_curP -_preP > 3)
////                    NSLog(@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.logViewLbl setTextColor:[UIColor darkTextColor]];
//                    [self.logViewLbl setText:[NSString stringWithFormat:@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP]];
//                });
//                
//                if (_curP - _averageP > _fHighDeltaPower) {
//                    if (_isDetected == NO && _curP > _fMinPower && _curP - _preP > _fMidDeltaPower) {
//                        _isDetected = YES;
//                        _detectedTime = _currentTime;
//                        
//                        //reset pausetime
//                        _checkTime = _currentTime;
//                        
//                        //detected
//                        _showCount = YES;
////                        NSLog(@"HDC: _curP = %.0f _averageP = %.0f", _curP, _averageP);
////                        NSLog(@"HDC: _curP - _averageP = %.0f, _curP - _preP = %.0f", _curP - _averageP, _curP - _preP);
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.logViewLbl setTextColor:[UIColor redColor]];
//                            [self.logViewLbl setText:[NSString stringWithFormat:@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP]];
//                        });
//                    }
////                    else if (_curP - _preP > _fHighDeltaPower)
////                        NSLog(@"HDC:  %.0f   %.0f  %.0f   %.0f", _curP, _averageP, _curP - _averageP, _curP - _preP);
//                }
//                else if (_curP - _averageP < _fLowDeltaPower) {
//                    _averageP = (_averageP * _numberP + _curP) / (_numberP + 1);
//                    _numberP++;
//                }
//                _preP = _curP;
//                [NSThread sleepForTimeInterval:0.001];
//                
//            }
//        }
//    }
//    
//    NSLog(@"HDC: detectThread finished!");
//}

#pragma outlet functions

-(IBAction)closeTrainView:(id)sender
{
//    float max = _maxMag;
    
    _endTime = [NSDate date];
    _trainDuration = (int)[_endTime timeIntervalSinceDate:_beginTime];
    
    if (self.secondTimer) {
        [self.secondTimer invalidate];
        self.secondTimer = nil;
    }
    if (self.readyTimer) {
        [self.readyTimer invalidate];
        self.readyTimer = nil;
    }
    
    [self stopAudioFile];
    
    //LCVoice

    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 0.0f) {
            NSLog(@"LCRecord Result : %@", [NSString stringWithFormat:@"\nrecord finish ! \npath:%@ \nduration:%f",self.voice.recordPath,self.voice.recordTime]);
        }
        
    }];
    
    NSLog(@"%@%@", @"HDC : ", @"close Train...");
    
    if (self.nSitupCount > 0) {
        /*
         Add train result to localDB
         */
        [self updateLocalDB];
        /*
         Add train result to parseDB
         */
        [self updateSitupDB];
        
        /*
         Set need update ViewControllers
         */
        [MyUtils setNeedUpdateHistory:YES];
        [MyUtils setNeedUpdateWorkout:YES];
        [MyUtils setNeedUpdateBoard:YES];
        [MyUtils setNeedUpdateChallenge:YES];
    }
    else
        [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];

}

-(IBAction)muteSound:(id)sender
{
    if (self.isMute == NO) {
        self.isMute = YES;
        [self stopAudioFile];
        NSLog(@"%@%@", @"HDC : ", @"sound disabled...");
        [self.muteSoundBtn setImage: [UIImage imageNamed:@"sound_off.png"]];
    }
    else{
        self.isMute = NO;
        NSLog(@"%@%@", @"HDC : ", @"sound enabled...");
        [self.muteSoundBtn setImage: [UIImage imageNamed:@"sound_on.png"]];
    }
}

#pragma mark - Utility


-(NSURL*)testFilePathURL {
    NSLog(@"PATH : %@", [NSString stringWithFormat:@"%@/%@",
                         [MyUtils applicationDocumentsDirectory],
                         @"EZTest.wav"]);
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [MyUtils applicationDocumentsDirectory],
                                   @"EZTest.wav"]];
}

#pragma mark - LCVoiceDelegate


-(void)updatePWMeter:(float)peakPower count:(int) count
{
    if (_isPreparing) {
        _averageP = (_averageP * _numberP + peakPower) / (_numberP + 1);
        _numberP++;
        _preP = peakPower;
        NSLog(@"HDC: _numberP: %d, _averageP: %.0f", _numberP, _averageP);
    }
    else
    {
        NSLog(@"HDC: %.0f", peakPower);
        [_powerArray addObject:[NSNumber numberWithFloat:peakPower]];
        int n = 0;
        while (_isDetecting == YES) {
            n ++;
        }
        if (n > 0) {
            NSLog(@"HDC: updatePowerMeter is paused for %d times.", n);
        }
        [self detectSitup];
    }
    
    
    // Update the power domain plot
//    double peakPowerForChannel = pow(10, (0.05 * peakPower));
//    float power[1];
//    power[0] = peakPowerForChannel;
//    
//    [self.audioPlotPeak updateBuffer:power withBufferSize:1];
    
}



#pragma mark -AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.audioPlayer = NULL;
    self.isPlayingFile = NO;
    [self.voice resumeRecording];
    NSLog(@"HDC: VLVoice Recording resumed.");
}





#pragma file manage functions

- (void)createFileWithName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // 1st, This funcion could allow you to create a file with initial contents.
    // 2nd, You could specify the attributes of values for the owner, group, and permissions.
    // Here we use nil, which means we use default values for these attibutes.
    // 3rd, it will return YES if NSFileManager create it successfully or it exists already.
    if ([manager createFileAtPath:filePath contents:nil attributes:nil]) {
        NSLog(@"Created the File Successfully. Path:%@", filePath);
    } else {
        NSLog(@"Failed to Create the File");
    }
}

- (NSString *)readFileWithName:(NSString *)fileName
{
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Have the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // NSFileManager is the manager organize all the files on device.
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        // Start to Read.
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error];
        NSLog(@"File Content: %@", content);
        
        if (error) {
            NSLog(@"There is an Error: %@", error);
        }
        return content;
    } else {
        NSLog(@"File %@ doesn't exists", fileName);
        return NULL;
    }
}

- (void)writeString:(NSString *)content toFile:(NSString *)fileName
{
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Have the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // NSFileManager is the manager organize all the files on device.
    NSFileManager *manager = [NSFileManager defaultManager];
    // Check if the file named fileName exists.
    if ([manager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        // Since [writeToFile: atomically: encoding: error:] will overwrite all the existing contents in the file, you could keep the content temperatorily, then append content to it, and assign it back to content.
        // To use it, simply uncomment it.
        //        NSString *tmp = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:NSStringEncodingConversionAllowLossy error:nil];
        //        if (tmp) {
        //            content = [tmp stringByAppendingString:content];
        //        }
        // Write NSString content to the file.
        [content writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&error];
        // If error happens, log it.
        if (error) {
            NSLog(@"There is an Error: %@", error);
        }
    } else {
        // If the file doesn't exists, log it.
        NSLog(@"File %@ doesn't exists", fileName);
    }
    
    // This function could also be written without NSFileManager checking on the existence of file,
    // since the system will atomatically create it for you if it doesn't exist.
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
