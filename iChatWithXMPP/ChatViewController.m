//
//  ViewController.m
//  iChatWithXMPP
//

//

#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ChatViewController () <MessageDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextView *chatView;
@property (weak, nonatomic) AppDelegate *appDelegate;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_otherUser];
    [self appDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (AppDelegate *)appDelegate {
    if (!_appDelegate) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        [_appDelegate setMessageDelegate:self];
    }
    return _appDelegate;
}

- (IBAction)sendMessageNow:(id)sender
{
    NSString *messageStr = _textView.text;
    if([messageStr length] > 0)
    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@ichatwithxmpp.p1.im",_otherUser]];
        [message addChild:body];
        
        [[self appDelegate].xmppStream sendElement:message];
        [_textView setText:nil];
    }
}

#pragma mark MessageDelegate

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

@end
