//
// Created by Alex Hoang on 9/15/15.
//

#import <Foundation/Foundation.h>


@interface IMConnectivityUtil : NSObject

+ (IMConnectivityUtil *)sharedInstance;

- (BOOL)hasConnectivity;

@end