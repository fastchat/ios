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

@property (nonatomic, assign, readonly) CGFloat progress;

/** Get the shared manager
 *
 * Gets the socket shared manager. The socket is a singleton, and should only be accessed
 * using this method.
 */
+ (CHSocketManager *)sharedManager;


- (SocketIO *)getSocket;


- (void)openSocket;

/** Send a @b message @@b event.

 This does not guarentee immediate sending. A queue is maintained that will only send
 messages in the order given.
 */
- (void)sendMessageWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;


- (void)sendTypingWithData:(NSDictionary *)data acknowledgement:(void (^)(id argsData))acknowledgement;


- (void)closeSocket;

@end
