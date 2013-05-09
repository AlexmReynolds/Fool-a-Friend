//
//  Communicator.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Packet.h"
@class Communicator;
@protocol CommunicatorDelegate <NSObject>

-(void)serverRecievedPacket:(Packet *)packet;
-(void)clientRecievedPacket:(Packet *)packet;
@end
@interface Communicator : NSObject

@end
