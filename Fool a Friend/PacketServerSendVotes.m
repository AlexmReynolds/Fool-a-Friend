//
//  PackerServerSendVotes.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketServerSendVotes.h"
#import "NSData+FoolAFriend.h"

@implementation PacketServerSendVotes
+(id) packetWithVotes:(NSArray *)votes{
    return [[[self class] alloc] initWithVotes:votes];
}
-(id) initWithVotes:(NSArray *)votes
{
    if (self = [super initWithType:PacketTypeAllVotesSubmitted]){
        self.votes = votes;
    }
    return self;
}
+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    int votesCount = [data ar_int8AtOffset:offset];
    offset += 1;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:votesCount];
    for (int t = 0; t < votesCount; ++t){
        int votes = [data ar_int8AtOffset:offset];
        offset += 1;
        NSString *peerID = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:votes],@"votes", peerID, @"peerID", nil]];
    }
	return [[self class] packetWithVotes:array];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendInt8:[self.votes count]];
    for (NSDictionary *response in self.votes){
        [data ar_appendInt8:[[response valueForKey:@"votes"] intValue]];
        [data ar_appendString:[response valueForKey:@"peerID"]];
    }
    
}
@end
