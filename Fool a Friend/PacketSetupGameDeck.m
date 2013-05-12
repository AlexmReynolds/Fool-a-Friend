//
//  PacketSetupGameDeck.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/11/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketSetupGameDeck.h"
#import "NSData+FoolAFriend.h"

@implementation PacketSetupGameDeck
@synthesize cards = _cards;
@synthesize startingPeerID = _startingPeerID;

+(id)packetWithCards:(NSArray *)cards startingWithPlayerPeerID:(NSString *)startingPeerID
{
    return [[[self class] alloc] initWithCards:cards startingWithPlayerPeerID:startingPeerID];
}
-(id) initWithCards:(NSArray *)cards startingWithPlayerPeerID:(NSString *)startingPeerID{
    self = [super initWithType:PacketTypeSetupGameDeck];
    if (self){
        self.cards = cards;
        self.startingPeerID = startingPeerID;
    }
    return self;
}
+(id) packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    
    NSString *startingPeerID = [data ar_stringAtOffset:offset bytesRead:&count];
    offset +=count;
    NSMutableArray *cards =[[self class]cardsFromData:data atOffset:offset];
    
    return [[self class] packetWithCards:cards startingWithPlayerPeerID:startingPeerID];
}
-(void) addPayloadToData:(NSMutableData *)data
{
    [data ar_appendString:self.startingPeerID];
    [self addCards:self.cards toPayload:data];
}
@end
