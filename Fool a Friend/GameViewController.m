//
//  GameViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addPlayerLabels
{

    NSDictionary *players = [self.game getPlayers];
    int numberOfPlayers = [[players allKeys]count];
    _nameLabels = [[NSMutableArray alloc] initWithCapacity:numberOfPlayers];
    int idx = 0;
    int labelHeight = 20;
    int labelPadding = 5;
    for (NSString *peerID in players){
        Player *player = [players objectForKey:peerID];
        int YOffset = ((labelHeight+labelPadding) * idx);
        NSLog(@"adding label %@", player.name);
        UIView *playerNameView = [[UIView alloc] initWithFrame:CGRectMake(10 + YOffset, 10, 100, labelHeight)];
        UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, playerNameView.bounds.size.height)];
        playerName.text = player.name;
        UILabel *playerPoints = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 20, playerNameView.bounds.size.height)];
        playerPoints.text = [NSString stringWithFormat:@"%i", player.points];
        [playerNameView addSubview:playerName];
        [playerNameView addSubview:playerPoints];
        
        [self.view addSubview:playerNameView];
        idx++;
    }
}
#pragma mark - GameDelegate

-(void)game:(Game*)game didQuitWithReason:(QuitReason)reason
{
    [self.delegate gameViewController:self didQuitWithReason:reason];
}

-(void)gameWaitingForServerReady:(Game *)game{
    self.centerLabel.text = NSLocalizedString(@"Waiting for game to start...", @"Status text: waiting for server");
}

-(void)gameWaitingForClientsReady:(Game *)game{
    self.centerLabel.text = NSLocalizedString(@"Waiting for other players...", @"Status text: waiting for clients");
}
-(void)gameDidBegin:(Game *)game
{
    [self addPlayerLabels];
}
- (void)viewDidUnload {
    [self setCenterLabel:nil];
    [super viewDidUnload];
}
@end
