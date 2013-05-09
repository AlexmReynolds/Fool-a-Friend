//
//  MatchMakingServer.h
//  Snap
//
//  Created by Alex Reynolds on 5/4/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
	ServerStateIdle,
	ServerStateAcceptingConnections,
	ServerStateIgnoringNewConnections,
}
ServerState;
@class MatchMakingServer;
@protocol MatchmakingServerDelegate <NSObject>

-(void)matchmakingServer:(MatchMakingServer *)server clientDidConnect:(NSString *)peerID;
-(void)matchmakingServer:(MatchMakingServer *)server clientDidDisconnect:(NSString *)peerID;
-(void)matchmakingServerSessionDidEnd:(MatchMakingServer *)server;
-(void)matchmakingServerNoNetwork:(MatchMakingServer *)server;

@end
@interface MatchMakingServer : NSObject <GKSessionDelegate>{
    NSMutableArray *_connectedClients;
    ServerState _serverState;
}

@property (nonatomic) int maxClients;
@property (nonatomic, strong) NSArray *connectedClients;
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, weak) id <MatchmakingServerDelegate> delegate;

-(void) startAcceptionConnectionsForSessionID:(NSString *)sessionID;
-(NSUInteger) connectedClientsCount;
-(NSString *) peerIDForConnectedClientAtIndex:(NSUInteger)index;
-(NSString *) displayNameForPeerID:(NSString*)peerID;
-(void) endSession;
-(void) stopAcceptingConnections;
@end
