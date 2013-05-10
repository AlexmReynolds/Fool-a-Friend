//
//  Card.h
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    Laws,
    Movies,
    People,
    Events
}CardCategory;


@interface Card : NSObject

@property (nonatomic, readonly) NSString *question;
@property (nonatomic, readonly) NSString *answer;
@property (nonatomic, readonly, assign) CardCategory category;
@property (nonatomic, assign) BOOL isTurnedOver;

- (id) initWithQuestion:(NSString *)question answer:(NSString *)answer andCategory:(CardCategory)category;
- (BOOL)isEqualToCard:(Card *)otherCard;
@end
