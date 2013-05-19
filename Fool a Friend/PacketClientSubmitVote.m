//
//  PacketClientSubmitVote.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketClientSubmitVote.h"
#import "NSData+FoolAFriend.h"
@implementation PacketClientSubmitVote

+(id) packetWithVote:(NSString *)vote{
    return [[[self class] alloc] initWithVote:vote];
}
-(id) initWithVote:(NSString *)vote
{
    if (self = [super initWithType:PacketTypeVoteSubmitted]){
        self.peerID = vote;
    }
    return self;
}
+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *vote = [data ar_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
	return [[self class] packetWithVote:vote];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendString:self.peerID];
}

@end
