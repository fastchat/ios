//
//  CHSocketManager.h
//  Chat
//
//  Created by Michael Caputo on 3/20/14.
//
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"


@interface CHSocketManager : NSObject <SocketIODelegate>

+ (CHSocketManager *)sharedManager;

@end
