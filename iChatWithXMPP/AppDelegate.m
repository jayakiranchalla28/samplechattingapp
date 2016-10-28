//
//  AppDelegate.m
//  iChatWithXMPP
//
//

#import "AppDelegate.h"

@implementation User

@end

@interface AppDelegate () <XMPPStreamDelegate, XMPPRoomDelegate, XMPPMUCDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - XMPP

- (XMPPStream *)xmppStream {
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream setHostName:@"ichatwithxmpp.p1.im"];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppStream;
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    
    if (![[self xmppStream] isDisconnected]) {
        return YES;
    }
    if (_user.username == nil || _user.password == nil) {
        return NO;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@ichatwithxmpp.p1.im",_user.username]]];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"Can't connect to server");
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    [self goOffline];
    [_xmppStream disconnect];
}

#pragma mark XMPP delegates

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:_user.password error:&error];
    NSLog(@"xmppStreamDidConnect : %@",sender);
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"xmppStreamConnectDidTimeout : %@",sender);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidAuthenticate : %@",sender);///11111
    [self goOnline];
    _xmppMuc = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [_xmppMuc activate:_xmppStream];
    [_xmppMuc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppMuc discoverServices];
    [_xmppMuc discoverRoomsForServiceNamed:@"conference.ichatwithxmpp.p1.im"];
    
//    XMPPJID *servrJID = [XMPPJID jidWithString:@"conference.ichatwithxmpp.p1.im"];
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
//    [iq addAttributeWithName:@"from" stringValue:[[self xmppStream] myJID].full];
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
//    [query addAttributeWithName:@"xmlns" stringValue:XMPPDiscoItemsNamespace];
//    [iq addChild:query];
//    [[self xmppStream] sendElement:iq];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"didNotAuthenticate : %@",sender);
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services {
    NSLog(@"didDiscoverServices: %@",services);
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName {
    NSLog(@"didDiscoverRooms: %@ %@ %@",sender, rooms , serviceName);
}

- (void)xmppMUC:(XMPPMUC *)sender failedToDiscoverRoomsForServiceNamed:(NSString *)serviceName withError:(NSError *)error {
    NSLog(@"failedToDiscoverRoomsForServiceNamed: %@",sender);
    NSLog(@"error %@",error);
}

- (void)xmppMUCFailedToDiscoverServices:(XMPPMUC *)sender withError:(NSError *)error {
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message {
    NSLog(@"Recieved Room Invitation from = %@ and Message = %@", roomJID, message);
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[[XMPPRoomMemoryStorage alloc] init] jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:[self xmppStream]];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:_xmppStream.myJID.user history:nil password:nil];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"didReceiveIQ: %@",iq);
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"didReceiveMessage: %@",message);
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    [_messageDelegate newMessageReceived:msg from:from];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence { ///333
    NSLog(@"didReceivePresence: %@",presence);
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:myUsername]) {
        if ([presenceType isEqualToString:@"available"]) {
        } else if ([presenceType isEqualToString:@"unavailable"]) {
        }
    }
}

- (void)createRoom:(NSString *)room {  ////222222
    XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.ichatwithxmpp.p1.im",room]];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:_xmppStream];
    [xmppRoom addDelegate:self
            delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:_xmppStream.myJID.user history:nil password:nil];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    //<XMPPRoom: 0x7ffa425061b0>   <XMPPRoom: 0x7f8904041de0>
    NSLog(@"xmppRoomDidCreate: %@",sender);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    //<XMPPRoom: 0x7f8904041de0>
    NSLog(@"xmppRoomDidJoin: %@",sender);
    [_roomDelegate roomCreated:sender];
    [sender fetchConfigurationForm];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [sender configureRoomUsingOptions:newConfig];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.org.iChatWithXMPP" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iChatWithXMPP" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iChatWithXMPP.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
