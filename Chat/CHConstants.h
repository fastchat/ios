//
//  CHConstants.h
//  Chat
//
//  Created by Ethan Mick on 5/31/14.
//
//

#import <Foundation/Foundation.h>

//f4ba5d3cda6140d68a278d77f6d90de5

#define CLASS_PREFIX @"CH"

//#define LOCAL 1
#ifdef LOCAL
    #define BASE_PROTOCOL @"http://"
    #define BASE_URL @"10.0.0.3"
    #define BASE_PORT 3000
    #define BASE_PATH [NSString stringWithFormat:@"%@%@:%lu", BASE_PROTOCOL, BASE_URL, (unsigned long)BASE_PORT]
#else
    #define BASE_PROTOCOL @"http://"
    #define BASE_URL @"powerful-cliffs-9562.herokuapp.com"
    #define BASE_PORT 80
    #define BASE_PATH [NSString stringWithFormat:@"%@%@:%lu", BASE_PROTOCOL, BASE_URL, (unsigned long)BASE_PORT]
#endif

FOUNDATION_EXPORT NSString *const CORE_DATA_ID;
FOUNDATION_EXPORT NSString *const kReloadGroupTablesNotification;
FOUNDATION_EXPORT NSString *const kReloadActiveGroupNotification;
FOUNDATION_EXPORT NSString *const kNewMessageReceivedNotification;
FOUNDATION_EXPORT NSString *const kNewGroupNotification;
FOUNDATION_EXPORT NSString *const kTypingNotification;
FOUNDATION_EXPORT NSString *const CHNotificationPayloadKey;

FOUNDATION_EXPORT NSString *const kCellIdentifier;
FOUNDATION_EXPORT NSString *const CHSwitchCell;

@interface CHConstants : NSObject

@end
