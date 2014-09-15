//
//  TestUser.m
//  MatchedUp
//
//  Created by David Pirih on 13.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

+(void)saveTestUserToParse {
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{kUserProfileCalculatedAgeKey : @20, kUserProfileBirthdayKey : @"26/09/2010", kUserProfileFirstnameKey : @"Alisha", kUserProfileLastnameKey : @"Pirih", kUserProfileGenderKey : @"female", kUserProfileInterestedInKey : @"male", kUserProfileNameKey : @"Alisha Pirih", kUserProfileRelationshipStatusKey : @"single", kUserProfileLocationKey : @"Gütersloh"  };
            [newUser setObject:profile forKey:kUserProfileKey];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"alisha.jpg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
                        [photo setObject:newUser forKey:kPhotoUserKey];
                        [photo setObject:photoFile forKey:kPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Photo saved successfully.");
                        }];
                    } else {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }];
        }
    }];
}

@end
