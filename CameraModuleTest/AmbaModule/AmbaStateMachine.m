//
//  AmbaStateMachine.m
//  RoadCam
//
//  Created by 刘玲 on 2019/4/28.
//  Copyright © 2019年 HSH. All rights reserved.
//

#import "AmbaStateMachine.h"
#import "AmbaController.h"

@interface AmbaStateMachine () <NSStreamDelegate> {
    
    unsigned int recvResponse;
    NSTimer   *jsonTimer;
    NSMutableString *tmpString;
}
@property (nonatomic, weak) AmbaController *controller;

@end

@implementation AmbaStateMachine

static AmbaStateMachine *machine;
static dispatch_once_t onceToken;

#pragma mark - API

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        machine = [[AmbaStateMachine alloc] init];
    });
    
    return machine;
}

- (void)destoryInstance {
    
    if (onceToken) {
        machine = nil;
        onceToken = 0;
    }
}

- (void)setupTargetController:(AmbaController *)pController {
    
    if ([pController isKindOfClass:[AmbaController class]]) {
        self.controller = (AmbaController *)pController;
    }
}

- (instancetype)init {
    
    if (self = [super init]) {
        [self configDefaultSetting];
    }
    
    return self;
}

- (void)initNetworkCommunication:(NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge  NSOutputStream *)writeStream;
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
    
    self.isTCPConnected = NO;
    self.sessionToken = [NSNumber numberWithInteger:0];
    self.wifiIPParameters = [NSMutableString stringWithFormat:@"%@",ipAddress];
}

- (NSInteger)writeDataToCamera:(id)obj andError:(NSError * _Nullable __autoreleasing *)error {
    NSLog(@"thread: %@", [NSThread currentThread]);
    if (self.isTCPConnected) {
        return [NSJSONSerialization writeJSONObject:obj toStream:self.outputStream options:kNilOptions error:error];
    } else {
        return 0;
    }
}

#pragma mark - Func

- (void)configDefaultSetting {
    
    self.sessionToken = @0;
    tmpString = [[NSMutableString alloc] init];
}


- (void)messageReceived:(NSString *)message
{
    if (_controller) {
        [self.controller handleReceivedResult:message];
    }

    recvResponse = 1;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"Connection with Camera: Open");
            [self sendUpdateConnectionStatusNotification:YES];
        }
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == self.inputStream) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *responseString = [[NSString alloc] initWithBytes:buffer
                                                                            length:len
                                                                          encoding:NSASCIIStringEncoding];
                        
                        //------handle Packet Framented return from camera
                        //TODO: Implement timeout if the string does'nt make it to App
                        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                       error:nil];
                        //Store the value in a global and append data string in next call check before we call messageReceived
                        if (!jsonResponse) {
                            [tmpString appendString:responseString];
                            
                            NSLog(@"Appending pkt Fragmented Data-> %@",tmpString);
                            
                            
                            data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
                            jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:nil];
                            if (jsonResponse){
                                recvResponse = 1;
                                [self messageReceived:tmpString];
                                //reset the tmpString to nothing
                                tmpString = [NSMutableString stringWithFormat:@""];
                                if (jsonTimer)
                                    [jsonTimer invalidate];
                            }
                        } else {
                            recvResponse = 1;
                            if (jsonTimer)
                                [jsonTimer invalidate];
                            
                            [self messageReceived:responseString];
                        }
                    }
                }
            }
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Can not connect to host!");
            [self sendUpdateConnectionStatusNotification:NO];
            // Invalidate the timer.
            if (jsonTimer)
                [jsonTimer invalidate];
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            NSLog(@"Error Writing to Network Stream!");
            [self sendUpdateConnectionStatusNotification:NO];
        }
            break;
            
        default:
            NSLog(@"UnKnown Event:");
            break;
    }
}

- (void)sendUpdateConnectionStatusNotification:(BOOL)isConnect {
    
    self.isTCPConnected = isConnect;
    //
    NSDictionary *notificationDict = [[NSDictionary alloc] init];
    NSNotification *notificationObject = [NSNotification  notificationWithName:kUpdateConnectionStatusNotification
                                                                        object:nil
                                                                      userInfo:notificationDict];
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

@end
