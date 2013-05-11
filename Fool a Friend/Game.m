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

@implementation Game

@synthesize delegate = _delegate;
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
    [_players setObject:player forKey:player.peerID];
    
    int index = 0;
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
    _busyDealing = YES;
    _firstTime = YES;
    _state = GameStateDealing;
    [self.delegate gameDidBegin:self];
    
    if(self.isServer){
        [self pickRandomStartingPlayer];
    }
    NSLog(@"the game should begin");
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
-(BOOL) receivedResponsesFromAllPlayer{
    for (NSString *peerID in _players){
        Player *player = [self playerWithPeerID:peerID];
        if (!player.receivedResponse){
            return NO;
        }
    }
    return YES;
}

-(void) pickRandomStartingPlayer
{
    do
    {
        _startingPlayerPosition = arc4random() % 4;
    }
    while ([self playerAtPosition:_startingPlayerPosition] == nil);
    _activePlayerPosition = _startingPlayerPosition;
    NSLog(@"starting player is %i", _startingPlayerPosition);
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
        case PacketTypeClientQuit:
            break;
		default:
			NSLog(@"Server received unexpected packet: %@", packet);
			break;
	}
}


@end
