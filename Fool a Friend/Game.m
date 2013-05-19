//
//  Game.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Game.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketSetupGameDeck.h"
#import "PacketActivatePlayer.h"
#import "PacketClientLieResponse.h"
#import "PacketServerSendAnswers.h"
#import "PacketClientSubmitVote.h"
#import "PacketServerSendVotes.h"
#import "PacketTurnEnded.h"


@implementation Game

@synthesize delegate = _delegate;
@synthesize currentUser;
@synthesize isServer = _isServer;

-(id) init
{
    self = [super init];
    if (self){
        _players = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

#pragma mark - Game Logic

-(void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID{
    self.isServer = NO;
    
    _session = session;
    _session.available = NO;
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    _serverPeerID = peerID;
    _localPlayerName = name;
    _clientPeerID = _session.peerID;
    _state = GameStateWaitingForSignIn;
    
    [self.delegate gameWaitingForServerReady:self];
}

-(void) startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients{
    self.isServer = YES;
    _session = session;
    _session.available = NO;
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    _serverPeerID = _session.peerID;
    _state = GameStateWaitingForSignIn;
    
    [self.delegate gameWaitingForClientsReady:self];
    
    Player *player = [[Player alloc] init];
    player.name = name;
    player.peerID = _session.peerID;
    player.position = 0;
    currentUser = player;
    [_players setObject:player forKey:player.peerID];
    
    int index = 1;
    for (NSString *peerID in clients){
        Player *player = [[Player alloc] init];
        player.peerID = peerID;
        player.position = index;
        [_players setObject:player forKey:player.peerID];
        index++;
    }
    Packet *packet = [Packet packetWithType:PacketTypeSignInRequest];
    [self sendPacketToAllClients:packet];
}


-(void) beginGame
{
    _tempPointsArray = [NSMutableArray arrayWithCapacity:[_players count]];
    _busyDealing = YES;
    _firstTime = YES;
    _state = GameStateDealing;
    [self.delegate gameDidBegin:self];
    
    if(self.isServer){
        [self pickRandomStartingPlayer];
        [self setupGameDeck];
    }
    NSLog(@"the game should begin");
}

-(void) setupGameDeck
{
    NSLog(@"Deal Cards");
    NSAssert(self.isServer, @"Must be server");
    NSAssert(_state == GameStateDealing, @"Wrong state");

    _deck = [[Deck alloc] init];
    NSLog(@"Now shuffle");
    [_deck shuffle];
    
    NSLog(@"get Starting player");
    Player *startingPlayer = [self activePlayer];
    NSLog(@"starting player name is %@",startingPlayer.name);

    
    PacketSetupGameDeck *packet = [PacketSetupGameDeck packetWithCards:[_deck getAllCards] startingWithPlayerPeerID:startingPlayer.peerID];
    NSLog(@"send Packet of cards");
	[self sendPacketToAllClients:packet];
    [self.delegate gameShouldLoadDeck:self];
    
}

-(BOOL) receivedResponsesFromAllPlayer{
    for (NSString *peerID in _players){
        Player *player = [self playerWithPeerID:peerID];
        if (!player.receivedResponse){
            return NO;
        }
    }
    return YES;
}

-(Deck *) getDeck
{
    return _deck;
}

-(void)quitGameWithReason:(QuitReason)reason{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _state = GameStateQuitting;
    if (reason == QuitReasonUserQuit){
        if (self.isServer){
            Packet *packet = [Packet packetWithType:PacketTypeServerQuit];
            [self sendPacketToAllClients:packet];
        } else {
            Packet *packet = [Packet packetWithType:PacketTypeClientQuit];
            [self sendPacketToServer:packet];
        }
    }
    [_session disconnectFromAllPeers];
    _session.delegate = nil;
    _session = nil;
    
    [self.delegate game:self didQuitWithReason:reason];
}

- (void)handleSetupDeckPacket:(PacketSetupGameDeck *)packet
{
	NSAssert([packet.cards count]  > 0, @"No Cards We Dealt");
    NSLog(@"Handle Setup Deck");
    _deck = [[Deck alloc] initWithCards:packet.cards];
    
	Player *startingPlayer = [self playerWithPeerID:packet.startingPeerID];
	_activePlayerPosition = startingPlayer.position;
    
	Packet *responsePacket = [Packet packetWithType:PacketTypeClientDeckSetupResponse];
	[self sendPacketToServer:responsePacket];
    
	_state = GameStatePlaying;
    
	[self.delegate gameShouldLoadDeck:self];
}
-(void) beginRound
{
    _busyDealing = NO;
    _hasTurnedCard = NO;
    [self activatePlayerAtPosition:_activePlayerPosition];
}
-(void)beginNextRound
{
    if (self.isServer){
        Packet *packet = [PacketTurnEnded packetWithPlayers:_players];
        [self sendPacketToAllClients:packet];
        _state = GameStateWaitingForNextTurn;
    } else {
        Packet *packet = [Packet packetWithType:PacketTypeClientTurnEnded];
        [self sendPacketToServer:packet];
    }
}
-(void) turnCardForActivePlayer
{
    NSLog(@" turn card !!!!!");
    [self turnCardForPlayer:[self activePlayer]];
    
    if(self.isServer){
        [self performSelector:@selector(activateNextPlayer) withObject:nil afterDelay:0.5f];
    }
}
-(void)drawCardForActivePlayer
{
    NSLog(@"current user name %@ and pos %i", currentUser.name, currentUser.position);
    NSLog(@"active player pos %i", _activePlayerPosition);
    if (_state == GameStatePlaying &&
        _activePlayerPosition == currentUser.position &&
        !_busyDealing &&
        !_hasTurnedCard){
        
        //[self turnCardForActivePlayer];
        Card *card = [_deck draw];
        if (self.isServer){
            _currentCard = card;
        }
        [self.delegate game:self showCardToReader:card];
        //if(!self.isServer){
           // Packet *packet = [Packet packetWithType:PacketTypeClientTurnedCard];
         //   [self sendPacketToServer:packet];
       // }
    }
}
-(void)sendQuestionToClients:(Card *)card
{
    if(!self.isServer){
        Packet *packet = [Packet packetWithType:PacketTypeCardRead];
       [self sendPacketToServer:packet];
    }else {
        _state = GameStateMakingLies;
        Packet *packet = [Packet packetWithType:PacketTypeCardRead];
        [self sendPacketToAllClients:packet];
        Player *activePlayer = [self activePlayer];
        activePlayer.answer = _currentCard.answer;
        activePlayer.receivedResponse = YES;
    }
}
-(void) handleCardReadPacket:(Packet *)packet
{
    if (_state == GameStatePlaying){
        _state = GameStateMakingLies;
        // make sure the reader doesn't get this message again
        if (currentUser.peerID != [self playerAtPosition:_activePlayerPosition].peerID){
            NSLog(@"non reader player");
            Card *card = [_deck draw];
            if (self.isServer){
                _currentCard = card;
            }
            [self.delegate game:self showQuestionToPlayers:card];
        }
    }

}
-(void)handleAllVotesSubmittedPacket:(Packet*)packet
{
    [self.delegate game:self allVotesSubmitted:((PacketServerSendVotes *)packet).votes];
}
-(void)handleTurnEnded
{
    if (self.isServer){
        NSLog(@"clear old answers");
        for (NSDictionary *votes in _tempPointsArray){
            Player *player = [self playerWithPeerID:[votes objectForKey:@"peerID"]];
            player.points += [[votes objectForKey:@"votes"] intValue];
        }
        [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop) {
            obj.hasVoted = NO;
            obj.answer = nil;
        }];
        [_tempPointsArray removeAllObjects];
    }
    [self.delegate gameTurnEnded];
}
// Called when the player hits the submit buttons on the voting/lying screen
-(void) playerDidAnswer:(NSString *)answer
{
    if (self.isServer){
        NSLog(@"here");
        Player *player = [self playerWithPeerID:_serverPeerID];
        NSLog(@"server peer id %@", _serverPeerID);
        player.answer = answer;
        NSLog(@"now here");
        for (NSString *peerID in _players){
            Player *_player = [_players objectForKey:peerID];
            NSLog(@"answer is %@ for player %@", _player.answer, _player.name);
        }
        if ([self allPlayersHaveAnswered]){
            NSLog(@"all answers in");
            [self sendAnswersToClients];
        }
        // Else if player count is more than 2 then wait for all answers
    } else {
        Packet *packet = [PacketClientLieResponse packetWithAnswer:answer];
        [self sendPacketToServer:packet];
    }

}

-(BOOL) allPlayersHaveAnswered
{
    for (NSString *peerID in _players){
        Player *player = [self playerWithPeerID:peerID];
        if (!player.answer){
            return NO;
        }
    }
    return YES;
}
-(BOOL) allPlayersHaveVoted
{
    for (NSString *peerID in _players){
        Player *player = [self playerWithPeerID:peerID];
        if (![player.peerID isEqualToString:[self activePlayer].peerID]){
            if (!player.hasVoted){
                return NO;
            }
        }

    }
    return YES;
}

-(void)sendAnswersToClients
{
    NSAssert(self.isServer, @"Must Be Server");
    NSMutableArray *answers = [NSMutableArray arrayWithCapacity:[_players count]];
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop) {
        
        [answers addObject:[NSDictionary dictionaryWithObjectsAndKeys:obj.answer,@"answer",obj.name,@"name",obj.peerID,@"peerID", nil]];
    }];
    NSLog(@"send answers to clients");
    Packet *packet = [PacketServerSendAnswers packetWithAnswers:answers];
    [self sendPacketToAllClients:packet];
    
    // If the server is the reader then load up the answers for reading
    if ([currentUser.peerID isEqualToString:[self activePlayer].peerID]){
        [self.delegate game:self loadAnswersForReader:answers];
    } else {
        [self.delegate game:self loadAnswersForLiars:answers];
    }
    // all lying is done set game state back to playing
    _state = GameStatePlaying;
}

