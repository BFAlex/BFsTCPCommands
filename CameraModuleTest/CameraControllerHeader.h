//
//  CameraControllerHeader.h
//  LIGO
//
//  Created by Boris on 2017/3/24.
//  Copyright © 2017年 HSH. All rights reserved.
//

#ifndef CameraControllerHeader_h
#define CameraControllerHeader_h

typedef enum : NSUInteger {
    CameraTypeNovatek,
    CameraTypeSunplus,
    CameraTypeAllwinner,
    CameraTypeGoplus,
    CameraTypeTima,
    CameraTypeAit,
    CameraTypeMaxNumber
} CameraType;

typedef enum : NSUInteger {
    ResultTypeNone,
    ResultTypeStatus,
    ResultTypeValue,
    ResultTypeList,
    ResultTypeMaxNumber
} ResultType;

typedef enum : NSUInteger {
    CameraModePhoto,
    CameraModeMovie,
    CameraModePlayback,
    CameraModeMaxNumber
} CameraMode;


typedef void (^ReturnBlock)(NSError *error, NSUInteger cmd, id result, ResultType type);

#endif /* CameraControllerHeader_h */
