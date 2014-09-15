//
//  ChatViewController.m
//  MatchedUp
//
//  Created by David Pirih on 14.09.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong,nonatomic) PFUser *withUser;
@property (strong,nonatomic) PFUser *currentUser;
@property (strong,nonatomic) UIImage *withUserPicture;
@property (strong,nonatomic) UIImage *currentUserPicture;

@property (strong,nonatomic)  NSTimer *chatTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong,nonatomic) NSMutableArray *chats;

@end

@implementation ChatViewController


#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    
    if ([testUser1.objectId isEqual:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[@"user2"];
    }
    else {
        self.withUser = self.chatRoom[@"user1"];
    }
    self.title = self.withUser[kUserProfileKey][kUserProfileFirstnameKey];
    self.sender = self.currentUser[kUserProfileKey][kUserProfileFirstnameKey];
    
    self.initialLoadComplete = NO;
    
    // Create avatar with initials images
    CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
    CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
    
    NSMutableString *currentUserInitials = [[NSMutableString alloc] init];
    NSString *currentUserInitialsFirstname = [self.currentUser[kUserProfileKey][kUserProfileFirstnameKey] substringToIndex:1];
    NSString *currentUserInitialsLastName = [self.currentUser[kUserProfileKey][kUserProfileLastnameKey] substringToIndex:1];
    [currentUserInitials appendString:currentUserInitialsFirstname];
    [currentUserInitials appendString:currentUserInitialsLastName];
    self.currentUserPicture = [JSQMessagesAvatarFactory avatarWithUserInitials:currentUserInitials
                                                            backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                    font:[UIFont systemFontOfSize:14.0f]
                                                                diameter:outgoingDiameter];
    
    NSMutableString *withUserInitials = [[NSMutableString alloc] init];
    NSString *withUserInitialsFirstname = [self.withUser[kUserProfileKey][kUserProfileFirstnameKey] substringToIndex:1];
    NSString *withUserInitialsLastname = [self.withUser[kUserProfileKey][kUserProfileLastnameKey] substringToIndex:1];
    [withUserInitials appendString:withUserInitialsFirstname];
    [withUserInitials appendString:withUserInitialsLastname];
    self.withUserPicture = [JSQMessagesAvatarFactory avatarWithUserInitials:withUserInitials
                                                              backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                    textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                         font:[UIFont systemFontOfSize:14.0f]
                                                                     diameter:incomingDiameter];
    
    self.avatars = @{ self.currentUser[kUserProfileKey][kUserProfileFirstnameKey] : self.currentUserPicture,
                      self.withUser[kUserProfileKey][kUserProfileFirstnameKey] : self.withUserPicture };
    
    // Update avatar with user picture in backgound
    //[self loadPictureForAvatar];
    
    
    // Create bubble images.
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    /* Remove camera button since media messages are not yet implemented */
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    // load chats from parse initialy and continuesly every 15s
    [self checkForNewChats];
    self.chatTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.chatTimer invalidate];
    self.chatTimer = nil;
}

#pragma mark - Lazy instantition

-(NSMutableArray *)messages {
    if (!_messages) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

#pragma mark - Helper Methods

-(void)loadPictureForAvatar {
    // Create avatar images from parse data
    CGFloat outgoingDiameter = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
    CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
    
    PFQuery *currentUserQuery = [PFQuery queryWithClassName:kPhotoClassKey];
    [currentUserQuery whereKey:kPhotoUserKey equalTo:self.currentUser];
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.currentUserPicture = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data]
                                                                        diameter:outgoingDiameter];
                self.avatars = @{ self.currentUser[kUserProfileKey][kUserProfileFirstnameKey] : self.currentUserPicture,
                                  self.withUser[kUserProfileKey][kUserProfileFirstnameKey] : self.withUserPicture };
                [self.collectionView reloadData];
                
            }];
        }
    }];
    
    PFQuery *withUserQuery = [PFQuery queryWithClassName:kPhotoClassKey];
    [withUserQuery whereKey:kPhotoUserKey equalTo:self.withUser];
    
    [withUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.withUserPicture = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data]
                                                                          diameter:incomingDiameter];
                self.avatars = @{ self.currentUser[kUserProfileKey][kUserProfileFirstnameKey] : self.currentUserPicture,
                                  self.withUser[kUserProfileKey][kUserProfileFirstnameKey] : self.withUserPicture };
                [self.collectionView reloadData];
            }];
        }
    }];
}

-(void)checkForNewChats {
    int oldChatCount = (int)[self.messages count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatRoom];
    [queryForChats includeKey:@"fromUser"];
    [queryForChats includeKey:@"toUser"];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]) {
                self.showTypingIndicator = !self.showTypingIndicator;
                
                if (self.initialLoadComplete == YES ) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                self.initialLoadComplete = YES;
            
                for (PFObject *object in objects) {
                    PFUser *user = object[@"fromUser"];
                    [self.messages addObject:[[JSQMessage alloc] initWithText:object[@"text"] sender:user[kUserProfileKey][kUserProfileFirstnameKey] date:[NSDate distantPast]]];
                }
                [self scrollToBottomAnimated:YES];
                [self finishReceivingMessage];
            }
        }
    }];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        [chat setObject:self.chatRoom forKey:@"chatroom"];
        [chat setObject:[PFUser currentUser] forKey:kActivityFromUserKey];
        [chat setObject:self.withUser forKey:kActivityToUserKey];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
            JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
            [self.messages addObject:message];
            
            [self finishSendingMessage];
        }];
    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    UIImage *avatarImage = [self.avatars objectForKey:message.sender];
    return [[UIImageView alloc] initWithImage:avatarImage];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
     /* Show a timestamp for every 3rd message */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /* Override point for customizing cells */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /* Show a timestamp for every 3rd message */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}
@end
