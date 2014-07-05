//
// MOSTimeSynchronizeVC.m
//
// Demonstrate use of MOSNTPClock.
//
//
// NOTIFICATIONS OBSERVED--
//   kMOSNTPClockTimeoutBadNotification (from MOSNTPClock)
//   kMOSNTPClockTimeoutGoodNotification (from MOSNTPClock)
//
//
//---------------------------------------------------------------------
//     Copyright (C) 2014 David Reeder.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "MOSTimeSynchronizeVC.h"



//-------------------------------------------------- -o--
// Constants.
//
#define kMOSSynchronizationStatusButtonReady       @"Start NTP"
#define kMOSSynchronizationStatusButtonProcessing  @"Synchronizing..."

#define kMOSLabelUnknown  @"(unknown)" 



//-------------------------------------------------- -o--
@interface MOSTimeSynchronizeVC()

  // UI
  //
  @property  (weak, nonatomic)  IBOutlet UIButton  *synchronizationStatusButtonAsLabel;
  - (IBAction) synchronizationStatusButtonAction:(UIButton *)sender;

  //
  @property  (weak, nonatomic)  IBOutlet UILabel  *deviceTimeLabel;
  @property  (weak, nonatomic)  IBOutlet UILabel  *ntpTimeLabel;
  @property  (weak, nonatomic)  IBOutlet UILabel  *timeDifferenceLabel;


  // View logic and model.
  //
  @property  (strong, nonatomic)  MOSNTPClock  *ntpClock;

  @property  (strong, nonatomic)  NSDateFormatter  *timeFormat;

  @property  (strong, nonatomic)  NSTimer  *secondsTimer;

  @property  (nonatomic)          float  ntpTimeOffsetInSeconds;


  // Private methods
  //
  - (void) ntpClockTimeoutBad:  (NSNotification *)notification;
  - (void) ntpClockTimeoutGood: (NSNotification *)notification;

  - (NSDate *) nowPlusOneSecondRounded:(NSTimeInterval)secondsOffset;

  - (void) secondsTimerFires:(NSTimer *)timer;

@end




//-------------------------------------------------- -o--
@implementation MOSTimeSynchronizeVC

#pragma mark - Lifecycle.

//----------------- -o-
- (void)viewDidLoad
{
  [super viewDidLoad];
    
  self.deviceTimeLabel.text      = kMOSLabelUnknown;
  self.ntpTimeLabel.text         = kMOSLabelUnknown;
  self.timeDifferenceLabel.text  = kMOSLabelUnknown;

  self.ntpTimeOffsetInSeconds = DBL_MAX;

} // viewDidLoad



//----------------- -o-
// viewWillAppear:
//
// Begin monitoring for NTP Notifications. 
// Start local timer.
//
- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  //
  [[NSNotificationCenter defaultCenter] addObserver: self 
                                           selector: @selector(ntpClockTimeoutBad:) 
                                               name: kMOSNTPClockTimeoutBadNotification
                                             object: nil ];

  [[NSNotificationCenter defaultCenter] addObserver: self 
                                           selector: @selector(ntpClockTimeoutGood:) 
                                               name: kMOSNTPClockTimeoutGoodNotification
                                             object: nil ];

  [[NSRunLoop mainRunLoop] addTimer:self.secondsTimer forMode:NSDefaultRunLoopMode];
}



//----------------- -o-
// viewWillDisappear:
//
// Cleanup NTP clock, timer and notifications.
//
- (void) viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];

  //
  [self.ntpClock stop];

  [self.secondsTimer invalidate];
  self.secondsTimer = nil;

  //
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}




//-------------------------------------------------- -o--
#pragma mark - Getters/setters.

//----------------- -o-
- (MOSNTPClock *) ntpClock
{
  if (! _ntpClock) {
    _ntpClock = [MOSNTPClock sharedClient];
  }

  return _ntpClock;
}


