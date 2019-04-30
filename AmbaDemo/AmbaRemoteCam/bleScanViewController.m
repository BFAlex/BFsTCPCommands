//
//  bleScanViewController.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import "bleScanViewController.h"

@interface bleScanViewController ()

@end

@implementation bleScanViewController

@synthesize  p, selectedP, pList;
@synthesize  bleViewObject;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ( [ambaStateMachine getInstance].bleMode == 0 ) {
        NSLog(@"Invoke CoreBluetooth:");
        [[ambaStateMachine getInstance] initBleManager];
        [self.connectBleButton setEnabled:NO];
    } else {
        //scan for BLE peripherals if not connected:
        if ( [ambaStateMachine getInstance].cameraBleMode == NO) {
            NSLog(@"DisConnected Mode");
            [[ambaStateMachine getInstance] startBleScan];
            [self.connectBleButton setEnabled:NO];
        }// else {
           // [[ambaStateMachine getInstance] startBleScan];
          //  [self.connectBleButton setEnabled:NO];
        //}
    }
    //Update Discovered BLE Peripheral Devices notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePeripheralList:)
                                                 name:foundNewPeripheralNotification
                                               object:[ambaStateMachine getInstance]];
}


- (void) updatePeripheralList:(NSNotificationCenter *)notificationParam
{
    //Enable Buttons
    self.p = [ambaStateMachine getInstance].peripheralNameList;
    self.pList = [ambaStateMachine getInstance].peripheralList;
    /*int i; //debug
     for ( i = 0 ; i < [self.p count]; i++) {
     NSLog(@"List of peripherals:%d . %@",i,self.p[i]);
     }*/
    [self.bleViewObject reloadData];
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

//----------Table View: list of Scanned BLE Peripherals----------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLEUITableView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BLEUITableView"];
    }
    cell.textLabel.text = [p objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [p count];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [ambaStateMachine getInstance].bleMode != NO) {
        //Try to connect to the selected Peripheral
        NSLog(@"Selected BLE Peripheral: %@", [self.p objectAtIndex:indexPath.row]);
        //[self.manager connectPeripheral:[self.peripheralData objectAtIndex:indexPath.row] options:nil];
        self.selectedP = [self.pList objectAtIndex:indexPath.row];
        [self.connectBleButton setEnabled:YES];
    }
}
//------------------------------------------------

- (IBAction)dismissBle:(id)sender {
    if (self.selectedP != nil) {
        [[ambaStateMachine getInstance] disconnectBlePeripheral];
    }
    //stop BLE scanning
    [[ambaStateMachine getInstance] stopBleScan];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restartBLEScan:(id)sender {
    [[ambaStateMachine getInstance] rescanBle];
    [self.p removeAllObjects];
    [self.pList removeAllObjects];
}

- (IBAction)stopBLEScan:(id)sender {
    [[ambaStateMachine getInstance] stopBleScan];
}

- (IBAction)connectBle:(id)sender {
    if (self.selectedP != nil) {
        NSLog(@"ViewController: Connecting to Peripheral %@", self.selectedP.name);
        [[ambaStateMachine getInstance] connectToBlePeripheral: self.selectedP];
    } else {
        NSLog(@"To Connect Select a Peripheral from TableView ");
    }
}


//- (IBAction)disconnectBle:(id)sender {
//    NSLog(@"ViewController :Event => disconnect");
//    [[ambaBleController getInstance] disconnectPeripheral];
//}
@end
