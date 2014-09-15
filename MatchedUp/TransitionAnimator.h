//
//  TransitionAnimator.h
//  MatchedUp
//
//  Created by David Pirih on 15.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
