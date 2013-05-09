//
//  MatchMakingServer.m
//  Snap
//
//  Created by Alex Reynolds on 5/4/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "MatchMakingServer.h"

@implementation MatchMakingServer
@synthesize maxClients = _maxClients;
@synthesize session = _session;
@synthesize delegate = _delegate;

- (id) init{
    self = [super init];
    if (self){
        _serverState = ServerStateIdle;
        
    }
    return self;
}
- (void) startAcceptionConnectionsForSessionID:(NSString *)sessionID{
    if (_serverState == ServerStateIdle){
        _serverState = ServerStateAcceptingConnections;
        NSLog(@"start accepting connections %@", sessionID);
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
    }

    
}
- (NSArray *)connectedClients
{
    return _connectedClients;
}
- (NSUInteger) connectedClientsCount{
    return [_connectedClients count];
}
- (NSString *) peerIDForConnectedClientAtIndex:(NSUInteger)index{
    return [_connectedClients objectAtIndex:index];
}

- (NSString *) displayNameForPeerID:(NSString *)peerID{
    return [_session displayNameForPeer:peerID];
}
-(void) session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    #ifdef DEBUG
        NSLog(@"MatchMakingServer: peer %@ changed state %d", peerID, state);
    #endif
     NSLog(@"MatchMakingServer: peer %@ changed state %d", peerID, state);
    switch (state) {
        case GKPeerStateConnected:
            if (_serverState == ServerStateAcceptingConnections){
                if(![_connectedClients containsObject:peerID]){
                    [_connectedClients addObject:peerID];
                    [self.delegate matchmakingServer:self clientDidConnect:peerID];
                }
            }
            break;
        case GKPeerStateDisconnected:
            if (_serverState == ServerStateAcceptingConnections){
                if([_connectedClients containsObject:peerID]){
                    [_connectedClients removeObject:peerID];
                    [self.delegate matchmakingServer:self clientDidDisconnect:peerID];
                }
            }
            break;
        case GKPeerStateConnecting:
            
            break;
        case GKPeerStateUnavailable:
            
            break;
        case GKPeerStateAvailable:
            
            break;
        default:
            break;
    }
}

-(void) session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID{
    #ifdef DEBUG
        NSLog(@"MatchMakingServer: connection request from peer %@", peerID);
    #endif
       NSLog(@"MatchMakingServer: connection request from peer %@", peerID);
    if (_serverState == ServerStateAcceptingConnections && [self connectedClientsCount] < self.maxClients){
        NSError *error;
        if([session acceptConnectionFromPeer:peerID error:&error]){
            NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
        } else {
            NSLog(@"MatchmakingServer: Error accepting connection from peer %@ error: %@", peerID, error);
        }
    } else {
        [session denyConnectionFromPeer:peerID];
    }
}
- (void) session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error{
    #ifdef DEBUG
        NSLog(@"MatchMakingServer: connection with peer %@ failed %@", peerID, error);
    #endif
}
-(void) session:(GKSession *)session didFailWithError:(NSError *)error{
    #ifdef DEBUG
        NSLog(@"MatchMakingServer: session failed %@", error);
    #endif
           NSLog(@"MatchMakingServer: session failed %@", error);
    if([[error domain] isEqualToString:GKSessionErrorDomain]){
        if ([error code] == GKSessionCannotEnableError){
            [self.delegate matchmakingServerNoNetwork:self];
            [self endSession];
        }
    }
}

- (void) stopAcceptingConnections{
    NSAssert(_serverState == ServerStateAcceptingConnections, @"Wrong State");
    _serverState = ServerStateIgnoringNewConnections;
    _session.available = NO;
}

-(void) endSession{
    NSAssert(_serverState != ServerStateIdle, @"Wrong State");
    
    _serverState = ServerStateIdle;
    [_session disconnectFromAllPeers];
    _session.available = NO;
    _session.delegate = nil;
    _session = nil;
    
    _connectedClients = nil;
    
    [self.delegate matchmakingServerSessionDidEnd:self];
}
@end
