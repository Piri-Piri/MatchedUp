//
//  MatchViewController.h
//  MatchedUp
//
//  Created by David Pirih on 14.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak, nonatomic) id <MatchViewControllerDelegate> delegate;

@end
