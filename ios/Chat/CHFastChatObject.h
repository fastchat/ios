//
//  CHFastChatObject.h
//  Chat
//
//  Created by Michael Caputo on 4/8/14.
//
//

#import <Foundation/Foundation.h>
#import "Mantle/Mantle.h"

@interface CHFastChatObject : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

+ (NSArray *)objectsFromJSON:(NSArray *)array;

@end
