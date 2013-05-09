//
//  NSData+FoolAFriend.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FoolAFriend)
-(int) ar_int32AtOffset:(size_t)offset;
-(short) ar_int16AtOffset:(size_t)offset;
-(char) ar_int8AtOffset:(size_t)offset;
-(NSString *)ar_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;
@end

@interface NSMutableData (FoolAFriend)

-(void)ar_appendInt32:(int)value;
-(void)ar_appendInt16:(int)value;
-(void)ar_appendInt8:(int)value;
-(void)ar_appendString:(NSString *)string;
@end
