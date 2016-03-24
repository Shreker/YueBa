//
//  ChatBottomView.h
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunctionView.h"

typedef enum{
    MessageBarButtonTypeAdd=1,//+
    MessageBarButtonTypeFace,//表情
    MessageBarButtonTypeVoice,//语音
    MessageBarButtonTypeSend//发送
}MessageBarButtonType;

@protocol MessageBarDelegate <NSObject>
@optional
-(void)updateTableViewHeight;

-(void)prepareToRecordVoiceWithCompletion:(BOOL (^)(void))completion;
-(void)didStartRecording;
-(void)didPauseRecording;
-(void)didContinueRecording;
-(void)didCancelRecording;
-(void)didFinishRecording;
@end

@interface MessageBar : UIView 
@property (nonatomic) id<MessageBarDelegate, QYFunctionViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) NSMutableArray *selectedFaces;


@end
