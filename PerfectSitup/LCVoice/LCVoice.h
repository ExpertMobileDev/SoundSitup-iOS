//
//  LCVoice.h
//  LCVoiceHud
//
//  Created by 郭历成 on 13-6-21.
//  Contact titm@tom.com
//  Copyright (c) 2013年 Wuxiantai Developer Team.(http://www.wuxiantai.com) All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol LCVoiceDelegate <NSObject>

@optional

-(void)updatePWMeter:(float)peakPower count:(int) count;

@end


@interface LCVoice : NSObject

@property(nonatomic, strong) id<LCVoiceDelegate> lcvoiceDelegate;

@property(nonatomic,retain) NSString * recordPath;
@property(nonatomic) float recordTime;

-(void) startRecordWithPath:(NSString *)path;
-(void) stopRecordWithCompletionBlock:(void (^)())completion;
-(void) cancelled;
-(void) pauseRecording;
-(void) resumeRecording;
@end
