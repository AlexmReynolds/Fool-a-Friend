//
//  Game.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Packet.h"
typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStateDealing,
	GameStatePlaying,
	GameStateGameOver,
	GameStateQuitting,
}
GameState;
@class Game;

@protocol GameDelegate <NSObject>

-(void)game:(Game*)game didQuitWithReason:(QuitReason)reason;
-(void)gameWaitingForServerReady:(Game *)game;
-(void)gameWaitingForClientsReady:(Game *)game;
-(void)gameDidBegin:(Game*)game;
-(void)game:(Game *)game playerDidDisconnect:(Player *)player redistributedCards:(NSDictionary *)redistributedCards;
-(void)gameShouldDealCards:(Game *)game startingWithPlayer:(Player *)startingPlayer;
-(void)game:(Game *)game didActivatePlayer:(Player *)player;
-(void)game:(Game *)game player:(Player *)player turnedOverCard:(Card *)card;
- (void)game:(Game *)game didRecycleCards:(NSArray *)recycledCards forPlayer:(Player *)player;
- (void)game:(Game *)game playerCalledSnapWithNoMatch:(Player *)player;

@end

@interface Game : NSObject<GKSessionDelegate>{
    NSMutableDictionary *_players;
    BOOL _firstTime;
    BOOL _busyDealing;
    BOOL _hasTurnedCard;
    int _sendPacketNumber;
    GameState _state;
    
    GKSession *_session;
    NSString *_serverPeerID;
    NSString *_localPlayerName;
    int _startingPlayerPosition;
    int _activePlayerPosition;
}

@property (nonatomic, weak) id <GameDelegate> delegate;
@property (nonatomic) BOOL isServer;

-(void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;
-(void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;

@end
