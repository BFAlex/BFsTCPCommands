//
//  fileDownload.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import "fileDownload.h"
unsigned int downloadFlag;


@implementation fileDownload

static fileDownload *fileDLinstance = nil;
@synthesize manager,fileHandle;

- (void) initDataCommunication:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName
{
    
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
        NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
        NSString    *documentsDirectory = [paths objectAtIndex:0];
        NSString    *localFileName = [fileName lastPathComponent];// stringByDeletingPathExtension];
       //// NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:@"amba.jpg"];
        NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",localFileName]];

        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } else if ([[fileName pathExtension] isEqualToString:@"mp4"] || [[fileName pathExtension] isEqualToString:@"MP4"])
    {
        NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
        NSString    *documentsDirectory = [paths objectAtIndex:0];
        NSString    *localFileName = [fileName lastPathComponent];// stringByDeletingPathExtension];
        ////NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:@"amba.mp4"];
        NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",localFileName]];
        self.manager = [NSFileManager defaultManager];
        [self.manager createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"creating download File at: %@",filePath);
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }

}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
     NSLog(@"[%@ %@] %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)streamEvent);
    switch (streamEvent)
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

- (void) closeFileDownloadConnection
{
    NSLog(@" close download Port!!");

    [dataInStream close];
    [dataOutStream close];
    downloadFlag = 1;
}
+ (fileDownload *) fileDownloadInstance{
    @synchronized (self)
    {
        if (!fileDLinstance)
        {
            fileDLinstance = [[fileDownload alloc] init];
        }
        return fileDLinstance;
    }
    return  nil;
}
- (void) closeTCPConnection
{
    [dataOutStream close];
    [dataInStream close];
    dataInStream = nil;
    dataOutStream = nil;
}
@end
