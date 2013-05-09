//
//  NSData+FoolAFriend.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "NSData+FoolAFriend.h"

@implementation NSData (FoolAFriend)

-(int) ar_int32AtOffset:(size_t)offset
{
    const int *intBytes = (const int *)[self bytes];
    return ntohl(intBytes[offset / 4]);
}
-(short) ar_int16AtOffset:(size_t)offset{
    const short *shortBytes = (const short *)[self bytes];
    return ntohs(shortBytes[offset / 2]);
}

-(char) ar_int8AtOffset:(size_t)offset{
    const char *charBytes = (const char *)[self bytes];
    return charBytes[offset];
}
-(NSString *) ar_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount{
    const char *charBytes = (const char *)[self bytes];
    NSString *string = [NSString stringWithUTF8String:charBytes + offset];
    *amount = strlen(charBytes + offset) + 1;
    return string;
}
@end
@implementation NSMutableData (FoolAFriend)

-(void)ar_appendInt32:(int)value{
    value = htonl(value);
    [self appendBytes:&value length:4];
}
-(void)ar_appendInt16:(int)value{
    value = htons(value);
    [self appendBytes:&value length:2];
}
-(void)ar_appendInt8:(int)value{
    [self appendBytes:&value length:1];
}
-(void)ar_appendString:(NSString *)string{
    const char *cString = [string UTF8String];
    [self appendBytes:cString length:strlen(cString) +1];
    
}
@end