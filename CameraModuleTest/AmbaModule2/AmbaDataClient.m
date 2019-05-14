//
//  AmbaFileManager.m
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/8.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "AmbaDataClient.h"

@interface AmbaDataClient () <NSStreamDelegate>
{
    NSInputStream *dataInStream;
    NSOutputStream *dataOutStream;
    
//    int downloadFlag;
    long _downloadedSize;
    DownloadingBlock _downloadingBlock;
    NSString *_downloadedFilePath;
}
@property (nonatomic, retain) NSInputStream *inputDataStream;
@property (nonatomic, retain) NSOutputStream *outputDataStream;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, retain) NSMutableString *wifiParameters;
@property (nonatomic, retain) NSFileManager *manager;
@property (nonatomic) NSFileHandle  *fileHandle;

@end

@implementation AmbaDataClient

static AmbaDataClient *dataClient;
static dispatch_once_t onceToken;

#pragma mark - API

+ (instancetype)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        dataClient = [[AmbaDataClient alloc] init];
    });
    
    return dataClient;
}
- (void)destoryInstance {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (onceToken > 0) {
        [self closeFileDownloadConnection];
        dataClient = nil;
        onceToken = 0;
    }
}
- (void)dealloc {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

//- (void)initDataCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName {
//    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//
//    CFReadStreamRef readStream;
//    CFWriteStreamRef writeStream;
//    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
//
//    dataInStream = (__bridge NSInputStream *)readStream;
//    dataOutStream = (__bridge  NSOutputStream *)writeStream;
//    [dataInStream setDelegate:self];
//    [dataOutStream setDelegate:self];
//    [dataInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//
//    self.wifiTCPConnectionStatus = 0;
//    [dataInStream open];
//    [dataOutStream open];
//
//    NSLog(@"File Download @ %@ : %lu OPEN", ipAddress, (long)tcpPortNo);
//    [self.wifiParameters appendString:ipAddress];
//    //
//    [self createrRelativeLocalFile:fileName];
//}
- (void)connectToDataService:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    //
    dataInStream = (__bridge NSInputStream *)readStream;
    dataOutStream = (__bridge  NSOutputStream *)writeStream;
    [dataInStream setDelegate:self];
    [dataOutStream setDelegate:self];
    [dataInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //
    [dataInStream open];
    [dataOutStream open];
    
    NSLog(@"File Download @ %@ : %lu OPEN", ipAddress, (long)tcpPortNo);
}

- (void)closeTheConnectionToDataServer {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [dataOutStream close];
    [dataInStream close];
    [dataOutStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [dataInStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    dataInStream = nil;
    dataOutStream = nil;
}

- (void)downloadFile:(NSString *)fileName downloadingBlock:(DownloadingBlock)downloadingBlock andReturnBlock:(ReturnBlock)block {
    
    _downloadedFilePath = [self createLocalTargetFile:fileName fileIsThumbnail:NO];
    _downloadedSize = 0;
    _downloadingBlock = downloadingBlock;
    if (block) {
        block(nil, 0, nil, ResultTypeNone);
    }
}

- (void)closeFileDownloadConnection {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Demo停止下载的操作是直接关闭流...
//    [dataInStream close];
//    [dataOutStream close];
//    downloadFlag = 1;
}

- (void)prepareToGetThumbnailOfFile:(NSString *)fileName {
    //
    _downloadedFilePath = [self createLocalTargetFile:fileName fileIsThumbnail:YES];
}

- (NSString *)getDownloadFilePath {
    return _downloadedFilePath;
}

#pragma mark - Func

- (NSString *)createLocalTargetFile:(NSString *)fileName fileIsThumbnail:(BOOL)isThumbnail {
    
    NSString *filePath;
    if (isThumbnail) {
        filePath = [self createLocalThumbnailFile:fileName];
    } else {
        filePath = [self createrLocalDownloadFile:fileName];
    }
    
    return filePath;
}

- (NSString *)createrLocalDownloadFile:(NSString *)fileName {
    //Open File To save Only if its Image
    NSString *filePath;
    if ([[fileName pathExtension] isEqualToString:@"jpg"] || [[fileName pathExtension] isEqualToString:@"JPG"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Files"]];
        filePath = [fileFolder stringByAppendingPathComponent:[fileName lastPathComponent]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else if ([[fileName pathExtension] isEqualToString:@"mp4"] || [[fileName pathExtension] isEqualToString:@"MP4"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Files"]];
        filePath = [fileFolder stringByAppendingPathComponent:[fileName lastPathComponent]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    return filePath;
}

- (NSString *)createLocalThumbnailFile:(NSString *)fileName {
    //
    NSString *filePath;
    if ([[fileName pathExtension] isEqualToString:@"jpg"] || [[fileName pathExtension] isEqualToString:@"JPG"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Files"]];
        filePath = [fileFolder stringByAppendingPathComponent:[fileName lastPathComponent]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else if ([[fileName pathExtension] isEqualToString:@"mp4"] || [[fileName pathExtension] isEqualToString:@"MP4"])
    {
        NSString *fileFolder = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[@"Thumbnail"]];
        NSString *fName = [[[fileName lastPathComponent] componentsSeparatedByString:@"."] firstObject];
        filePath = [fileFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.JPG", fName]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    return filePath;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"[%@ %@] %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)eventCode);
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Data Client(%@) Connection with Camera: Open", NSStringFromClass([aStream class]));
//            downloadFlag = 1;
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"[%@]8787 stream receive data", NSStringFromClass([self class]));
            if (aStream == dataInStream) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([dataInStream hasBytesAvailable]) {
                    NSLog(@"*..*");
                    len = [dataInStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        _downloadedSize += len;
                        NSLog(@"已经下载文件:%ld", _downloadedSize);
                        NSString *responseString = [[NSString alloc] initWithBytes:buffer
                                                                            length:len
                                                                          encoding:NSASCIIStringEncoding];
                        if (nil != responseString) {
//                            if (downloadFlag) {
                                if (self.fileHandle != nil) {
                                    NSData *buff = [[NSData alloc] initWithBytes:buffer length:len];
                                    [self.fileHandle seekToEndOfFile];
                                    [self.fileHandle writeData:buff];
                                    //                                    
                                    if (_downloadingBlock) {
                                        _downloadingBlock(self, [NSString stringWithFormat:@"%ld", _downloadedSize], nil);
                                    }
//                                }
//                                downloadFlag = 1;
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
            NSLog(@"[%@]Close Stream(%@)", NSStringFromClass([self class]), NSStringFromClass([aStream class]));
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            [self.fileHandle closeFile];
//            downloadFlag = 0;
            break;
            
        default:
            break;
    }
}

@end
