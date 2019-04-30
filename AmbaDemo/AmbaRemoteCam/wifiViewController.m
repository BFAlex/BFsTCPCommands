//
//  wifiViewController.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import "wifiViewController.h"

@interface wifiViewController ()

@end

@implementation wifiViewController
@synthesize cameraControlPanelButton, tcpConnectButton,conStatusLabel;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.conStatusLabel.text = [NSString stringWithFormat:@"" ];
    if (self.cameraIPAddress != NULL) {
        self.defaultIP = [[NSMutableArray alloc] init];
        [self.defaultIP addObject:@"192.168.42.1"];
        self.cameraIPAddress.text = [self.defaultIP objectAtIndex:0];
        NSLog(@"Default IPAddress %@", [self.defaultIP objectAtIndex:0]);
    } else {
        self.cameraIPAddress.text = @"192.168.42.1";
    }
    [self.cameraControlPanelButton setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noConnectionStatus:)
                                                 name:noConnectionStatusNotification
                                               object:[ambaStateMachine getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatus:)
                                                 name:connectionStatusNotification
                                               object:[ambaStateMachine getInstance]];
    
}


- (void) connectionStatus:(NSNotificationCenter *)notificationParam {    
    [self.tcpConnectButton setHidden:YES];
    [self.tcpConnectButton setEnabled:NO];
    self.conStatusLabel.text = [NSString stringWithFormat:@"TCP Connection: OK" ];


    [self.cameraControlPanelButton setHidden:NO];
    [self.cameraControlPanelButton setEnabled:YES];
}

- (void) noConnectionStatus:(NSNotificationCenter *)notificationParam
{
    NSLog(@"Camera Not Answering Connection Request");
    
    [[[UIAlertView alloc] initWithTitle:@"Connection To Camera: Lost"
                                message:@"Please Check the Wifi Setting and Try Again"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    // Change View to parent View Controller
    [self dismiss:self.view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) connectToCamera:(id)sender {
    
    [[ambaStateMachine getInstance] initNetworkCommunication:self.cameraIPAddress.text tcpPort: 7878];

}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldReturn : (id)sender
{
    //Done/Return Press = hide keyboard
    [sender resignFirstResponder];
}

@end
