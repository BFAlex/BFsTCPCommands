//
//  WifiBleViewController.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella 
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"

@interface WifiBleViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *cameraIPaddress;
- (IBAction)dismissView:(id)sender;
- (IBAction)setCameraWifiIPaddress:(id)sender;

@end
