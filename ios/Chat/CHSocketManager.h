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

//@class SocketIO;
@protocol CHSocketManagerDelegate;

@interface CHSocketManager : NSObject <SocketIODelegate>


@property (nonatomic, weak) id <CHSocketManagerDelegate> delegate;
@property (nonatomic, strong) SocketIO *socket;

+ (CHSocketManager *)sharedManager;
-(SocketIO *)getSocket;
-(void)openSocket;
-(void) sendMessageWithEvent: (NSString *)message data: (NSDictionary *)data;
-(void) closeSocket;

@end

@protocol CHSocketManagerDelegate <NSObject>

-(BOOL)manager: (CHSocketManager *)manager doesCareAboutMessage: (NSDictionary *)message;

@end
