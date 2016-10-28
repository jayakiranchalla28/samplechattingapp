//
//  AppDelegate.h
//  iChatWithXMPP
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPLogging.h"
#import "XMPPRoom.h"
#import "XMPPMUC.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPConstants.h"

@protocol MessageDelegate <NSObject>

- (void)newMessageReceived:(NSString *)message from:(NSString *)from;

@end

@protocol RoomDelegate <NSObject>

- (void)roomCreated:(XMPPRoom *)room;

@end

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) XMPPStream *xmppStream;
//@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPMUC *xmppMuc;

@property (nonatomic, assign) id <MessageDelegate> messageDelegate;
@property (nonatomic, assign) id <RoomDelegate> roomDelegate;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) User *user;

- (BOOL)connect;
- (void)createRoom:(NSString *)room;

@end

