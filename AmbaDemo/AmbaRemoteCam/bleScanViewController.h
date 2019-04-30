//
//  bleScanViewController.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"

@interface bleScanViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *bleViewObject;
@property (nonatomic, retain) NSMutableArray  *p;  // Peripheral Name list
@property (nonatomic, retain) NSMutableArray  *pList; // List of found peripherals
@property (nonatomic, retain) CBPeripheral  *selectedP; //selectedPeripheral
@property (strong, nonatomic) IBOutlet UIButton *connectBleButton;



- (IBAction)dismissBle:(id)sender;
- (IBAction)restartBLEScan:(id)sender;
- (IBAction)stopBLEScan:(id)sender;
- (IBAction)connectBle:(id)sender;
//- (IBAction)disconnectBle:(id)sender;
@end
