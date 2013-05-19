//
//  GameViewController.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "GameViewController.h"
#import "CardView.h"

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
    [self loadSounds];
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
    _nameLabels = [NSMutableDictionary dictionaryWithCapacity:numberOfPlayers];
    int idx = 0;
    int labelHeight = 20;
    int labelPadding = 5;
    for (NSString *peerID in players){
        Player *player = [players objectForKey:peerID];
        int YOffset = ((labelHeight+labelPadding) * idx);
        NSLog(@"adding label %@", player.name);
        UIView *playerNameView = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + YOffset, 100, labelHeight)];
        if ([player.peerID isEqualToString:self.game.currentUser.peerID]){
            playerNameView.backgroundColor = [UIColor yellowColor];
        }
        UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, playerNameView.bounds.size.height)];
        playerName.backgroundColor = [UIColor clearColor];
        playerName.text = player.name;
        UILabel *playerPoints = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 20, playerNameView.bounds.size.height)];
        playerPoints.backgroundColor = [UIColor clearColor];
        playerPoints.text = [NSString stringWithFormat:@"%i", player.points];
        [playerNameView addSubview:playerName];
        [playerNameView addSubview:playerPoints];
        [_nameLabels setObject:playerNameView forKey:player.peerID];
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

-(void) gameShouldLoadDeck:(Game *)game
{
    NSLog(@"starting Dealing Deck");
    self.centerLabel.text = NSLocalizedString(@"Dealing...", @"Status Text");
    
    NSTimeInterval delay =1.0f;
    
    _dealingCardsSound.currentTime = 0.0f;
    [_dealingCardsSound prepareToPlay];
    [_dealingCardsSound performSelector:@selector(play) withObject:nil afterDelay:delay];
    size_t count = [[[self.game getDeck] getAllCards] count];
    for(int t=0; t < count; ++t){
                CardView *cardView = [[CardView alloc] initWithFrame:CGRectMake(0,0,CardWidth, CardHeight)];
                [self.cardContainer addSubview:cardView];
                [cardView animateDealingWithDelay:delay];
                delay += 0.1f;
    }
    [self performSelector:@selector(stopDealingSound) withObject:nil afterDelay:delay];
    
}

-(void)game:(Game *)game didActivatePlayer:(Player *)player
{
    NSLog(@"current use peerid %@ and active player peerid %@", game.currentUser.peerID, player.peerID);
    if ([game.currentUser.peerID isEqualToString:player.peerID]){
        self.centerLabel.text = @"Your Turn";
        
    } else {
        self.centerLabel.text = @"Their turn";
    }
}
- (void)viewDidUnload {
    [self setCenterLabel:nil];
    [self setCardContainer:nil];
    [super viewDidUnload];
}

-(void)game:(Game *)game showCardToReader:(Card*)card
{
    _readerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cardViewController"];
    [_readerViewController loadCard:card];
    _readerViewController.delegate = self;
    [self presentViewController:_readerViewController animated:YES completion:nil];
}
-(void)game:(Game *)game showQuestionToPlayers:(Card *)card
{
    _liarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"liarViewController"];
    [_liarViewController loadCard:card];
    _liarViewController.delegate = self;
    [self presentViewController:_liarViewController animated:YES completion:nil];
}

-(void)game:(Game *)game loadAnswersForReader:(NSArray *)answers
{
    NSLog(@"load answers to reader");
    [_readerViewController loadAnswers:answers];
}
-(void)game:(Game *)game loadAnswersForLiars:(NSArray *)answers
{
    NSLog(@"load answers to liar");
    [_liarViewController loadAnswers:answers];
}

-(void)game:(Game *)game allVotesSubmitted:(NSArray *)votes
{
    [_readerViewController updateVotes:votes];
    NSLog(@"votes from game view controller %@", votes);
}

-(void)revealAnswersForVoting
{
    [_liarViewController revealAnswers];
}
-(void)gameTurnEnded
{
    // Do gameboard animation update
    if (nil != _liarViewController){
        [_liarViewController gameTurnEnded:^(BOOL finished){
            _liarViewController = nil;
        }];
    }
    if (nil != _readerViewController){
        [_readerViewController gameTurnEnded:^(BOOL finished){
            _readerViewController = nil;
        }];
    }
    
    [_nameLabels enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIView *obj, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [_nameLabels removeAllObjects];
    
    [self addPlayerLabels];
    
    // Move into the finish method for the animations
    
    [self.game clientReadyForNextTurn];
    

}

#pragma mark - cardviewcontroller

-(void)sendQuestionToClients:(Card *)card{
    [self.game sendQuestionToClients:card];
}
-(void) sendAnswersToVote
{
    NSLog(@"go vote from game view");
    [self.game sendAnswersToVote];
}
-(void) beginNextRound
{
    [self.game beginNextRound];
}
#pragma mark - votingViewController

-(void)playerDidAnswer:(NSString *)answer
{
    [self.game playerDidAnswer:answer];
}
-(void)userVotedForPeer:(NSString *)peerID
{
    [self.game userVotedForPeer:peerID];
}

#pragma mark - Sounds

-(void) loadSounds
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    audioSession.delegate = nil;
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:NULL];
    [audioSession setActive:YES error:NULL];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Dealing" withExtension:@"caf"];
    _dealingCardsSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _dealingCardsSound.numberOfLoops = -1;
    [_dealingCardsSound prepareToPlay];
    NSLog(@"load sound");
}

-(void) stopDealingSound
{
    [_dealingCardsSound stop];
    [self.game beginRound];
}


- (IBAction)pickCardAction:(id)sender {
    [self.game drawCardForActivePlayer];
}
@end
