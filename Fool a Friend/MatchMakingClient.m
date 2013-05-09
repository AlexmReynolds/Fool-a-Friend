//
//  MatchMakingClient.m
//  Snap
//
//  Created by Alex Reynolds on 5/4/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "MatchMakingClient.h"


@implementation MatchMakingClient
@synthesize session = _session;
@synthesize delegate = _delegate;
-(id) init{
    self = [super init];
    if (self){
        _clientState = ClientStateIdle;
    }
    return self;
}

-(void) startSearchingForServersWithSessionID:(NSString *)sessionID{
    if (_clientState == ClientStateIdle){
        _clientState = ClientStateSearchingForServers;
    }
    
    _availableServers = [NSMutableArray arrayWithCapacity:10];
    NSLog(@"start searching %@", sessionID);
    _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
    
    _session.delegate = self;
    _session.available = YES;
}
-(NSArray *) availableServers{
    return _availableServers;
}

-(void) connectToServerWithPeerID:(NSString *)peerID{
    NSAssert(_clientState == ClientStateSearchingForServers, @"Wrong State");
    
    _clientState = ClientStateConnecting;
    _serverPeerID = peerID;
    [_session connectToPeer:peerID withTimeout:_session.disconnectTimeout];
}
-(void) session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    #ifdef DEBUG
        NSLog(@"MatchMakingClient: peer %@ changed state %d", peerID, state);
    #endif
            NSLog(@"MatchMakingClient: peer %@ changed state %d", peerID, state);
    switch (state) {
        case GKPeerStateAvailable:
            if (_clientState == ClientStateSearchingForServers){
                if (![_availableServers containsObject:peerID]){
                    [_availableServers addObject:peerID];
                    [self.delegate matchmakingClient:self serverBecameAvailable:peerID];
                }
            }

            break;
        case GKPeerStateUnavailable:
            if (_clientState == ClientStateSearchingForServers){
                if ([_availableServers containsObject:peerID]){
                    [_availableServers removeObject:peerID];
                    [self.delegate matchmakingClient:self serverBecameUnavailable:peerID];
                }
            }
			if (_clientState == ClientStateConnecting && [peerID isEqualToString:_serverPeerID])
			{
				[self disconnectFromServer];
			}
            break;
        case GKPeerStateConnected:
            if (_clientState == ClientStateConnecting){
                _clientState = ClientStateConnected;
                [self.delegate matchmakingClient:self didConnectToServer:peerID];
            }
            break;
        case GKPeerStateConnecting:
            break;
        case GKPeerStateDisconnected:
            if (_clientState == ClientStateConnected){
                [self disconnectFromServer];
            }
            break;
            
        default:
            break;
    }
}

-(void) disconnectFromServer{
    NSAssert(_clientState != ClientStateIdle, @"Wrong state");
    _clientState = ClientStateIdle;
    
    [_session disconnectFromAllPeers];
    _session.available = NO;
    _session.delegate = nil;
    _session = nil;
    
    _availableServers = nil;
    
    [self.delegate matchmakingClient:self didDisconnectFromServer:_serverPeerID];
    _serverPeerID = nil;
}

-(NSUInteger) availableServerCount{
    return [_availableServers count];
}
- (NSString *) peerIDForAvailableServerAtIndex:(NSUInteger)index{
    return [_availableServers objectAtIndex:index];
}
- (NSString *) displayNameForPeerID:(NSString *)peerID{
    return [_session displayNameForPeer:peerID];
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    #ifdef DEBUG
        NSLog(@"MatchMakingClient: request from peer %@", peerID);
    #endif
    
}
-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
    #ifdef DEBUG
        NSLog(@"MatchMakingClient: connection with peer %@ failed %@", peerID, error);
    #endif
    [self disconnectFromServer];
}
-(void)session:(GKSession *)session didFailWithError:(NSError *)error{
    #ifdef DEBUG
        NSLog(@"MatchMakingClient: session failed %@", error);
    #endif
            NSLog(@"MatchMakingClient: session failed %@", error);
    if ([[error domain] isEqualToString:GKSessionErrorDomain]){
        if([error code] == GKSessionCannotEnableError){
            [self.delegate matchmakingClientNoNetwork:self];
            [self disconnectFromServer];
        }
    }
}
@end
