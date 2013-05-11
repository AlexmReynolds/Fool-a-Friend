//
//  PacketSignInResponse.h
//  Snap
//
//  Created by Alex Reynolds on 5/5/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketSignInResponse : Packet

@property (nonatomic, copy) NSString *playerName;

+ (id)packetWithPlayerName:(NSString *)playerName;
@end
