//
//  PacketClientLieResponse.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/13/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketClientLieResponse.h"
#import "NSData+FoolAFriend.h"
@implementation PacketClientLieResponse

+(id) packetWithAnswer:(NSString *)answer{
    return [[[self class] alloc] initWithAnswer:answer];
}
-(id) initWithAnswer:(NSString *)answer
{
    if (self = [super initWithType:PacketTypeClientAnswer]){
        self.answer = answer;
    }
    return self;
}
+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *answer = [data ar_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
	return [[self class] packetWithAnswer:answer];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendString:self.answer];
}
@end
