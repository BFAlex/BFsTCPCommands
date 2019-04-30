//
//  serviceCharacteristicsViewController.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"


@interface serviceCharacteristicsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *selectedServiceUUID;
@property (strong, nonatomic) IBOutlet UITextField *ambaWriteCharacteristicUUID;
@property (strong, nonatomic) IBOutlet UITextField *ambaReadCharacteristicUUID;
@property (strong, nonatomic) IBOutlet UIButton *startAmbaBleSessionButton;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;


- (IBAction)startAmbaBleSession:(id)sender;
- (IBAction)cancelBleConnectedDevice:(id)sender;

//- (void) startProgress;

@end
