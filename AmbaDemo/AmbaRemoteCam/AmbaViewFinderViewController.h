//
//  AmbaViewFinderViewController.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"
#import "constants.h"
#import "AmbaRTSPPlayer.h"

@class AmbaRTSPPlayer;

@interface AmbaViewFinderViewController : UIViewController<UIAlertViewDelegate>
{
    IBOutlet UIImageView *rtspView;
    AmbaRTSPPlayer       *video;
    float lastFrameTime;
}

@property (nonatomic, retain) AmbaRTSPPlayer    *video;
- (IBAction)shutterCmd:(id)sender;
- (IBAction)stopContShutter:(id)sender;
- (IBAction)startRec:(id)sender;
- (IBAction)stopRec:(id)sender;

- (IBAction)splitRecord:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *splitRecButton;
@property (retain, nonatomic) IBOutlet UIImageView *rtspView;

- (IBAction)reloadViewFinder:(id)sender;
- (IBAction)closeViewFinderView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *returnStatusTextLabel;

@end
