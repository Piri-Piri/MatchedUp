//
//  LoginViewController.m
//  MatchedUp
//
//  Created by David Pirih on 11.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // update (already) logged-in users 
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"toHomeSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction Methods

- (IBAction)loginAction:(UIButton *)sender {
    NSArray *permissions = @[@"user_about_me", @"user_birthday", @"user_interests", @"user_relationships", @"user_relationship_details", @"user_location"];
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        //NSLog(@"PFUser: %@", user);
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (!user) {
            if(!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"The Facebook login was canceld" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];

            }
        } else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"toHomeSegue" sender:self];
        }
    }];

}

#pragma mark - Helper Methods

-(void)updateUserInformation {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSDictionary *userDict = (NSDictionary *)result;
            //NSLog(@"FBUser: %@", result);
            
            // Create a URL
            NSString *facebookID = userDict[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if (userDict[kUserProfileNameKey]) {
                userProfile[kUserProfileNameKey] = userDict[kUserProfileNameKey];
            }
            if (userDict[kUserProfileFirstnameKey]) {
                userProfile[kUserProfileFirstnameKey] = userDict[kUserProfileFirstnameKey];
            }
            if (userDict[kUserProfileLastnameKey]) {
                userProfile[kUserProfileLastnameKey] = userDict[kUserProfileLastnameKey];
            }
            if (userDict[kUserProfileLocationKey][kUserProfileLocationNameKey]) {
                userProfile[kUserProfileLocationKey] = userDict[kUserProfileLocationKey][kUserProfileLocationNameKey];
            }
            if (userDict[kUserProfileGenderKey]) {
                userProfile[kUserProfileGenderKey] = userDict[kUserProfileGenderKey];
            }
            if (userDict[kUserProfileBirthdayKey]) {
                userProfile[kUserProfileBirthdayKey] = userDict[kUserProfileBirthdayKey];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDict[kUserProfileBirthdayKey]];
                NSDate *now = [NSDate date];
                
                int age = [now timeIntervalSinceDate: date] / 31536000;
                userProfile[kUserProfileCalculatedAgeKey] = @(age);
                
            }
            if (userDict[kUserProfileInterestedInKey]) {
                userProfile[kUserProfileInterestedInKey] = userDict[kUserProfileInterestedInKey];
            }
            if (userDict[kUserProfileRelationshipStatusKey]) {
                userProfile[kUserProfileRelationshipStatusKey] = userDict[kUserProfileRelationshipStatusKey];
            }
            if ([pictureURL absoluteString]) {
                userProfile[kUserProfilePictureURLKey] = [pictureURL absoluteString];
            }
            
            //NSLog(@"%@", userProfile);
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        }else {
            NSLog(@"Error in Facebook Request:  %@", [error localizedDescription]);
        }
    }];
}

-(void)uploadPFFileToParse:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        NSLog(@"Error: imageData was not found.");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            PFObject *photo = [PFObject objectWithClassName:kPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kPhotoUserKey];
            [photo setObject:photoFile forKey:kPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully.");
            }];
        }
    }];
}

-(void)requestImage {
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number == 0) {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kUserProfileKey][kUserProfilePictureURLKey]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if(!urlConnection) {
                NSLog(@"Failed to download user picture!");
            }
        }
    }];
}

#pragma mark - NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // save image to parse;
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

@end
