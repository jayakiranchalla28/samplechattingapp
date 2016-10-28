//
//  UserListTableViewController.m
//  iChatWithXMPP
//

//  Copyright © 2016 Org. All rights reserved.
//

#import "UserListTableViewController.h"
#import "ChatViewController.h"

@interface UserListTableViewController ()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *otherUser;
@property (nonatomic, assign) BOOL isSelfSelection;

@end

@implementation UserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isSelfSelection = [self.navigationController.viewControllers count] == 1;
    if (_isSelfSelection) {
        [self setTitle:@"Choose Yourself"];
    } else {
        [self setTitle:@"Choose Other Person"];
    }
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)users {
    if (!_users) {
        _users = @[@"jayakiran", @"tester1", @"tester2", @"tester3", @"tester4"];
    }
    return _users;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self users].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    [cell.textLabel setText:_users[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSelfSelection) {
        User *user = [User new];
        [user setUsername:_users[indexPath.row]];
        [user setPassword:_users[indexPath.row]];
        [[self appDelegate] setUser:user];
        [[[self appDelegate] xmppStream] disconnect];
        [[self appDelegate] connect];
    } else {
        _otherUser = _users[indexPath.row];
        [self performSegueWithIdentifier:@"toChatScreen" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toChatScreen"]) {
        ChatViewController *chatContlr = [segue destinationViewController];
        [chatContlr setOtherUser:_otherUser];
    }
}

@end
