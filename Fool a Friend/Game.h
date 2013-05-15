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
#import "Deck.h"
typedef enum
{
	GameStateWaitingForSignIn,
	GameStateWaitingForReady,
	GameStateDealing,
	GameStatePlaying,
    GameStateMakingLies,
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
-(void)gameShouldLoadDeck:(Game *)game;
-(void)game:(Game *)game showCardToReader:(Card*)card;
-(void)game:(Game *)game showQuestionToPlayers:(Card *)card;
-(void)game:(Game *)game playerDidDisconnect:(Player *)player redistributedCards:(NSDictionary *)redistributedCards;
-(void)game:(Game *)game didActivatePlayer:(Player *)player;
-(void)game:(Game *)game player:(Player *)player turnedOverCard:(Card *)card;
-(void)game:(Game *)game loadAnswersForReader:(NSArray *)answers;
-(void)game:(Game *)game loadAnswersForLiars:(NSArray *)answers;
-(void)revealAnswersForVoting;

@end

@interface Game : NSObject<GKSessionDelegate>{
    NSMutableDictionary *_players;
    BOOL _firstTime;
    BOOL _busyDealing;
    BOOL _hasTurnedCard;
    int _sendPacketNumber;
    GameState _state;
    Deck *_deck;
    Card *_currentCard;
    GKSession *_session;
    NSString *_serverPeerID;
    NSString *_clientPeerID;
    NSString *_localPlayerName;
    int _startingPlayerPosition;
    int _activePlayerPosition;
}

@property (nonatomic, weak) id <GameDelegate> delegate;
@property (nonatomic) BOOL isServer;
@property (nonatomic, strong) Player *currentUser;

-(NSDictionary *)getPlayers;
-(Deck *) getDeck;
-(void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;
-(void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
-(void)beginRound;
-(void)drawCardForActivePlayer;
-(void)sendQuestionToClients:(Card *)card;
-(void)playerDidAnswer:(NSString *)answer;
-(void)sendAnswersToVote;
@end
