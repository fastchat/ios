//
//  CHSocketManager.h
//  Chat
//
//  Created by Michael Caputo on 3/20/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SocketIO.h"

@class CHMessage;

@interface CHSocketManager : NSObject <SocketIODelegate>

@property (nonatomic, strong) UIViewController *_defaultViewController;

+ (CHSocketManager *)sharedManager;
- (SocketIO *)getSocket;
- (void)openSocket;
- (void)sendMessageWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;
- (void)closeSocket;

@end
