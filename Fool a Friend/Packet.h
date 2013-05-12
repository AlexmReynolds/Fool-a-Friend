//
//  Packet.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>


const size_t PACKET_HEADER_SIZE;
typedef enum
{
	PacketTypeSignInRequest = 0x64,    // server to client
	PacketTypeSignInResponse,          // client to server
    
	PacketTypeServerReady,             // server to client
	PacketTypeClientReady,             // client to server
    
	PacketTypeClientSpecious,          // client specious answers to server
	PacketTypeSetupGameDeck,               // server sends question to clients to answer
    PacketTypeClientDeckSetupResponse,
    PacketServerGameReady,
    
	PacketTypeActivatePlayer,          // server to client
	PacketTypeCardRead,                // client read card and hit button.
    PacketTypeClientTurnedCard,
    
	PacketTypeAllAnswersSubmitted,     // server to client to give all answers to active player
	PacketTypeAllLiesRead,              // client to server
    PacketTypeOpenVoting,               // server to clients to start voting
    PacketTypeVoteSubmitted,          // client to server with vote.
    
    
	PacketTypeOtherClientQuit,         // server to client
	PacketTypeServerQuit,              // server to client
	PacketTypeClientQuit,              // client to server
}PacketType;
@interface Packet : NSObject

@property (nonatomic, assign) int packetNumber;
@property (nonatomic) PacketType packetType;

+ (id)packetWithType:(PacketType)packetType;
+ (id)packetWithData:(NSData *)data;
- (id)initWithType:(PacketType)packetType;
+ (NSMutableArray *)cardsFromData:(NSData *)data atOffset:(size_t)offset;
-(void)addCards:(NSArray *)cards toPayload:(NSMutableData *)data;

-(NSData *)data;
@end
