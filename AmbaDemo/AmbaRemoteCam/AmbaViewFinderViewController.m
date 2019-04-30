//
//  AmbaViewFinderViewController.m
//  AmbaRemoteCam
//
///  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import "AmbaViewFinderViewController.h"

unsigned int timerFlag; // 0 - stop rtsp view 1 - restart view
unsigned int notificationCount;

@interface AmbaViewFinderViewController ()
@property (nonatomic, retain) NSTimer   *nextFrameTimer;
@end

@implementation AmbaViewFinderViewController

@synthesize rtspView, video;
@synthesize nextFrameTimer = _nextFrameTimer;


- (void)viewDidLoad {
    [super viewDidLoad];
    timerFlag = 1;
    notificationCount = 0;
    
    // Do any additional setup after loading the view.
    // First we reset the view finder to enable the live View
    ////[[ambaStateMachine getInstance] cameraResetViewFinder];
    
    //Init RTSP play only if Wifi is present
    if ([ambaStateMachine getInstance].wifiBleComboMode || [ambaStateMachine getInstance].networkModeWifi)
    {
        if (!video) {
            NSLog(@"RTSP Play URL = rtsp://192.168.42.1/live");
           // video = [[AmbaRTSPPlayer alloc] initWithVideo:@"rtsp://192.168.42.1/live" usesTcp:NO decodeAudio:NO];
            video = [[AmbaRTSPPlayer alloc] initWithVideo:@"rtsp://192.168.42.1/live" usesTcp:NO decodeAudio:NO];
            video.outputHeight = 640;//176;//426;
            video.outputWidth = 352;//320;//320;
            //Debug:
            NSLog(@"Source Video Width:Height = %d x %d", video.sourceWidth, video.sourceHeight);
            //Start viewFinder
            
            [self startViewFinder];
        } else {
            [self startViewFinder];
        }
        
    } else {
        self.returnStatusTextLabel.text = @"BLE: VF no Support";
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(unableToFindRTSPStream:)
                                                 name: unableToFindRTSPStreamNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateCommandReturnStatus:)
                                                 name: updateCommandReturnStatusNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(querySessionHolder:)
                                                 name:querySessionHolderNotification
                                               object:nil];
    
}

- (void) querySessionHolder: (NSNotification *)notificationParam
{
    if ([ ambaStateMachine getInstance].notificationCount ){
        
        UIAlertView *jsonDebugAlert = [[UIAlertView alloc] initWithTitle:@"Last Command Response:"
                                                                 message: [ambaStateMachine getInstance].notifyMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"RetainSession"
                                                       otherButtonTitles:@"logout", nil];
        [jsonDebugAlert show];
        
        [ ambaStateMachine getInstance].notificationCount = 0;
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //NSLog(@"#############CancelButton Was Activated");
        NSLog(@"LogOut button Selected");
    } else {
        [[ambaStateMachine getInstance ] keepSessionActive];
    }
}


- (void) unableToFindRTSPStream:(NSNotificationCenter *)notificationParam
{
    NSLog(@"Unable to Find RTSP Stream Server:");
    
    [[[UIAlertView alloc] initWithTitle:@"Fail: RTSP Server Connect "
                                message:@"Check stream_out_type set to 'rtsp' \n or \n reset vf"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateCommandReturnStatus: (NSNotification *)notificationParam
{
    if ( [ambaStateMachine getInstance].commandReturnValue == 0 )
        self.returnStatusTextLabel.text = [NSString stringWithFormat:@"%@ Success",self.returnStatusTextLabel.text];    else if ([ambaStateMachine getInstance].commandReturnValue < 0)
        self.returnStatusTextLabel.text = [NSString stringWithFormat:@"%@ FAIL",self.returnStatusTextLabel.text];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) startViewFinder
{
    lastFrameTime = -1;
    //Seek if we are doing play-back rtsp stream
    //[video seekTimer:0.0]; //move to video time 0.0
    [_nextFrameTimer invalidate];
    
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}
#define LERP(A,B,C)     ((A)*(1.0-C)+(B)*C)
- (void) displayNextFrame:(NSTimer *)timer
{
    if(timerFlag == 0)
    {
        [timer invalidate];
        timer = nil;
        return;
    }
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![video stepFrame])
    {
        [timer invalidate];
        //[video closeAudio];
        NSLog(@"DBG: video stepFrame failed");
        //release video class instance
        video = nil;
        //Pop Notification to user to double check vf is enable and stream_type is set to rtsp
        if (notificationCount == 0){
            NSNotification *notificationObject = [NSNotification notificationWithName:unableToFindRTSPStreamNotification
                                                                           object:self
                                                                         userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        }
        return;
    }
    rtspView.image = video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (lastFrameTime < 0) {
        lastFrameTime = frameTime;
    } else {
        lastFrameTime = LERP(frameTime,lastFrameTime, 0.8);
    }
}
- (IBAction)shutterCmd:(id)sender {
    self.returnStatusTextLabel.text = @"Take Photo:";
    [[ambaStateMachine getInstance] takePhoto];
}

- (IBAction)stopContShutter:(id)sender {
    self.returnStatusTextLabel.text = @"Stop Cont..Photo:";
    NSLog(@"To Implement the command in StateMachine");
    [[ambaStateMachine getInstance] stopContPhotoSession];
}

- (IBAction)startRec:(id)sender {
    self.returnStatusTextLabel.text = @"Start Record:";
    [[ambaStateMachine getInstance] cameraRecordStart];
}

- (IBAction)stopRec:(id)sender {
    self.returnStatusTextLabel.text = @"Stop Rec:";
    [[ambaStateMachine getInstance] cameraRecordStop];
}

- (IBAction)splitRecord:(id)sender {
    self.returnStatusTextLabel.text = @"Split Recording:";
     [[ambaStateMachine getInstance] cameraSplitRecording];
}
- (IBAction)reloadViewFinder:(id)sender {
     //NSLog(@"To Implement the command in StateMachine");
    self.returnStatusTextLabel.text = @"Reset ViewFinder:";
    [[ambaStateMachine getInstance] cameraResetViewFinder];
    [self performSelector:@selector(reloadView) withObject:self afterDelay:3.0];
    [_nextFrameTimer invalidate];
}

- (void) reloadView
{
    NSLog(@"reload view");
    [self viewDidLoad];
}


- (IBAction)closeViewFinderView:(id)sender {
    //Stop RTSP Decoding
    self.returnStatusTextLabel.text = @"ViewFinder:close view";
    notificationCount = 1;
    [video stopRTSPDecode];
    [self.presentingViewController dismissViewControllerAnimated:NO
                                                      completion:nil];
}
@end
