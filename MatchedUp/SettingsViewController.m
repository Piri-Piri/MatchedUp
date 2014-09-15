//
//  SettingsViewController.m
//  MatchedUp
//
//  Created by David Pirih on 12.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UISlider *ageSilder;
@property (weak, nonatomic) IBOutlet UISwitch *showMenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showWomenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *singlesOnlySwitch;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ageSilder.value = [[NSUserDefaults standardUserDefaults] integerForKey:kAgeMaxKey];
    self.showMenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kMenEnabledKey];
    self.showWomenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kWomenEnabledKey];
    self.singlesOnlySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSingleEnabledKey];
    
    [self.ageSilder addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.showMenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.showWomenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singlesOnlySwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSilder.value];
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

#pragma mark - IBACtions Methods

- (IBAction)logoutAction:(UIButton *)sender {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editProfileAction:(id)sender {
    
}

#pragma mark - Helper Methods

-(void)valueChanged:(id)sender {
    if (sender == self.ageSilder) {
        [[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSilder.value forKey:kAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSilder.value];
    } else if (sender == self.showMenSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showMenSwitch.isOn forKey:kMenEnabledKey];
    } else if (sender == self.showWomenSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.showWomenSwitch.isOn forKey:kWomenEnabledKey];
    } else if (sender == self.singlesOnlySwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.singlesOnlySwitch.isOn forKey:kSingleEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
