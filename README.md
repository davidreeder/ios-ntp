# MOSNTPClock (v0.1)

MOSNTPClock is a class interface to an augmented version of ios-ntp.
Please see below for the original README about ios-ntp.

See the "xcode" directory for an example.  example-MOSNTPClock.xcodeproj
depends on "ios-ntp" and "classes".


### About

Implement timer to limit usage of NTP:
  * Provides simple backoff in case of failure
  * Use previous synchroniation values (if any) in case of error

Class level notifications regarding success/failure.

Provide NTP time -OR- NTP time + arbitrary offset.  

Test whether NTP protocol is currently active

Test whether last iteration of time synchronization was successful.



### Build requirements for ios-ntp

    (XCode target) --> Build Phases --> Compile Sources --> Compiler Flags

        GCDAsyncUdpSocket.m  -fno-objc-arc -Wno-deprecated-declarations
        NetAssociation.m     -fno-objc-arc 
        NetworkClock.m       -fno-objc-arc 



### Changes to ios-ntp

  * Adapted ios-ntp.h to include ios-ntp-prefix.h --
      Preceded with optional #define IOS_NTP_LOGGING.
  * Added instance variable NetworkClock :: enableUponForegrounding --
      Allows the class to be foregrounded without re-activating NTP.
  * Add NetworkClock :: networkTimeWithOffset --
      Allows fudge factor on returned time.
  * Clarify Notification identifiers: kNetAssociationNotification{Good,Fail}
  * Specify C language numeric types

NB
  * NetworkClock :: sharedNetworkClock may still be started without custom
    configuration if [NSDate networkTime] executes before [self 
    sharedNTPClient].  This case may return (unstable) time before 
    kMOSNTPClockSuccessCountThreshold is achieved.

  * By contrast, [self date] and [self differenceFromSystemDate] will return 
    out of bound values upon error or prior to NTP synchronization.


Dependencies: MOSNTPClock relies on MOSLog.


Notifications observed--
  * kNetAssociationNotificationGood  (from NetAssociation)
  * UIApplicationDidEnterBackgroundNotification  (from UIApplication)

Notifications generated--
  * kMOSNTPClockTimeoutBadNotification 
  * kMOSNTPClockTimeoutGoodNotification 




# ios-ntp

An application testbed and a network time protocol client for iOS. This is a
work in progress.

Created by Gavin Eadie on Oct 17, 2010

### About

The clock on an iPhone, iTouch or iPad is not closely synchronized to the
correct time. In the case of a device with access to the telephone system, there
is a setting to enable synchronizing to the phone company time, but that time
has been known to be over a minute different from UTC.

In addition, users may change their device time and severely affect applications
that rely on correct times to enforce functionality.

This project contains code to provide time obtained from standard time servers
using the network time protocol (NTP: RFCs 4330 and 5905). The implementation is
not a rigorous as described in those RFCs since the goal was to improve time
accuracy to with in a second, not to fractions of milliseconds.

### This Fork

This is a fork from the original source at
[http://code.google.com/p/ios-ntp/](http://code.google.com/p/ios-ntp/) that
provides ios-ntp as a *static* iOS framework. This makes its use easier and
avoids symbol clashing.

Why fork? Well, because git and github are much more convenient than google code
for me. I (jbenet) am subscribed to the RSS feed of the original project and
will merge any upstream changes.

### License

The [MIT](http://www.opensource.org/licenses/mit-license.php) License
Copyright (c) 2012, Ramsay Consulting

### Usage

Download [ios-ntp.tar.gz](https://raw.github.com/jbenet/ios-ntp/master/release/ios-ntp.tar.gz),
and add `ios-ntp.framework` to your project. Make sure the file `ntp.hosts` is
added to the project. I should show within the ios-ntp.framework/Headers
directory.*

This project depends on CocoaAsyncSocket, so you may need to
[get it](http://code.google.com/p/cocoaasyncsocket/). ios-ntp only needs
`AyncUdpSocket`.

Edit ntp.hosts to add or remove any NTP servers. Make sure it is OK to use them.

Then, simply call:

    [NSDate networkDate];

As soon as you call it, the NTP process will begin. If you wish to start it at
boot time, so that the time is well synchronized by the time you actually want
to use it, just call it in your AppDelegate's didFinishLaunching function.


* Note: The ntp.hosts is currently inside Headers to both bundle it with the
framework AND coax Xcode to automatically add it, as it does not add the
Resources directory of frameworks.

### Building

To build the static framework, build the `ios-ntp` target from the xcode
project. Make sure you build BOTH the `iPhone Simulator` and `iOS Device`
architectures.


