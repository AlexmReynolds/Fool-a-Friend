//
//  Packet.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"
#import "Card.h"
#import "NSData+FoolAFriend.h"
#import "PacketSignInResponse.h"
#import "PacketServerReady.h"
#import "PacketSetupGameDeck.h"
#import "PacketActivatePlayer.h"
#import "PacketClientLieResponse.h"
#import "PacketServerSendAnswers.h"

@implementation Packet

const size_t PACKET_HEADER_SIZE = 10;
@synthesize packetType = _packetType;
@synthesize packetNumber = _packetNumber;

+ (id)packetWithType:(PacketType)packetType{
    return [[[self class] alloc] initWithType:packetType];
}

+ (id)packetWithData:(NSData *)data{
    if([data length] < PACKET_HEADER_SIZE){
        NSLog(@"Error: Packet too small");
        return nil;
    }
    
    if ([data ar_int32AtOffset:0] != 'FAFG') {
        NSLog(@"Error: Packet has invalid header");
        return nil;
    }
    
    int packetNumber = [data ar_int32AtOffset:4];
    PacketType packetType = [data ar_int16AtOffset:8];
    
    Packet *packet;
    
    switch(packetType){
        case PacketTypeClientQuit:
        case PacketTypeServerQuit:
        case PacketTypeSignInRequest:
        case PacketTypeClientDeckSetupResponse:
        case PacketTypeClientReady:
        case PacketServerGameReady:
        case PacketTypeCardRead:
        case PacketTypeClientTurnedCard:
            packet = [Packet packetWithType:packetType];
            break;
        case PacketTypeSignInResponse:
            packet = [PacketSignInResponse packetWithData:data];
            break;
        case PacketTypeServerReady:
            packet = [PacketServerReady packetWithData:data];
            break;
        case PacketTypeOtherClientQuit:
            break;
        case PacketTypeActivatePlayer:
            packet = [PacketActivatePlayer packetWithData:data];
			break;
        case PacketTypeSetupGameDeck:
            packet = [PacketSetupGameDeck packetWithData:data];
            break;
        case PacketTypeClientAnswer:
            packet = [PacketClientLieResponse packetWithData:data];
            break;
        case PacketTypeAllAnswersSubmitted:
            packet = [PacketServerSendAnswers packetWithData:data];
            break;
        default:
            NSLog(@"Error: packet has invalid type");
            break;
    }
    packet.packetNumber = packetNumber;
    
    return packet;
}

-(id)initWithType:(PacketType)packetType{
    if (self = [super init]){
        self.packetNumber = -1;
        self.packetType = packetType;
    }
    return self;
}

-(NSData *)data{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:100];
    
    [data ar_appendInt32:'FAFG'];  //0x534E4150
    [data ar_appendInt32:self.packetNumber];
    [data ar_appendInt16:self.packetType];
    
    [self addPayloadToData:data];
    return data;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ number=%d, type=%d", [super description], self.packetNumber, self.packetType];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    
}
-(void)addCards:(NSArray *)cards toPayload:(NSMutableData *)data
{
    [data ar_appendInt8:[cards count]];
        
    for (int t = 0; t <[cards count]; ++t){
        Card *card = [cards objectAtIndex:t];
        [data ar_appendString:card.question];
        [data ar_appendString:card.answer];
        [data ar_appendInt8:card.category];
    }
}
+(NSMutableArray *)cardsFromData:(NSData *)data atOffset:(size_t)offset
{
    size_t count;

    NSMutableArray *cards;
    while (offset < [data length]){
        
        int numberOfCards = [data ar_int8AtOffset:offset];
        cards = [NSMutableArray arrayWithCapacity:numberOfCards];
        offset +=1;
        for (int t = 0; t < numberOfCards; ++t){
            NSString *question = [data ar_stringAtOffset:offset bytesRead:&count];
            offset += count;
            
            NSString *answer = [data ar_stringAtOffset:offset bytesRead:&count];
            offset += count;

            int category =  [data ar_int8AtOffset:offset];
            offset += 1;
            NSLog(@"adding card with question %@ and category %i",question, category);
            Card *card = [[Card alloc] initWithQuestion:question answer:answer andCategory:category];
            [cards addObject:card];
        }
    }
    return cards;
}

@end
