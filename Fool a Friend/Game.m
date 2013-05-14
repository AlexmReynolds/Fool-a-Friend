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
        NSLog(@"Assign player position %i", index);
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

-(void) playerDidAnswer:(NSString *)answer
{
    if (self.isServer){
        Player *player = [self playerWithPeerID:_serverPeerID];
        player.answer = answer;
        if ([_players count] <= 2){
            // only two players so the server must submit the answer
            Packet *packet = [PacketServerSendAnswers packetWithAnswers:[NSArray arrayWithObject:answer]];
            [self sendPacketToAllClients:packet];
        }
        // Else if player count is more than 2 then wait for all answers
    } else {
        Packet *packet = [PacketClientLieResponse packetWithAnswer:answer];
        [self sendPacketToServer:packet];
    }

}

-(void)handleAllAnswersFromServerPacket:(Packet *)packet
{
    NSArray *answers = ((PacketServerSendAnswers *)packet).answers;
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
    NSLog(@"activate next player");
    while(true){
        _activePlayerPosition ++;
        if (_activePlayerPosition > ([_players count] -1)){
            _activePlayerPosition = 0;
        }
        
        Player *nextPlayer = [self activePlayer];
        if (nextPlayer != nil){
            if([nextPlayer.closedCards cardCount] > 0){
                [self activatePlayerAtPosition:_activePlayerPosition];
                return;
            }else {
                [self activatePlayerAtPosition:_activePlayerPosition];
                return;
            }
            
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

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
#ifdef DEBUG
    NSLog(@"Game: peer %@ changed state %d", peerID, state);
#endif
    if (state == GKPeerStateDisconnected){
        if (self.isServer){
            //[self clientDidDisconnect:peerID redistributedCards:nil];
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
        case PacketTypeClientTurnedCard:
            NSLog(@"client turned card");
            if (_state == GameStatePlaying && player == [self activePlayer]){
                NSLog(@"go turn card");
                [self turnCardForActivePlayer];
            }
            break;
        case PacketTypeClientQuit:
            break;
        case PacketTypeCardRead:
            if (_state == GameStatePlaying){
                [self handleCardReadPacket:packet];
                Packet *packet = [Packet packetWithType:PacketTypeCardRead];
                [self sendPacketToAllClients:packet];
                // we need to mark the active player as responded since he doesn't send an answer
                Player *activePlayer = [self activePlayer];
                activePlayer.answer = _currentCard.answer;
                activePlayer.receivedResponse = YES;
            }
            break;
        case PacketTypeClientAnswer:
            if (_state == GameStateMakingLies){
                NSLog(@"recieved answer from player");
                player.answer = ((PacketClientLieResponse *)packet).answer;
                if ([self receivedResponsesFromAllPlayer]){
                    NSLog(@"All clients have Answered.");
                    _state = GameStatePlaying;
                }
            }
            break;
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}


@end
