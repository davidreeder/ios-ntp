//
// MOSLog.h
//
//---------------------------------------------------------------------
//     Copyright (C) 2014 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define MOS_VERSION_LOG  0.6



//---------------------------------------------------- -o-
#define MOS_LOG_ENABLED        YES 


//
#define MOS_CLASS_AND_METHOD  \
    [NSString stringWithFormat:@"%@ :: %@", [self class], NSStringFromSelector(_cmd)]

#define MOS_CLASS_AND_METHOD_DASH  \
    [NSString stringWithFormat:@"%@ -- ", MOS_CLASS_AND_METHOD]

#define MOS_CODE_LOCATION  MOS_CLASS_AND_METHOD

#define MOS_CODE_LOCATION_WITH_MESSAGE(...)  \
    [MOS_CLASS_AND_METHOD_DASH stringByAppendingString:[NSString stringWithFormat:__VA_ARGS__]]


//
#define MOS_LOG_DEBUG(...)  \
  [MOSLog msg:[NSString stringWithFormat:__VA_ARGS__]  location:MOS_CODE_LOCATION  logType:@"DEBUG"]

#define MOS_LOG_INFO(...)  \
  [MOSLog msg:[NSString stringWithFormat:__VA_ARGS__]  location:MOS_CODE_LOCATION  logType:@"INFO"]

#define MOS_LOG_WARNING(...)  \
  [MOSLog msg:[NSString stringWithFormat:__VA_ARGS__]  location:MOS_CODE_LOCATION  logType:@"WARNING"]

#define MOS_LOG_ERROR(...)  \
  [MOSLog msg:[NSString stringWithFormat:__VA_ARGS__]  location:MOS_CODE_LOCATION  logType:@"ERROR"]

#define MOS_LOG_LOGTYPE_FATAL  @"FATAL"
#define MOS_LOG_FATAL(...)  \
  [MOSLog msg:[NSString stringWithFormat:__VA_ARGS__]  location:MOS_CODE_LOCATION  logType:MOS_LOG_LOGTYPE_FATAL]


#define MOS_LOG_NSERROR(err)  \
  [MOSLog nserror:(NSError *)err  location:MOS_CODE_LOCATION  logType:@"NSERROR"]




//---------------------------------------------------- -o-
@interface MOSLog : NSObject

  + (void)      msg: (NSString *) msg
           location: (NSString *) location  
            logType: (NSString *) logType;

  + (void)   nserror: (NSError *)  error
            location: (NSString *) location
             logType: (NSString *) logType;

@end // @interface MOSLog : NSObject

