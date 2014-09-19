//
//  CHConstants.h
//  Chat
//
//  Created by Ethan Mick on 5/31/14.
//
//

#import <Foundation/Foundation.h>

#define CLASS_PREFIX @"CH"

//#define BASE_PROTOCOL @"http://"
//#define BASE_URL @"localhost"
//#define BASE_PORT 3000
//#define BASE_PATH [NSString stringWithFormat:@"%@%@:%lu", BASE_PROTOCOL, BASE_URL, (unsigned long)BASE_PORT]
#define BASE_PROTOCOL @"http://"
#define BASE_URL @"powerful-cliffs-9562.herokuapp.com"
#define BASE_PORT 80
#define BASE_PATH [NSString stringWithFormat:@"%@%@:%lu", BASE_PROTOCOL, BASE_URL, (unsigned long)BASE_PORT]

FOUNDATION_EXPORT NSString *const CORE_DATA_ID;
FOUNDATION_EXPORT NSString *const kReloadGroupTablesNotification;
FOUNDATION_EXPORT NSString *const kReloadActiveGroupNotification;

@interface CHConstants : NSObject

@end
