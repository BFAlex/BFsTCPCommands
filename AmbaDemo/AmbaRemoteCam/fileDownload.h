//
//  fileDownload.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileDownload : NSObject  <NSStreamDelegate>
{
    NSInputStream *dataInStream;
    NSOutputStream *dataOutStream;
}



@property (nonatomic, retain) NSInputStream *inputDataStream;
@property (nonatomic, retain) NSOutputStream *outputDataStream;
//@property (nonatomic, retain) NSMutableArray *messages;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, retain) NSMutableString *wifiParameters;
//@property (nonatomic, retain) NSMutableString *notifyMsg;
//@property (atomic, retain) NSNumber *connected;
@property (nonatomic, retain) NSFileManager *manager;
@property (nonatomic) NSFileHandle  *fileHandle;

- (void) initDataCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName;
+ (fileDownload *) fileDownloadInstance;
- (void) closeFileDownloadConnection;
- (void) closeTCPConnection;
@end
