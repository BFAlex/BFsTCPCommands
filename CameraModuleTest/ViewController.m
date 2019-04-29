//
//  ViewController.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/4/29.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "ViewController.h"
#import "AmbaController.h"

@interface ViewController ()
@property (nonatomic, strong) AmbaController *ambaController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _ambaController = [[AmbaController alloc] init];
}

- (IBAction)actionConnectBtn:(UIButton *)sender {
    
    [_ambaController connectToCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"tcp 连接会话结果：%@", !error?@"成功":error.description);
    }];
}
- (IBAction)actionSessionBtn:(UIButton *)sender {
    
    for (int i = 0; i < 20; i++) {
        [_ambaController startSession];
        NSLog(@"???: %d", i);
    }
}
- (IBAction)actionDisconnectBtn:(UIButton *)sender {
    [_ambaController disconnectFromCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
    }];
}

@end