//----------------- -o-
- (NSDateFormatter *) timeFormat 
{
  if (! _timeFormat) {
    _timeFormat = [[NSDateFormatter alloc] init];
    [_timeFormat setDateFormat:@"HH:mm:ss.SSS zzz"];
  }

  return _timeFormat;
}


//----------------- -o-
- (NSTimer *) secondsTimer
{
  if (! _secondsTimer) {
    _secondsTimer = [[NSTimer alloc] initWithFireDate: [self nowPlusOneSecondRounded:0]
                                             interval: 1.0
                                               target: self
                                             selector: @selector(secondsTimerFires:)
                                             userInfo: nil
                                              repeats: YES ];
  }

  return _secondsTimer;
}




//-------------------------------------------------- -o--
#pragma mark - Notification receipt.

//----------------- -o-
- (void) ntpClockTimeoutBad:(NSNotification *)notification
{
  if (! [self.ntpClock synchronizationSuccess])
  {
    NSString  *errorMessage = [NSString stringWithFormat:
      @"\nPlease check that WIFI is enabled and has a stable signal."
      @"\n\nThen try synchronization again, but wait a little longer for results."
      @"\n\n(responses:%ld  restarts:%ld)", 
              (unsigned long)[self.ntpClock countOfSuccessfulResponses], 
              (unsigned long)[self.ntpClock countOfFailedTimerStarts] ];

    MOS_LOG_ERROR(@"%@", errorMessage);
    
    UIAlertView  *anAlert = [[UIAlertView alloc] initWithTitle: @"NTP Time Synchronization Failed"
                                                       message: errorMessage
                                                      delegate: nil
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles: nil ];
    [anAlert show];
  }
}


//----------------- -o-
- (void) ntpClockTimeoutGood:(NSNotification *)notification
{
  [self.synchronizationStatusButtonAsLabel setTitle:kMOSSynchronizationStatusButtonReady forState:UIControlStateNormal];
}




//-------------------------------------------------- -o--
#pragma mark - UI Actions

//----------------- -o-
- (IBAction)synchronizationStatusButtonAction:(UIButton *)sender 
{
  if (! [self.ntpClock isProtocolActive]) 
  {
    [self.synchronizationStatusButtonAsLabel setTitle:kMOSSynchronizationStatusButtonProcessing forState:UIControlStateNormal];
    [self.ntpClock startWithTimer];
  }
}




//-------------------------------------------------- -o--
#pragma mark - Private Methods.

//----------------- -o-
- (NSDate *) nowPlusOneSecondRounded:(NSTimeInterval)secondsOffset
{
  return [NSDate dateWithTimeIntervalSinceReferenceDate:round([NSDate timeIntervalSinceReferenceDate] + 1)];
}



//----------------- -o-
- (void) secondsTimerFires:(NSTimer *)timer
{
  NSDate  *systemNow  = [NSDate date];
  NSDate  *ntpNow     = [self.ntpClock date];

  self.deviceTimeLabel.text  = [self.timeFormat stringFromDate:systemNow];


  //
  if (! [self.ntpClock isProtocolActive]) {
    [self.synchronizationStatusButtonAsLabel setTitle:kMOSSynchronizationStatusButtonReady forState:UIControlStateNormal];
  }


  //
  if (    [self.ntpClock synchronizationSuccess]
       || (![self.ntpClock isProtocolActive] && [self.ntpClock date]) )
  {
    self.ntpTimeLabel.text         = [self.timeFormat stringFromDate:ntpNow];

    self.ntpTimeOffsetInSeconds    = [self.ntpClock differenceFromSystemDate];
    self.timeDifferenceLabel.text  = [NSString stringWithFormat:@"%0.3f", self.ntpTimeOffsetInSeconds];

  } else {
    self.ntpTimeOffsetInSeconds    = DBL_MAX;

    self.ntpTimeLabel.text         = kMOSLabelUnknown;
    self.timeDifferenceLabel.text  = kMOSLabelUnknown;
  }

} // secondsTimerFires:


@end

