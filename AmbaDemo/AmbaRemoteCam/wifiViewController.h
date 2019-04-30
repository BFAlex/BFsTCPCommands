//
//  wifiViewController.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"

@interface wifiViewController : UIViewController
@property (retain, nonatomic) NSMutableArray *defaultIP;
@property (retain, nonatomic) IBOutlet UITextField *cameraIPAddress;
@property (nonatomic) IBOutlet UIButton *tcpConnectButton;
@property (nonatomic) IBOutlet UIButton *cameraControlPanelButton;
@property (nonatomic) IBOutlet UILabel *conStatusLabel;

- (IBAction) connectToCamera:(id)sender;
- (IBAction) dismiss:(id)sender;

- (IBAction) textFieldReturn:(id)sender;

@end
