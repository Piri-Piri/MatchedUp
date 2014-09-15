//
//  ProfileViewController.m
//  MatchedUp
//
//  Created by David Pirih on 13.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFFile *pictureFile = self.photo[kPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    
    PFUser *user = self.photo[kPhotoUserKey];
    self.locationLabel.text = user[kUserProfileKey][kUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kUserProfileKey][kUserProfileCalculatedAgeKey]];
    self.statusLabel.text = user[kUserProfileKey][kUserProfileRelationshipStatusKey];
    self.taglineLabel.text = user[kUserProfileKey][kUserTagLineKey];
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

@end