-(void)handleAllAnswersFromServerPacket:(Packet *)packet
{
    NSLog(@"alll answer method");
    
    NSArray *answers = ((PacketServerSendAnswers *)packet).answers;

    // If the current client is the reader then load up the answers to read.
    if ([currentUser.peerID isEqualToString:[self activePlayer].peerID]){
        [self.delegate game:self loadAnswersForReader:answers];
    } else {
        [self.delegate game:self loadAnswersForLiars:answers];
    }
    for (NSDictionary *response in answers){
        NSLog(@"unpacking answer %@ for player %@", [response valueForKey:@"answer"],[response valueForKey:@"name"]);
    }
}

-(void)sendAnswersToVote
{
    if(self.isServer){
        NSLog(@"server id %@ and active id %@", _serverPeerID,[self activePlayer].peerID );
        if (_serverPeerID != [self activePlayer].peerID){
            [self.delegate revealAnswersForVoting];
        }
        NSLog(@"server send to clients");
        Packet *packet = [Packet packetWithType:PacketTypeOpenVoting];
        [self sendPacketToAllClients:packet];
    } else {
        Packet *packet = [Packet packetWithType:PacketTypeOpenVoting];
        [self sendPacketToServer:packet];
    }

}

-(void) userVotedForPeer:(id)peerID
{
    if(self.isServer){
        Player *_server = [self playerWithPeerID:_serverPeerID];
        _server.hasVoted = YES;
        [self addVoteForPlayer:peerID];
        if ([self allPlayersHaveVoted]){
            NSLog(@"all votes in send to player");
            Packet *packet = [PacketServerSendVotes packetWithVotes:_tempPointsArray];
            [self sendPacketToPeer:packet peerID:[self activePlayer].peerID];
        }
    } else {
        PacketClientSubmitVote *packet = [PacketClientSubmitVote packetWithVote:peerID];
        [self sendPacketToServer:packet];
    }
    
}

