//
//  HomeViewController.m
//  MatchedUp
//
//  Created by David Pirih on 12.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "HomeViewController.h"
#import "TestUser.h"
#import "ProfileViewController.h"
#import "MatchViewController.h"
#import "TransitionAnimator.h"

@interface HomeViewController () <ProfileViewControllerDelegate, MatchViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByUser;
@property (nonatomic) BOOL isDislikedByUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // [TestUser saveTestUserToParse];
    
    [self setupViews];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.profilePictureImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kPhotoClassKey];
    [query whereKey:kPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            if (![self allowPhotos]) {
                [self setupNextPhoto];
            } else {
                [self queryForCurrentPhotoIndex];
            }
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
}

-(void)setupViews {
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.profilePictureImageView.layer.masksToBounds = YES;
    
    //[self addShadowForView:self.profilePictureImageView];
}

-(void)addShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4; // if you like rounded corners
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toProfileSegue"]) {
        ProfileViewController *profileViewController = segue.destinationViewController;
        profileViewController.photo = self.photo;
        profileViewController.delegate = self;
    }
}

#pragma mark - IBActions Methods

- (IBAction)chatAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"toMatchesSegue" sender:nil];
}

- (IBAction)settingsAction:(UIBarButtonItem *)sender {
    
}

- (IBAction)likeAction:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Like"];
    [mixpanel flush];
    
    [self checkLike];
}

- (IBAction)infoAction:(UIButton *)sender {
    [self performSegueWithIdentifier:@"toProfileSegue" sender:nil];
}

- (IBAction)dislikeAction:(UIButton *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Dislike"];
    [mixpanel flush];
    
    [self checkDislike];
}

#pragma mark - Helper Methods 

- (void)queryForCurrentPhotoIndex {
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
                [self updateView];
            }
            else NSLog(@"Error: %@", [error localizedDescription]);
            
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kActivityClassKey];
        [queryForLike whereKey:kActivityTypeKey equalTo:kActivityLikeKey];
        [queryForLike whereKey:kActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kActivityClassKey];
        [queryForDislike whereKey:kActivityTypeKey equalTo:kActivityDislikeKey];
        [queryForDislike whereKey:kActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                // no activity: user is either liked or disliked
                if ([self.activities count] == 0) {
                    self.isLikedByUser = NO;
                    self.isDislikedByUser = NO;
                } else {
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kActivityTypeKey] isEqualToString:kActivityLikeKey]) {
                        self.isLikedByUser = YES;
                        self.isDislikedByUser = NO;
                    }
                    else if ([activity[kActivityTypeKey] isEqualToString:kActivityDislikeKey]) {
                        self.isLikedByUser = NO;
                        self.isDislikedByUser = YES;
                    }
                    else {
                        // other types of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.infoButton.enabled = YES;
                self.dislikeButton.enabled = YES;
            }
        }];
    }
}

- (void)updateView {
    self.firstNameLabel.text = self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileFirstnameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kPhotoUserKey][kUserProfileKey][kUserProfileCalculatedAgeKey]];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex++;
        if (![self allowPhotos]) {
            [self setupNextPhoto];
        } else {
            [self queryForCurrentPhotoIndex];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No more Users to view" message:@"Check back later for more people!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)allowPhotos {
    int maxAge = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kPhotoUserKey];
    
    int userAge = [user[kUserProfileKey][kUserProfileCalculatedAgeKey] intValue];
    NSString *gender = user[kUserProfileKey][kUserProfileGenderKey];
    NSString *relationshipStatus = user[kUserProfileKey][kUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge) {
        return NO;
    }
    else if (men == NO && [gender isEqualToString:@"male"] ) {
        return NO;
    } else if (women == NO && [gender isEqualToString:@"female"] ) {
        return NO;
    }
    else if (single == YES && ![relationshipStatus isEqualToString:@"single"]) {
        return NO;
    } else {
        return YES;
    }
}

-(void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [likeActivity setObject:kActivityLikeKey forKey:kActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // check for likes on both side and if, create a chatroom
        [self checkForPhotoUserLikes];
        self.isLikedByUser = YES;
        self.isDislikedByUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
    
}

-(void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kActivityClassKey];
    [dislikeActivity setObject:kActivityDislikeKey forKey:kActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kPhotoUserKey] forKey:kActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByUser = NO;
        self.isDislikedByUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

-(void) checkLike {
    if(self.isLikedByUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

-(void) checkDislike {
    if(self.isDislikedByUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

-(void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kActivityClassKey];
    [query whereKey:kActivityFromUserKey equalTo:self.photo[kPhotoUserKey]];
    [query whereKey:kActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kActivityTypeKey equalTo:kActivityLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0) {
            // create a chatroom
            [self createChatRoom];
        }
    }];

}

-(void)createChatRoom {
    // user1 likes user2 first
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoom whereKey:kChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kChatRoomUser2Key equalTo:self.photo[kPhotoUserKey]];
    
    // user2 likes user1 first
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kChatRoomUser1Key equalTo:self.photo[kPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if ([objects count] == 0) {
            NSLog(@"Creating a chatroom with matched user.");
            PFObject *chatRoom = [PFObject objectWithClassName:kChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kChatRoomUser1Key];
            [chatRoom setObject:self.photo[kPhotoUserKey] forKey:kChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIStoryboard *storyboard = self.storyboard;
                MatchViewController *matchViewController  = [storyboard instantiateViewControllerWithIdentifier:@"matchViewController"];
                matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.75f];
                matchViewController.transitioningDelegate = self;
                matchViewController.delegate = self;
                matchViewController.matchedUserImage = self.profilePictureImageView.image;
                matchViewController.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:matchViewController animated:YES completion:nil];
            }];
        }
        else {
            NSLog(@"Existing chatroom with matched user found!");
        }
    }];
}

#pragma mark - MatchViewController Delegate

-(void)presentMatchesViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"toMatchesSegue" sender:nil];
    }];
}

#pragma mark - ProfileViewController Delegate

-(void)didPressLike {
    [self.navigationController popViewControllerAnimated:NO];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Like"];
    [mixpanel flush];
    
    [self checkLike];
}

-(void)didPressDislike {
    [self.navigationController popViewControllerAnimated:NO];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Dislike"];
    [mixpanel flush];
    
    [self checkDislike];
}

#pragma mark - UIViewControllerTransitioning Delegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    return animator;
}

@end
