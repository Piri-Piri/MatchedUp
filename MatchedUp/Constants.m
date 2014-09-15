//
//  Constants.m
//  MatchedUp
//
//  Created by David Pirih on 12.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - User Class

NSString *const kUserTagLineKey                     = @"tagLine";

/* 
 Keys are used for store obsjets in parse and query facebook properties.
 Ensure the exact match! 
 */
NSString *const kUserProfileKey                     = @"profile";
NSString *const kUserProfileFirstnameKey            = @"first_name";
NSString *const kUserProfileLastnameKey             = @"last_name";
NSString *const kUserProfileNameKey                 = @"name";
NSString *const kUserProfileLocationKey             = @"location";
NSString *const kUserProfileLocationNameKey         = @"name";
NSString *const kUserProfileGenderKey               = @"gender";
NSString *const kUserProfileBirthdayKey             = @"birthday";
NSString *const kUserProfileCalculatedAgeKey        = @"age";
NSString *const kUserProfileInterestedInKey         = @"interested_in";
NSString *const kUserProfilePictureURLKey           = @"pictureURL";
NSString *const kUserProfileRelationshipStatusKey   = @"relationship_status";

#pragma mark - Picture Class

/* Keys are used for store obsjets in parse. */
NSString *const kPhotoClassKey                      = @"Photo";
NSString *const kPhotoUserKey                       = @"user";
NSString *const kPhotoPictureKey                    = @"image";
NSString *const kPhotoTagLineKey                    = @"tagline";

#pragma mark - Activity Class

/* Keys are used for store obsjets in parse. */
NSString *const kActivityClassKey                   = @"Activity";
NSString *const kActivityLikeKey                    = @"like";
NSString *const kActivityDislikeKey                 = @"dislike";
NSString *const kActivityTypeKey                    = @"type";
NSString *const kActivityFromUserKey                = @"fromUser";
NSString *const kActivityToUserKey                  = @"toUser";
NSString *const kActivityPhotoKey                   = @"photo";

#pragma mark - ChatRoom Class

NSString *const kChatRoomClassKey                   = @"ChatRoom";
NSString *const kChatRoomUser1Key                   = @"user1";
NSString *const kChatRoomUser2Key                   = @"user2";

#pragma mark - Chat Class

NSString *const kChatClassKey                       = @"Chat";
NSString *const kChatChatroomKey                    = @"chatroom";
NSString *const kChatFromUserKey                    = @"fromUser";
NSString *const kChatToUserKey                      = @"toUser";
NSString *const kChatTextKey                        = @"text";

#pragma mark - Settings

NSString *const kMenEnabledKey                      = @"men";
NSString *const kWomenEnabledKey                    = @"women";
NSString *const kSingleEnabledKey                   = @"single";
NSString *const kAgeMaxKey                          = @"ageMax";

@end
