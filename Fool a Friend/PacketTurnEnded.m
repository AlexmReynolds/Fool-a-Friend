//
//  PacketTurnEnded.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketTurnEnded.h"
#import "NSData+FoolAFriend.h"
#import "Player.h"
@implementation PacketTurnEnded


+(id)packetWithPlayers:(NSMutableDictionary *)players
{
    return [[[self class] alloc] initWithPlayers:players];
}

-(id)initWithPlayers:(NSMutableDictionary *)players
{
    self = [super initWithType:PacketTypeServerTurnEnded];
    if(self){
        self.players = players;
    }
    return self;
}

-(void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendInt8:[self.players count]];
    [self.players enumerateKeysAndObjectsUsingBlock:^(id key, Player *player, BOOL *stop) {
        [data ar_appendString:player.peerID];
        [data ar_appendString:player.name];
        [data ar_appendInt8:player.position];
        [data ar_appendInt8:player.points];
    }];
}
+(id) packetWithData:(NSData *)data
{
    NSMutableDictionary *players = [NSMutableDictionary dictionaryWithCapacity:4];
    
    size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    
    // Go to the end of the header to start reading the info
    int numberOfPlayers = [data ar_int8AtOffset:offset];
    offset += 1;
    for (int t = 0; t < numberOfPlayers; ++t){
        NSString *peerID = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        
        NSString *name = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        
        int position = [data ar_int8AtOffset:offset];
        offset +=1;
        
        int points = [data ar_int8AtOffset:offset];
        offset +=1;
        
        Player *player = [[Player alloc] init];
        player.peerID = peerID;
        player.name = name;
        player.position = position;
        player.points = points;
        [players setObject:player forKey:peerID];
    }
    return [[self class] packetWithPlayers:players];
}

@end
