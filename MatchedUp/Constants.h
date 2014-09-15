//
//  Constants.h
//  MatchedUp
//
//  Created by David Pirih on 12.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User Class

extern NSString *const kUserTagLineKey;

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileFirstnameKey;
extern NSString *const kUserProfileLastnameKey;
extern NSString *const kUserProfileNameKey;
extern NSString *const kUserProfileLocationKey;
extern NSString *const kUserProfileLocationNameKey;
extern NSString *const kUserProfileGenderKey;
extern NSString *const kUserProfileBirthdayKey;
extern NSString *const kUserProfileCalculatedAgeKey;
extern NSString *const kUserProfileInterestedInKey;
extern NSString *const kUserProfilePictureURLKey;
extern NSString *const kUserProfileRelationshipStatusKey;

#pragma mark - Picture Class

extern NSString *const kPhotoClassKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoPictureKey;
extern NSString *const kPhotoTagLineKey;

#pragma mark - Activity Class

extern NSString *const kActivityClassKey;
extern NSString *const kActivityLikeKey;
extern NSString *const kActivityDislikeKey;
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityPhotoKey;

#pragma mark - Settings

extern NSString *const kMenEnabledKey;
extern NSString *const kWomenEnabledKey;
extern NSString *const kSingleEnabledKey;
extern NSString *const kAgeMaxKey;

@end
