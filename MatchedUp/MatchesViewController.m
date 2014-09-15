//
//  MatchesViewController.m
//  MatchedUp
//
//  Created by David Pirih on 14.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "MatchesViewController.h"
#import "ChatViewController.h"

@interface MatchesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;

@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvailableChatRooms];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy instantiation

-(NSMutableArray *)availableChatRooms {
    if (!_availableChatRooms) {
        _availableChatRooms = [[NSMutableArray alloc] init];
    }
    return _availableChatRooms;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toChatSegue"]) {
        NSIndexPath *path = sender;
        
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.chatRoom = self.availableChatRooms[path.row];
    }
}

#pragma mark - Helper Methods

-(void)updateAvailableChatRooms {
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [combinedQuery includeKey:@"chat"];
    [combinedQuery includeKey:@"user1"];
    [combinedQuery includeKey:@"user2"];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatRooms removeAllObjects];
            [self.availableChatRooms addObjectsFromArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];

    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFObject *chatroom = [self.availableChatRooms objectAtIndex:indexPath.row];
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatroom[@"user1"];
    
    // better comparing user by this unique ID
    if ([testUser1.objectId isEqual:currentUser.objectId]) {
        likedUser = [chatroom objectForKey:@"user2"];
    }
    else {
        likedUser = [chatroom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = likedUser[kUserProfileKey][kUserProfileFirstnameKey];
    cell.detailTextLabel.text = likedUser[kUserProfileKey][kUserProfileBirthdayKey];
    
    //cell.imageView.image = ((placeholder image))
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:kPhotoClassKey];
    [queryForPhoto whereKey:@"user" equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.contentMode = UIViewContentModeScaleAspectFit;
                [self.tableView reloadData];
            }];
        }
    }];
    
    return cell;
    
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"toChatSegue" sender:indexPath];

}

@end
