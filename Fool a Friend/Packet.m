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
    
    if ([data ar_int32AtOffset:0] != 'SNAP') {
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
        case PacketTypeClientReady:
            packet = [Packet packetWithType:packetType];
            break;
        case PacketTypeSignInResponse:
            break;
        case PacketTypeServerReady:
            break;
        case PacketTypeOtherClientQuit:
            break;
        case PacketTypeActivatePlayer:
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
-(void)addCards:(NSDictionary *)cards toPayload:(NSMutableData *)data
{
    [cards enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *array, BOOL *stop) {
        [data ar_appendString:key];
        [data ar_appendInt8:[array count]];
        
        for (int t = 0; t <[array count]; ++t){
            Card *card = [array objectAtIndex:t];
            [data ar_appendString:card.question];
            [data ar_appendString:card.answer];
            [data ar_appendInt8:card.category];
        }
    }];
}
+(NSMutableDictionary *)cardsFromData:(NSData *)data atOffset:(size_t)offset
{
    size_t count;
    NSMutableDictionary *cards = [NSMutableDictionary dictionaryWithCapacity:4];
    
    while (offset < [data length]){
        NSString *peerID = [data ar_stringAtOffset:offset bytesRead:&count];
        offset +=count;
        
        int numberOfCards = [data ar_int8AtOffset:offset];
        offset +=1;
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:numberOfCards];
        for (int t = 0; t < numberOfCards; ++t){
            NSString *question = [data ar_stringAtOffset:offset bytesRead:&count];
            offset += count;
            
            NSString *answer = [data ar_stringAtOffset:offset bytesRead:&count];
            offset += count;
            
            CardCategory category =  [data ar_int8AtOffset:offset];
            offset += 1;
            
            Card *card = [[Card alloc] initWithQuestion:question answer:answer andCategory:category];
            [array addObject:card];
        }
        [cards setObject:array forKey:peerID];
    }
    return cards;
}

@end
