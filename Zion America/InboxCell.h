//
//  inboxCell.h
//  Zion America
//
//  Created by Patrick Asare on 1/2/13.
//  Copyright (c) 2013 Patrick Asare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *unreadMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;

@end
