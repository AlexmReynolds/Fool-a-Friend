//
//  MatchMakingClient.h
//  Snap
//
//  Created by Alex Reynolds on 5/4/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MatchMakingClient;

@protocol MatchmakingClientDelegate <NSObject>

-(void)matchmakingClient:(MatchMakingClient *)client serverBecameAvailable:(NSString *)peerID;
-(void)matchmakingClient:(MatchMakingClient *)client serverBecameUnavailable:(NSString *)peerID;
-(void)matchmakingClient:(MatchMakingClient *)client didDisconnectFromServer:(NSString *)peerID;
-(void)matchmakingClientNoNetwork:(MatchMakingClient *)client;
-(void)matchmakingClient:(MatchMakingClient *)client didConnectToServer:(NSString *)peerID;


@end
typedef enum
{
	ClientStateIdle,
	ClientStateSearchingForServers,
	ClientStateConnecting,
	ClientStateConnected,
}
ClientState;

@interface MatchMakingClient : NSObject<GKSessionDelegate>{
    @private
    NSMutableArray *_availableServers;
    ClientState _clientState;
    NSString *_serverPeerID;
}

@property (nonatomic, strong) NSArray *availableServers;
@property (nonatomic, strong) GKSession *session;
@property (nonatomic, weak) id <MatchmakingClientDelegate> delegate;

-(void) startSearchingForServersWithSessionID:(NSString *)sessionID;
-(NSUInteger) availableServerCount;
- (NSString *) peerIDForAvailableServerAtIndex:(NSUInteger)index;
- (NSString *) displayNameForPeerID:(NSString *)peerID;
-(void) connectToServerWithPeerID:(NSString *)peerID;
-(void) disconnectFromServer;
@end
