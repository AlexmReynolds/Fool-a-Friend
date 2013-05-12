//
//  PacketActivatePlayer.m
//  Snap
//
//  Created by Alex Reynolds on 5/7/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "PacketActivatePlayer.h"
#import "NSData+FoolAFriend.h"

@implementation PacketActivatePlayer
@synthesize peerID = _peerID;

+(id)packetWithPeerID:(NSString *)peerID
{
    return [[[self class] alloc] initWithPeerID:peerID];
}
-(id) initWithPeerID:(NSString *)peerID
{
    self = [super initWithType:PacketTypeActivatePlayer];
    if (self){
        self.packetNumber = 0;
        self.peerID = peerID;
    }
    return self;
}
+(id) packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
    size_t count;
    NSString *peerID = [data ar_stringAtOffset:offset bytesRead:&count];
    return [[self class] packetWithPeerID:peerID];
}
-(void) addPayloadToData:(NSMutableData *)data
{
    [data ar_appendString:self.peerID];
}
@end
