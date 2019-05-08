//
//  AmbaFileManager.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/8.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaFileManager.h"

@interface AmbaFileManager () <NSStreamDelegate>
{
    NSInputStream *dataInStream;
    NSOutputStream *dataOutStream;
    
    int downloadFlag;
}
@property (nonatomic, retain) NSInputStream *inputDataStream;
@property (nonatomic, retain) NSOutputStream *outputDataStream;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, retain) NSMutableString *wifiParameters;
@property (nonatomic, retain) NSFileManager *manager;
@property (nonatomic) NSFileHandle  *fileHandle;

@end

@implementation AmbaFileManager

static AmbaFileManager *manager;
static dispatch_once_t onceToken;

#pragma mark - API

+ (instancetype)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        manager = [[AmbaFileManager alloc] init];
    });
    
    return manager;
}
- (void)destoryInstance {
    if (onceToken > 0) {
        manager = nil;
        onceToken = 0;
    }
}

- (void)initDataCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    
    dataInStream = (__bridge NSInputStream *)readStream;
    dataOutStream = (__bridge  NSOutputStream *)writeStream;
    [dataInStream setDelegate:self];
    [dataOutStream setDelegate:self];
    [dataInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.wifiTCPConnectionStatus = 0;
    [dataInStream open];
    [dataOutStream open];
    
    NSLog(@"File Download @ %@ : %lu OPEN", ipAddress, (long)tcpPortNo);
    [self.wifiParameters appendString:ipAddress];
    //Open File To save Only if its Image
    if ([[fileName pathExtension] isEqualToString:@"jpg"] || [[fileName pathExtension] isEqualToString:@"JPG"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Files"]];
        NSString *filePath = [fileFolder stringByAppendingPathComponent:[fileName lastPathComponent]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else if ([[fileName pathExtension] isEqualToString:@"mp4"] || [[fileName pathExtension] isEqualToString:@"MP4"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Files"]];
        NSString *filePath = [fileFolder stringByAppendingPathComponent:[fileName lastPathComponent]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
}

- (void)closeFileDownloadConnection {
    NSLog(@" close download Port!!");
    
    [dataInStream close];
    [dataOutStream close];
    downloadFlag = 1;
}

- (void)closeTCPConnection {
    
    [dataOutStream close];
    [dataInStream close];
    dataInStream = nil;
    dataOutStream = nil;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"[%@ %@] %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)eventCode);
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Data Connection with Camera: Open");
            //[self ambaLogString:@"WiFi Connection With Camera Open" toFile:AMBALOGFILE];
            downloadFlag = 1;
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == dataInStream) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([dataInStream hasBytesAvailable]) {
                    NSLog(@"*..*");
                    len = [dataInStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *responseString = [[NSString alloc] initWithBytes:buffer
                                                                            length:len
                                                                          encoding:NSASCIIStringEncoding];
                        NSLog(@"[%@]:%@", NSStringFromClass([self class]), responseString);
                        if (nil != responseString) {
                            if (downloadFlag) {
                                //NSLog(@"Start Data Transfer from Camera >");
                                if (self.fileHandle != nil) {
                                    NSData *buff = [[NSData alloc] initWithBytes:buffer length:len];
                                    [self.fileHandle seekToEndOfFile];
                                    [self.fileHandle writeData:buff];
                                }
                                downloadFlag = 1;
                            }
                        }
                    }
                }
            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"Unable to connect to Data Port 8787!");
            break;
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            [self.fileHandle closeFile];
            downloadFlag = 0;
            break;
            
        default:
            break;
    }
}

@end