-(void) addVoteForPlayer:(NSString *)peerID
{
    NSMutableArray *tempArry = [_tempPointsArray copy];
    int idx = 0;
    BOOL found = NO;
    for (NSMutableDictionary *_temp in tempArry){
        if ([[_temp objectForKey:@"peerID"] isEqualToString:peerID] ){
            int votes = [[_temp objectForKey:@"votes"] intValue];
            votes++;
            [[_tempPointsArray objectAtIndex:idx] setObject:[NSNumber numberWithInt:votes] forKey:@"votes"];
            found = YES;
            
        }
        idx++;
    }
    if (!found){
        NSLog(@"add vote not in array");
        NSMutableDictionary *vote = [[NSMutableDictionary alloc] init];
        [vote setObject:peerID forKey:@"peerID"];
        [vote setObject:[NSNumber numberWithInt:1] forKey:@"votes"];
        [_tempPointsArray addObject:vote];
    }
    NSLog(@"votes %@", _tempPointsArray);
}

-(void)clientReadyForNextTurn
{
    if(!self.isServer){
        Packet *packet = [Packet packetWithType:PacketTypeClientReady];
        [self sendPacketToServer:packet];
    }

}

#pragma mark - Player Methods

-(Player *)activePlayer
{
    return [self playerAtPosition:_activePlayerPosition];
}
-(NSDictionary *)getPlayers
{
    return _players;
}
-(Player *)playerAtPosition:(int)position
{
    NSLog(@"position is %i count is %i", position, [_players count]);
    NSAssert(position <= [_players count] && position >= 0, @"Invalid Player Position");
    __block Player *player;
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop) {
        player = obj;
        if (player.position == position){
            NSLog(@"player at posi is %@",obj.name);
            *stop = YES;
        } else {
            player = nil;
        }
    }];
    return player;
}
- (Player *)playerWithPeerID:(NSString *)peerID
{
	return [_players objectForKey:peerID];
}
-(void) pickRandomStartingPlayer
{
    do
    {
        _startingPlayerPosition = arc4random() % [_players count];
    }
    while ([self playerAtPosition:_startingPlayerPosition] == nil);
    _activePlayerPosition = _startingPlayerPosition;
    NSLog(@"starting player is %@", [self playerAtPosition:_startingPlayerPosition].name);
}


