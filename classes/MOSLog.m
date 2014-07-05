//
// MOSLog.m
//
//---------------------------------------------------------------------
//     Copyright (C) 2014 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "MOSLog.h"



//---------------------------------------------------- -o-
@implementation MOSLog


//------------------- -o-
+ (void)      msg: (NSString *) msg
         location: (NSString *) location
          logType: (NSString *) logType
{
  if (MOS_LOG_ENABLED) {
    NSLog(@"_LOG: %@_ %@ -- %@", logType, location, msg);
  }

  
  if ([logType isEqualToString:MOS_LOG_LOGTYPE_FATAL]) 
  {
    BOOL  useAlertOverExceptionOnFatalError = NO;

    UIAlertView  *anAlert = [[UIAlertView alloc] initWithTitle: MOS_LOG_LOGTYPE_FATAL
                                                       message: msg
                                                      delegate: nil
                                             cancelButtonTitle: nil
                                             otherButtonTitles: nil ];

    NSException  *exception = [[NSException alloc] initWithName: MOS_LOG_LOGTYPE_FATAL
                                                         reason: msg
                                                       userInfo: nil ];

    if (useAlertOverExceptionOnFatalError) 
    {
      dispatch_async(dispatch_get_main_queue(), ^{ [anAlert show]; });
    } else {
      [exception raise];
    }
  }
} 



//------------------- -o-
+ (void)   nserror: (NSError *)  error
          location: (NSString *) location
           logType: (NSString *) logType
{
  if (!error)  { return; }


  NSString *s;

  if (MOS_LOG_ENABLED) {
    s =   [NSString stringWithFormat:@"\n\t%@: %@", @"Description", [error localizedDescription]];
    s = [s stringByAppendingString:
          [NSString stringWithFormat:@"\n\t%@: %@", @"Reason", [error localizedFailureReason]]];
    s = [s stringByAppendingString:
          [NSString stringWithFormat:@"\n\t%@: %@", @"Suggestion", [error localizedRecoverySuggestion]]];

    [MOSLog  msg:s  location:location  logType:logType];

    if ([[error userInfo] count] > 0) {
      NSMutableDictionary *simpleDict = [[NSMutableDictionary alloc] init];
      [simpleDict setObject:[error userInfo] forKey:@""];
      MOS_LOG_INFO(@"%@", [simpleDict description]);
    }
  }

} // nserror:location:logType:


@end // @implementation MOSLog

