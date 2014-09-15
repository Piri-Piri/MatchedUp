//
//  ProfileViewController.h
//  MatchedUp
//
//  Created by David Pirih on 13.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileViewControllerDelegate <NSObject>

@required
-(void)didPressLike;
-(void)didPressDislike;

@end

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak,nonatomic) id <ProfileViewControllerDelegate> delegate;

@end