-(void) handleActivatePlayerPacket:(PacketActivatePlayer *)packet
{
    NSLog(@"hande act");
    if (_firstTime){
        _firstTime = NO;
        return;
    }
    NSString *peerID = packet.peerID;
    
    Player *newPlayer = [self playerWithPeerID:peerID];
    if (nil == newPlayer){
        return;
    }
    NSLog(@"client handle packet for active  players %@", newPlayer.name);
    [self turnCardForActivePlayer];
    [self performSelector:@selector(activatePlayerWithPeerID:) withObject:peerID afterDelay:0.5f];
}
-(void) activatePlayerWithPeerID:(NSString *)peerID
{
    NSAssert(!self.isServer, @"Must be client");
    
    Player *player = [self playerWithPeerID:peerID];
    _activePlayerPosition = player.position;
    [self activatePlayerAtPosition:_activePlayerPosition];
    if ([player shouldRecycle])
	{
		//[self recycleCardsForActivePlayer];
	}
}
-(void)activateNextPlayer
{
    NSAssert(self.isServer, @"Must be server");
    NSLog(@"activate next player old position is %i", _activePlayerPosition);
    while(true){
        _activePlayerPosition ++;
        if (_activePlayerPosition > ([_players count] -1)){
            _activePlayerPosition = 0;
        }
        
        Player *nextPlayer = [self activePlayer];
        if (nextPlayer != nil && [_deck cardsRemaining] > 0){
            NSLog(@"active %@", nextPlayer.name);
            [self activatePlayerAtPosition:_activePlayerPosition];
            return;
        }
    }
}

-(void) turnCardForPlayer:(Player *)player{
    NSAssert([_deck cardsRemaining] > 0, @"Deck has no more cards");
    
    _hasTurnedCard = YES;

    NSLog(@"turn card for player");
    //[self.delegate game:self player:player turnedOverCard:card];
}

-(void) activatePlayerAtPosition:(int)position
{
    NSLog(@"activate player from beginround %@", [self activePlayer].name);
    
    _hasTurnedCard = NO;
    if (self.isServer){
        NSString *peerID = [self activePlayer].peerID;
        Packet *packet = [PacketActivatePlayer packetWithPeerID:peerID];
        [self sendPacketToAllClients:packet];
    }
    [self.delegate game:self didActivatePlayer:[self activePlayer]];
}

#pragma mark - GKSessionDelegate

-(void)clientDidDisconnect:(NSString *)peerID
{
    if(_state != GameStateQuitting){
        Player *player = [self playerWithPeerID:peerID];
        if (player != nil){
            [_players removeObjectForKey:peerID];
            
            if (_state != GameStateWaitingForSignIn){
                
                if (self.isServer){

                }

                
                if (self.isServer && player.position == _activePlayerPosition)
                    [self activateNextPlayer];
            }
            
        }
    }
}
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
#ifdef DEBUG
    NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
    if (state == GKPeerStateDisconnected){
        if (self.isServer){
            [self clientDidDisconnect:peerID];
        }
        else if ([peerID isEqualToString:_serverPeerID]){
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
}
-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    [session denyConnectionFromPeer:peerID];
}
-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
#ifdef DEBUG
	NSLog(@"Game: connection with peer %@ failed %@", peerID, error);
