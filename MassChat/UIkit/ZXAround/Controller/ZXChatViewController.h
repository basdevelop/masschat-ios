#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "WifiDirectManager.h"


@interface ZXChatViewController : JSMessagesViewController
@property(nonatomic, strong) NSString *personId;

-(id)initWithFriend:(FriendNearBy*)friendPeerId;
@end
