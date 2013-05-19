//
//  PacketServerSendAnswers.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/13/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "PacketServerSendAnswers.h"
#import "NSData+FoolAFriend.h"

@implementation PacketServerSendAnswers

+(id) packetWithAnswers:(NSArray *)answers{
    return [[[self class] alloc] initWithAnswers:answers];
}
-(id) initWithAnswers:(NSArray *)answers
{
    if (self = [super initWithType:PacketTypeAllAnswersSubmitted]){
        self.answers = answers;
    }
    return self;
}
+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    int answersCount = [data ar_int8AtOffset:offset];
    offset += 1;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:answersCount];
    for (int t = 0; t < answersCount; ++t){
        NSString *answer = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        NSString *name = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        NSString *peerID = [data ar_stringAtOffset:offset bytesRead:&count];
        offset += count;
        
        NSLog(@"answer from packet is %@", answer);
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:answer,@"answer",name,@"name", peerID, @"peerID", nil]];
    }
	return [[self class] packetWithAnswers:array];
}

- (void)addPayloadToData:(NSMutableData *)data
{
    [data ar_appendInt8:[self.answers count]];
    for (NSDictionary *response in self.answers){
        [data ar_appendString:[response valueForKey:@"answer"]];
        [data ar_appendString:[response valueForKey:@"name"]];
        [data ar_appendString:[response valueForKey:@"peerID"]];
    }

}
@end
