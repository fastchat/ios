//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//

#import "_CHModel.h"
#import "Mantle.h"

@interface CHModel : _CHModel

+ (instancetype)objectFromJSON:(NSDictionary *)dict;
+ (NSArray *)objectsFromJSON:(NSArray *)array;

@end
