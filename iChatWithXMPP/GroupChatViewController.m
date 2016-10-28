//
//  GroupChatViewController.m
//  iChatWithXMPP
//

//

#import "GroupChatViewController.h"
#import "AppDelegate.h"

@interface GroupChatViewController () <MessageDelegate,RoomDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextView *chatView;
@property (weak, nonatomic) IBOutlet UITextField *groupTextField;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) XMPPRoom *room;
@property (nonatomic, strong) NSArray *users;

@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self appDelegate];
}

- (AppDelegate *)appDelegate {
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        [_appDelegate setRoomDelegate:self];
        [_appDelegate setMessageDelegate:self];
    }
    return _appDelegate;
}

- (IBAction)createChat:(id)sender {
    if (_groupTextField.text.length > 0) {
        [[self appDelegate] createRoom:_groupTextField.text];
    }
}

- (NSArray *)users {
    if (!_users) {
        _users = @[@"jayakiran", @"tester1", @"tester2", @"tester3", @"tester4"];
    }
    return _users;
}

- (IBAction)inviteAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Invite people" preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *aUser in [self users]) {
        [alertController addAction:[UIAlertAction actionWithTitle:aUser style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [_room inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@ichatwithxmpp.p1.im",action.title]] withMessage:@"Greetings!"];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)roomCreated:(XMPPRoom *)room {
    [self setRoom:room];
    [_groupTextField setText:nil];
    [_groupTextField setEnabled:NO];
    _inviteButton.hidden = NO;
}

- (IBAction)sendMessageNow:(id)sender
{  //<XMPPRoom: 0x7f8904041de0>
    if (!_room) {
        NSLog(@"Please create a room");
        return;
    }
    NSString *messageStr = _textView.text;
    if([messageStr length] > 0)
    {
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" xmlns:XMPPMUCNamespace];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        [message addChild:body];
        [_room sendMessage:[XMPPMessage messageFromElement:message]];
        
        [_textView setText:nil];
/*
        {
            [_room sendMessageWithBody:@"Hi All"];
            
            NSXMLElement *x = [NSXMLElement elementWithName:@"groupchat" xmlns:XMPPMUCNamespace];
            
            XMPPMessage *message = [XMPPMessage message];
            [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@/%@",[_room.roomJID full],_ro(@"LoginNumber")]];
            [message addChild:x];
            NSLog(@"x in Invite === %@",x);
            [xmppStream sendElement:message];
        }
 */
    }
}


- (void)newMessageReceived:(NSString *)message from:(NSString *)from {
    [_chatView setText:[NSString stringWithFormat:@"%@\n%@\n%@\n",_chatView.text,from,message]];
    [self scrollTextViewToBottom:_chatView];
}


- (void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
