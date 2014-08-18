//
//  Chat
//
//  Created by Ethan Mick on 8/12/14.
//
//
#import "CHGroup.h"
#import "CHUser.h"


@interface CHGroup ()

@property (nonatomic, strong) NSMutableDictionary *allUsers;

@end


@implementation CHGroup

@synthesize allUsers = _allUsers;

- (void)awakeFromFetch;
{
    [super awakeFromFetch];
    [self commonInit];
}

- (void)awakeFromInsert;
{
    [super awakeFromInsert];
    [self commonInit];
}

- (void)commonInit;
{
    self.allUsers = [NSMutableDictionary dictionary];
}

- (NSString *)name;
{
    if( self.primitiveName.length != 0 ) {
        return self.primitiveName;
    }
    
    NSMutableString *nameFromMembers = [[NSMutableString alloc] init];
    if( self.members.count == 1 ) {
        [nameFromMembers appendString:[NSString stringWithFormat:@"Empty chat!"]];
    }
    else if( self.members.count == 2 ) {
        if (((CHUser *)self.members.firstObject).chID == [CHUser currentUser].chID) {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[1]).username]];
        }
        else {
            [nameFromMembers appendString:[NSString stringWithFormat:@"%@", ((CHUser *)self.members[0]).username]];
        }
    } else {
        CHUser *currLoggedInUser = [CHUser currentUser];
        for (int i = 0; i < self.members.count; i++) {
            CHUser *currMember = self.members[i];
            
            if (![currMember.chID isEqualToString:currLoggedInUser.chID]) {
                if (i == self.members.count - 1) {
                    [nameFromMembers appendString:[NSString stringWithFormat:@"%@",((CHUser *)self.members[i]).username]];
                }
                else {
                    [nameFromMembers appendString:[NSString stringWithFormat:@"%@,",((CHUser *)self.members[i]).username]];
                }
            }
        }
    }
    return nameFromMembers;
}

- (NSString *)usernameFromId:(NSString *)theId;
{
    return self.allUsers[theId];
}

- (CHUser *)memberFromId:(NSString *)theId;
{
    CHUser *userToReturn = nil;
    
    if (theId) {
        //        userToReturn = self.memberDict[theId];
    }
    
    return userToReturn;
}

- (BOOL)hasUnread;
{
    return self.unread.integerValue > 0;
}


@end
