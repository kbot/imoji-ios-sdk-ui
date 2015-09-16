//
// Created by Alex Hoang on 9/15/15.
//

#import "IMConnectivityUtil.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>


@implementation IMConnectivityUtil {

}

+ (IMConnectivityUtil *)sharedInstance {
    static IMConnectivityUtil *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    BOOL isConnected = nil;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                isConnected = NO;
            } else if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                isConnected = YES;
            } else if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                    (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs

                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    isConnected = YES;
                }
            } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                isConnected = YES;
            }
        }
    }

    CFRelease(reachability);

    if(isConnected) {
        return isConnected;
    }

    return NO;
}

@end