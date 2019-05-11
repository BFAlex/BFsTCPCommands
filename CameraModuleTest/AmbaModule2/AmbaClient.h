//
//  AmbaClient.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AmbaClient;
typedef void (^DownloadingBlock)(AmbaClient *client, NSString *downloadingSize, NSString *totalSize);

NS_ASSUME_NONNULL_BEGIN

@interface AmbaClient : NSObject

@end

NS_ASSUME_NONNULL_END