#endif
}
-(void)session:(GKSession *)session didFailWithError:(NSError *)error{
#ifdef DEBUG
	NSLog(@"Game: session failed %@", error);
#endif
    if ([[error domain] isEqualToString:GKSessionErrorDomain]){
        if (_state != GameStateQuitting){
            [self quitGameWithReason:QuitReasonConnectionDropped];
        }
    }
}

#pragma mark - GKSession Data Receive Handler

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void*)context{
#ifdef DEBUG
	NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
#endif
    Packet *packet = [Packet packetWithData:data];
    if (packet == nil){
        NSLog(@"invalid packet: %@", data);
        return;
    }
    Player *player = [self playerWithPeerID:peerID];
    if (nil != player){
        if (packet.packetNumber != -1 && packet.packetNumber <= player.lastPacketNumberReceived){
            NSLog(@"Out of Order Packet");
            return;
        }
        player.lastPacketNumberReceived = packet.packetNumber;
        player.receivedResponse = YES;
    }
    if (self.isServer){
        [self serverReceivedPacket:packet fromPlayer:player];
    } else {
        [self clientReceivedPacket:packet];
    }
}




#pragma mark - Networking

-(void) sendPacketToAllClients:(Packet *)packet{
    if(packet.packetNumber != -1){
        packet.packetNumber = _sendPacketNumber++;
    }
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop) {
        obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
    }];
    
    GKSendDataMode dataMode = GKSendDataReliable;
    NSData *data = [packet data];
    NSError *error;
    if(![_session sendDataToAllPeers:data withDataMode:dataMode error:&error]) {
        NSLog(@"Error sending data to clients: %@", error);
    }
}

-(void) sendPacketToServer:(Packet *)packet
{
    if(packet.packetNumber != -1){
        packet.packetNumber = _sendPacketNumber++;
    }
    GKSendDataMode dataMode = GKSendDataReliable;
    NSData *data = [packet data];
    NSError *error;
    if (![_session sendData:data toPeers:[NSArray arrayWithObject:_serverPeerID] withDataMode:dataMode error:&error]){
        NSLog(@"Error sending data to server: %@", error);
    }
}

-(void) sendPacketToPeer:(Packet *)packet peerID:(NSString *)peerID
{
    if(packet.packetNumber != -1){
        packet.packetNumber = _sendPacketNumber++;
    }
    GKSendDataMode dataMode = GKSendDataReliable;
    NSData *data = [packet data];
    NSError *error;
    if (![_session sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:dataMode error:&error]){
        NSLog(@"Error sending data to server: %@", error);
    }
}

