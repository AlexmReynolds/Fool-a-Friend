//
//  JoinViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController ()

@end

@implementation JoinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hostSelected = NO;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (nil == _matchmakingClient){
        _quitReason = QuitReasonConnectionDropped;
        _matchmakingClient = [[MatchMakingClient alloc] init];
        [_matchmakingClient startSearchingForServersWithSessionID:GAME_SESSION_ID];
        _matchmakingClient.delegate = self;
        self.nameTextField.placeholder = _matchmakingClient.session.displayName;
        [self.theTableView reloadData];
    }
}



#pragma mark - MatchMaking Delegate

-(void)matchmakingClient:(MatchMakingClient *)client serverBecameAvailable:(NSString *)peerID{
    [self.theTableView reloadData];
}

-(void)matchmakingClient:(MatchMakingClient *)client serverBecameUnavailable:(NSString *)peerID{
    [self.theTableView reloadData];
}
-(void)matchmakingClient:(MatchMakingClient *)client didDisconnectFromServer:(NSString *)peerID{
    _matchmakingClient.delegate = nil;
    _matchmakingClient = nil;
    [self.theTableView reloadData];
    [self.delegate joinViewController:self didDisconnectWithReason:_quitReason];
}
-(void)matchmakingClientNoNetwork:(MatchMakingClient *)client{
    _quitReason = QuitReasonNoNetwork;
}
-(void) matchmakingClient:(MatchMakingClient *)client didConnectToServer:(NSString *)peerID{
    NSLog(@"did connect");
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"name is %@", name);
    NSLog(@"name is from field %@", self.nameTextField.text);
    if ([name length] == 0){
        NSLog(@"in the if");
        name = _matchmakingClient.session.displayName;
    }
    [self.delegate joinViewController:self startGameWithSession:_matchmakingClient.session playerName:name server:peerID];
}




#pragma  mark - Table Delegates


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (nil != _matchmakingClient){
        return [_matchmakingClient availableServerCount];
    } else {
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingClient displayNameForPeerID:peerID];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_matchmakingClient != nil){
        self.waitView.hidden = NO;
        NSString *peerID = [_matchmakingClient peerIDForAvailableServerAtIndex:indexPath.row];
        [_matchmakingClient connectToServerWithPeerID:peerID];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textfield{
    [textfield resignFirstResponder];
    return NO;
}

- (void)viewDidUnload {
    [self setWaitView:nil];
    [self setTheTableView:nil];
    [self setNameTextField:nil];
    [self setCenterLabel:nil];
    [super viewDidUnload];
}
- (IBAction)exitAction:(id)sender {
    
    _quitReason = QuitReasonUserQuit;
    [_matchmakingClient disconnectFromServer];
    [self.delegate joinViewControllerDidCancel:self];
}
@end
