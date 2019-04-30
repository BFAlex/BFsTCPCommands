//
//  fileUpload.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fileUpload :NSObject  <NSStreamDelegate>
{
    NSInputStream *dataInStream;
    NSOutputStream *dataOutStream;
}
@property (nonatomic, retain) NSInputStream *inputDataStream;
@property (nonatomic, retain) NSOutputStream *outputDataStream;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, retain) NSMutableString *wifiParameters;
//@property (nonatomic, retain) NSMutableString *notifyMsg;
//@property (atomic, retain) NSNumber *connected;

- (void) initDataCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo;
+ (fileUpload *) fileUploadInstance;
- (void) putFileToCamera: (NSString *)fileName :(NSInteger)fileSize :(NSString *)md5sum :(NSInteger)offset;
- (void) closeTCPConnection;
@end
