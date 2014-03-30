//
//  CHSocketManager.m
//  Chat
//
//  Created by Michael Caputo on 3/20/14.
//
//

#import "CHSocketManager.h"
#import "SocketIOPacket.h"

@implementation CHSocketManager

+ (CHSocketManager *)sharedManager;
{
    static CHSocketManager *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[CHSocketManager alloc] init];
    });
    
    return _sharedManager;
}

@end
