//
//  WifiBleViewController.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella 
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import "WifiBleViewController.h"

@interface WifiBleViewController ()

@end

@implementation WifiBleViewController
@synthesize cameraIPaddress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraIPaddress.text = @"192.168.42.1";
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

- (IBAction)dismissView:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setCameraWifiIPaddress:(id)sender {
    //Enable ComboMode Flag
    [ambaStateMachine getInstance].wifiBleComboMode = 1;
    //save camera IPAddress
    [ambaStateMachine getInstance].wifiIPParameters = (NSMutableString *) self.cameraIPaddress.text;
}
@end
