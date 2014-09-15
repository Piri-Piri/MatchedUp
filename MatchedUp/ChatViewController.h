//
//  ChatViewController.h
//  MatchedUp
//
//  Created by David Pirih on 14.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessages.h"

@interface ChatViewController : JSQMessagesViewController

@property (strong,nonatomic) PFObject *chatRoom;

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

@end