-(void)clientReceivedPacket:(Packet *)packet
{
    switch (packet.packetType){
        case PacketTypeSignInRequest:
            if (_state == GameStateWaitingForSignIn){
                _state = GameStateWaitingForReady;
                
                Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
                [self sendPacketToServer:packet];
            }
            break;
        case PacketTypeServerReady:
            if (_state == GameStateWaitingForReady){
                _players = ((PacketServerReady *)packet).players;
                currentUser = [self playerWithPeerID:_clientPeerID];
                //[self changeRelativePositionsOfPlayers];
                
                Packet *packet = [Packet packetWithType:PacketTypeClientReady];
                [self sendPacketToServer:packet];
                
                [self beginGame];
                NSLog(@"The players are %@", _players);
            }
            break;
        case PacketTypeOtherClientQuit:
            if (_state != GameStateQuitting){
            }
            break;
        case PacketTypeServerQuit:
            [self quitGameWithReason:QuitReasonServerQuit];
            break;
        case PacketTypeActivatePlayer:
            if (_state == GameStatePlaying){
                [self handleActivatePlayerPacket:(PacketActivatePlayer *)packet];
            }
            break;
        case PacketTypeSetupGameDeck:
            if (_state == GameStateDealing){
                [self handleSetupDeckPacket:(PacketSetupGameDeck *)packet];
            }
            break;
        case PacketServerGameReady:
            NSLog(@"All systems GO!!!");
            break;
        case PacketTypeCardRead:
            if (_state == GameStatePlaying){
                [self handleCardReadPacket:packet];
            }
            
            break;
        case PacketTypeAllAnswersSubmitted:
            if(_state == GameStateMakingLies){
                _state = GameStatePlaying;
                [self handleAllAnswersFromServerPacket:packet];
                NSLog(@"recieved answers from server");
            } else {
                NSLog(@"wrong state for all answers");
            }
            break;
        case PacketTypeOpenVoting:
                [self.delegate revealAnswersForVoting];
            break;
        case PacketTypeAllVotesSubmitted:
            NSLog(@"player recieved votes packet should be reader");
            [self handleAllVotesSubmittedPacket:packet];
            break;
        case PacketTypeServerTurnEnded:
            NSLog(@"activate next player since turn is over");
            if (_state == GameStatePlaying){
                _players = ((PacketTurnEnded *)packet).players;
                [self handleTurnEnded];
                
            }
        default:
            break;
    }
}
- (void)serverReceivedPacket:(Packet *)packet fromPlayer:(Player *)player
{
	switch (packet.packetType)
	{
		case PacketTypeSignInResponse:
			if (_state == GameStateWaitingForSignIn)
			{
				player.name = ((PacketSignInResponse *)packet).playerName;
                
				NSLog(@"server received sign in from client '%@'", player.name);
                if ([self receivedResponsesFromAllPlayer]){
                    _state = GameStateWaitingForReady;
                    NSLog(@"All clients have responded.");
                    Packet *packet = [PacketServerReady packetWithPlayers:_players];
                    [self sendPacketToAllClients:packet];
                }
			}
			break;
        case PacketTypeClientReady:
            if (_state == GameStateWaitingForReady && [self receivedResponsesFromAllPlayer]){
                [self beginGame];
            } else if (_state == GameStateWaitingForNextTurn)
			{
				NSLog(@"server received next turn ready in from client '%@'", player.name);
                if ([self receivedResponsesFromAllPlayer]){
                    _state = GameStatePlaying;
                    NSLog(@"All clients are ready for next turn.");
                    [self activateNextPlayer];
                }
			}
            break;
        case PacketTypeClientDeckSetupResponse:
                if ([self receivedResponsesFromAllPlayer]){
                    NSLog(@"All clients have responded.");
                    _state = GameStatePlaying;
                    Packet *packet = [Packet packetWithType:PacketServerGameReady];
                    [self sendPacketToAllClients:packet];
                }
            break;
        case PacketTypeClientTurnEnded:
            NSLog(@"activate next player since turn is over");
            if (_state == GameStatePlaying){
                _state = GameStateWaitingForNextTurn;
                [self handleTurnEnded];
                Packet *packet = [PacketTurnEnded packetWithPlayers:_players];
                [self sendPacketToAllClients:packet];
            }
            break;
        case PacketTypeClientQuit:
            break;
        case PacketTypeCardRead:
            if (_state == GameStatePlaying){
                [self handleCardReadPacket:packet];
                Packet *packet = [Packet packetWithType:PacketTypeCardRead];
                [self sendPacketToAllClients:packet];
                NSLog(@"active player card read add the real answer to this player");
                // we need to mark the active player as responded since he doesn't send an answer
                Player *activePlayer = [self activePlayer];
                activePlayer.answer = _currentCard.answer;
                activePlayer.receivedResponse = YES;
            }
            break;
        case PacketTypeClientAnswer:
            if (_state == GameStateMakingLies){

                player.answer = ((PacketClientLieResponse *)packet).answer;
                NSLog(@"recieved answer from player %@", player.answer);
                if ([self allPlayersHaveAnswered]){
                    NSLog(@"All clients have Answered.");
                    _state = GameStatePlaying;
                    [self sendAnswersToClients];
                }
            }
            break;
        case PacketTypeOpenVoting:
            NSLog(@"open voting packet");
            if(_state == GameStatePlaying){
                NSLog(@"Open voting");
                [self sendAnswersToVote];
            }

            break;
        case PacketTypeVoteSubmitted:
            if (_state == GameStatePlaying){
                Player *tempPlayer = [self playerWithPeerID:player.peerID];
                tempPlayer.hasVoted = YES;
                NSLog(@"recieved vote to server from player:%@",player.name);
                [self addVoteForPlayer:((PacketClientSubmitVote *)packet).peerID];
                if([self allPlayersHaveVoted]){
                    NSLog(@"all votes in");
                    if([_serverPeerID isEqualToString:[self activePlayer].peerID]){
                        NSLog(@"WE ARE THE SERVER AND ACTIVE");
                        [self.delegate game:self allVotesSubmitted:_tempPointsArray];
                    } else {
                        Packet *newpacket = [PacketServerSendVotes packetWithVotes:_tempPointsArray];
                        [self sendPacketToPeer:newpacket peerID:[self activePlayer].peerID];
                    }

                }
            }

            break;
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}


@end
