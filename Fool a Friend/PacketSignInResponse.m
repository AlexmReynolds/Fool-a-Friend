//
//  PacketSignInResponse.m
//  Snap
//
//  Created by Alex Reynolds on 5/5/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "PacketSignInResponse.h"
#import "NSData+FoolAFriend.h"

@implementation PacketSignInResponse

+(id) packetWithPlayerName:(NSString *)playerName{
    return [[[self class] alloc] initWithPlayerName:playerName];
}
-(id) initWithPlayerName:(NSString *)playerName
{
    if (self = [super initWithType:PacketTypeSignInResponse]){
        self.playerName = playerName;
    }
    return self;
}
+ (id)packetWithData:(NSData *)data
{
	size_t count;
	NSString *playerName = [data ar_stringAtOffset:PACKET_HEADER_SIZE bytesRead:&count];
	return [[self class] packetWithPlayerName:playerName];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendString:self.playerName];
}
@end
