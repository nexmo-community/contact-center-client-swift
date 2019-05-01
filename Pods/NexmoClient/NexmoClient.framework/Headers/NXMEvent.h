//
//  NXMEvent.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEnums.h"

@interface NXMEvent : NSObject

@property (nonatomic, strong, nonnull) NSString *conversationId;
@property (nonatomic, strong, nonnull) NSString *fromMemberId;
@property (nonatomic, strong, nonnull) NSDate *creationDate;
@property (nonatomic, strong, nullable) NSDate *deletionDate;
@property NXMEventType type;
@property NSInteger sequenceId;

@end
