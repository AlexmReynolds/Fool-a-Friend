//
//  HostViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController ()

@end

@implementation HostViewController
@synthesize theTableView,nameTextField;
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_matchmakingServer == nil){
        _matchmakingServer = [[MatchMakingServer alloc] init];
        _matchmakingServer.maxClients = 3;
        _matchmakingServer.delegate = self;
        [_matchmakingServer startAcceptionConnectionsForSessionID:GAME_SESSION_ID];
        self.nameTextField.placeholder = _matchmakingServer.session.displayName;
        [theTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServer:(MatchMakingServer *)server clientDidConnect:(NSString *)peerID
{
	[theTableView reloadData];
}

- (void)matchmakingServer:(MatchMakingServer *)server clientDidDisconnect:(NSString *)peerID
{
	[theTableView reloadData];
}

-(void)matchmakingServerSessionDidEnd:(MatchMakingServer *)server{
    _matchmakingServer.delegate = nil;
    _matchmakingServer = nil;
    [theTableView reloadData];
    [self.delegate hostViewController:self didEndSessionWithReason:_quitReason];
}
-(void)matchmakingServerNoNetwork:(MatchMakingServer *)server{
    _quitReason = QuitReasonNoNetwork;
}



#pragma mark - TableDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_matchmakingServer != nil){
        NSLog(@"HERE in table view host");
        NSLog(@"count %i", [_matchmakingServer connectedClientsCount]);
        return [_matchmakingServer connectedClientsCount];
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"here in cell for row HOST");
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *peerID = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];
    cell.textLabel.text = [_matchmakingServer displayNameForPeerID:peerID];
    return cell;
}
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setNameTextField:nil];
    [self setTheTableView:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (IBAction)exitAction:(id)sender {
    _quitReason = QuitReasonUserQuit;
    [_matchmakingServer endSession];
    [self.delegate hostViewControllerDidCancel:self];
    
}
@end
