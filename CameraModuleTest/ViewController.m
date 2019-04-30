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
        NSLog(@"tcp连接结果: %@", result);
    }];
}
- (IBAction)actionSessionBtn:(UIButton *)sender {
    
    [_ambaController startSession:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"开启会话结果: %@", resultStr);
        
        [self actionSettingBtn:nil];
    }];
}
- (IBAction)actionDisconnectBtn:(UIButton *)sender {
    [_ambaController disconnectFromCamera:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSLog(@"断开连接...");
    }];
}
- (IBAction)actionTakePhotoBtn:(UIButton *)sender {
    [_ambaController takePhoto:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"拍照结果: %@", resultStr);
    }];
}
- (IBAction)actionStartRecordBtn:(UIButton *)sender {
    [_ambaController startRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"开启录制结果: %@", resultStr);
    }];
}
- (IBAction)actionStopRecordBtn:(UIButton *)sender {
    [_ambaController stopRecord:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"关闭录制结果: %@", resultStr);
    }];
}
- (IBAction)actionSettingBtn:(UIButton *)sender {
    [_ambaController currentMachineStatus:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"setting结果: %@", resultStr);
    }];
}
- (IBAction)actionFormatSDBtn:(UIButton *)sender {
    [_ambaController formatSDCard:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"Format SD 结果: %@", resultStr);
    }];
}
- (IBAction)actionListAllFiles:(UIButton *)sender {
    [_ambaController listAllFiles:^(NSError *error, NSUInteger cmd, id result, ResultType type) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), result);
        NSString *resultStr = error ? error.description : @"成功";
        NSLog(@"List All Files结果: %@", resultStr);
    }];
}

@end
