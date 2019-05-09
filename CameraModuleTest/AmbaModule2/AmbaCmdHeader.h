//
//  AmbaCmdHeader.h
//  CameraModuleTest
//
//  Created by 刘玲 on 2019/5/9.
//  Copyright © 2019年 BFs. All rights reserved.
//

#ifndef AmbaCmdHeader_h
#define AmbaCmdHeader_h

NSString  *tokenKey     = @"token";
NSString  *msgIdKey     = @"msg_id";
NSString  *typeKey      = @"type";
NSString  *offsetKey    = @"offset";
NSString  *featchSizeKey = @"fetch_size";
NSString *optionsKey    = @"options";
//Return keys
NSString *rvalKey = @"rval";
NSString *permissionKey = @"permission";
NSString *pwdKey = @"pwd";

//BiDirectional Key
NSString *paramKey = @"param";

//CommandStrings
NSString *startSessionCmd   = @"StartSession";
NSString *stopSessionCmd    = @"StopSession";
NSString *recordStartCmd    = @"RecStart";
NSString *recordStopCmd     = @"RecStop";
NSString *shutterCmd        = @"Shutter";
NSString *deviceInfoCmd     = @"deviceInfoCmd";
NSString *batteryLevelCmd   = @"batteryLevelCmd";
NSString *stopContPhotoSessionCmd = @"stopContPhotoSessionCmd";
NSString *recordingTimeCmd  = @"RecordingTime";
NSString *splitRecordingCmd = @"RecordingSplit";
NSString *stopVFCmd         = @"StopVF";
NSString *resetVFCmd        = @"ResetVF";
NSString *zoomInfoCmd       = @"zoomInfo";
NSString *setBitRateCmd     = @"BitRate";
NSString *startEncoderCmd   = @"StartEncoder";
NSString *changeSettingCmd  = @"ChangeSetting";
NSString *appStatusCmd      = @"uItronStat";
NSString *storageSpaceCmd   = @"storageSpace";
NSString *presentWorkingDirCmd = @"pwd";
NSString *listAllFilesCmd   = @"listAllFiles";
NSString *numberOfFilesInFolderCmd = @"numberOfFilesInFolderCmd";
NSString *changeToFolderCmd = @"changeFolder";
NSString *mediaInfoCmd      = @"mediaInfo";
NSString *getFileCmd        = @"getFile";
NSString *putFileCmd        = @"putFile";
NSString *stopGetFileCmd    = @"stopGetFile";
NSString *removeFileCmd     = @"removeFile";
NSString *fileAttributeCmd  = @"fileAttributeCmd";
NSString *formatSDMediaCmd  = @"formatSDMediaCmd";
NSString *allSettingsCmd    = @"allSettings";
NSString *getSettingValueCmd = @"getSettingValue";
NSString *getOptionsForValueCmd = @"getOptionsForValue";
NSString *setCameraParameterCmd = @"setCameraParamValue";
NSString *getThumbnailCmd = @"getThumbnailCmd";
NSString *sendCustomJSONCmd = @"sendCustomJSONCmd";
NSString *setClientInfoCmd  = @"setClientInfoCmd";
NSString *getWifiSettingsCmd = @"getWifiSettingsCmd";
NSString *setWifiSettingsCmd = @"setWifiSettingsCmd";
NSString *getWifiStatusCmd   = @"getWifiStatusCmd";
NSString *stopWifiCmd        = @"stopWifiCmd";
NSString *startWifiCmd       = @"startWifiCmd";
NSString *reStartWifiCmd     = @"reStartWifiCmd";
NSString *querySessionCmd    = @"querySessionCmd";
NSString *AMBALOGFILE    = @"AmbaRemoteCam.txt";


//command code thats msg_id number as per amba document
const unsigned int appStatusMsgId       = 1;
const unsigned int getSettingValueMsgId = 1;
const unsigned int setCameraParameterMsgId = 2;
const unsigned int allSettingsMsgId     = 3;
const unsigned int formatSDMediaMsgId   = 4;
const unsigned int storageSpaceMsgId    = 5;
const unsigned int numberOfFilesInFolderId = 6;
const unsigned int notificationMsgId    = 7;
const unsigned int getOptionsForValueMsgId = 9;
const unsigned int deviceInfoMsgId      = 11;
const unsigned int batteryLevelMsgId    = 13;
const unsigned int zoomInfoMsgId        = 15;
const unsigned int setBitRateMsgId      = 16;


const unsigned int startSessionMsgId    = 257;
const unsigned int stopSessionMsgId     = 258;
const unsigned int resetVFMsgId         = 259;
const unsigned int stopVFMsgId          = 260;
const unsigned int setClientInfoMsgId   = 261;


const unsigned int recordStartMsgId     = 513;
const unsigned int recordStopMsgId      = 514;
const unsigned int recordingTimeMsgId   = 515;
const unsigned int splitRecordingMsgId  = 516;

const unsigned int shutterMsgId         = 769;
const unsigned int stopContPhotoSessionMsgId = 770;
const unsigned int getThumbnailId       = 1025;
const unsigned int mediaInfoMsgId       = 1026;
const unsigned int fileAttributeMsgId   = 1027;

const unsigned int removeFileMsgId      = 1281;
const unsigned int listAllFilesMsgId    = 1282;
const unsigned int changeToFolderMsgId  = 1283;
const unsigned int presentWorkingDirMsgId = 1284;
const unsigned int getFileMsgId         = 1285;
const unsigned int putFileMsgId         = 1286;
const unsigned int stopGetFileMsgId     = 1287;

const unsigned int reStartWifiMsgId     = 1537;
const unsigned int setWifiSettingsMsgId = 1538;
const unsigned int getWifiSettingsMsgId = 1539;
const unsigned int stopWifiMsgId        = 1540;
const unsigned int startWifiMsgId       = 1541;
const unsigned int getWifiStatusMsgId   = 1542;
const unsigned int querySessionHolderMsgId = 1793;

const unsigned int sendCustomJSONMsgID = 99999999; //Select some random number for custom cmd.
//
//unsigned int STATUS_FLAG;
//unsigned int recvResponse;

#endif /* AmbaCmdHeader_h */
