//
//  serviceCharacteristicsViewController.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import "serviceCharacteristicsViewController.h"

static float progressCount = 0.0f;

@interface serviceCharacteristicsViewController ()

@end

@implementation serviceCharacteristicsViewController

@synthesize progressView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([ambaStateMachine getInstance].cameraBleMode == YES) {
        //if connected to a BLE device Enable AmbaCameraControl  button
        [self.startAmbaBleSessionButton setEnabled:YES];
    } else {
        [self.startAmbaBleSessionButton setEnabled:NO];
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.tintColor = [UIColor redColor];
        self.progressView.trackTintColor = [UIColor lightGrayColor];
        
        self.progressView.frame = CGRectMake(63,243,200,40);
        //rescale the UIProgressView
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5f,4.0f);
        self.progressView.transform = transform;
        [self.view addSubview:self.progressView];
    }
    //Notification TO update the selected Service/Characteristics  UUID and enable AmbaCameraControl Button
    //When BLE device is connected and discovered the relavent Service/Char UUIDs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUUIDList:)
                                                 name:foundUUIDNotification
                                               object:[ambaStateMachine getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressBar:)
                                                 name:progressBarNotification
                                               object:[ambaStateMachine getInstance]];
}

//- (void) viewDidAppear:(BOOL)animated
//{
//    if ([ambaStateMachine getInstance].cameraBleMode == NO){
//        [self.startAmbaBleSessionButton setEnabled:NO];
//        NSLog(@"serviceCharacteristicsView: view did appear");
//    }
//}

- (void) updateProgressBar:(NSNotificationCenter *)notificationParam
{
    
    progressCount = progressCount + 0.25;
    self.progressView.progress = (float)progressCount;
}
- (void) updateUUIDList:(NSNotificationCenter *)notificationParam
{
    self.selectedServiceUUID.text = AMBA_RAPTOR1_SERVICE_UUID;
    self.ambaWriteCharacteristicUUID.text = AMBA_JSON_SEND_CHARCTERISTIC;
    self.ambaReadCharacteristicUUID.text = AMBA_JSON_RECV_CHARCTERISTIC;
    [self.startAmbaBleSessionButton setEnabled:YES];
    //PopUp a notification of Connection Success
    
    /*[[[UIAlertView alloc] initWithTitle:@"Connection To Ambarella Remote Cam: "
                                message:@"BLE Connection Status: OK"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startAmbaBleSession:(id)sender {
    NSLog(@"Starting Ambarella BLE Remote Camera Control Mode:");
}

- (IBAction)cancelBleConnectedDevice:(id)sender {
    if ([ambaStateMachine getInstance].cameraBleMode ) {
        [[ambaStateMachine getInstance] disconnectBlePeripheral];
    } else {
        NSLog(@"Central Not connected to any Peripheral");
    }
    [self.presentingViewController dismissViewControllerAnimated:NO
                                                      completion:nil];
}
@end
