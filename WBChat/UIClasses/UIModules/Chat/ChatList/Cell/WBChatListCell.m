//
//  WBChatListCell.m
//  WBChat
//
//  Created by RedRain on 2017/12/11.
//  Copyright © 2017年 RedRain. All rights reserved.
//

#import "WBChatListCell.h"
@interface WBChatListCell ()

@property (nonatomic, strong) UIImageView *chatHeaderView; ///< 会话的头像
@property (nonatomic, strong) UILabel *chatTitleLabel; ///< 会话的名称
@property (nonatomic, strong) UILabel *chatMessageLabel; ///< 最后一天聊天记录
@property (nonatomic, strong) UILabel *chatTimeLabel; ///< 时间

@end

@implementation WBChatListCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"WBChatListCell";
    WBChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[WBChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.chatHeaderView];
        [self.contentView addSubview:self.chatTitleLabel];
        [self.contentView addSubview:self.chatMessageLabel];
        [self.contentView addSubview:self.chatTimeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -  Life Cycle
#pragma mark -  UITableViewDelegate
#pragma mark -  CustomDelegate
#pragma mark -  Event Response
#pragma mark -  Notification Callback
#pragma mark -  GestureRecognizer Action
#pragma mark -  Btn Click
#pragma mark -  Private Methods
- (void)setupUI{
    
}
#pragma mark -  Public Methods
+ (CGFloat)cellHeight{
    return 70;
}
#pragma mark -  Getters and Setters
- (void)setCellModel:(WBChatListCellModel *)cellModel{
    _cellModel = cellModel;
    
    self.chatHeaderView.frame = cellModel.chatUserHeaderViewF;
    self.chatHeaderView.image = [UIImage imageNamed:@"header_male"];
    
    self.chatTitleLabel.frame = cellModel.chatTitleF;
    self.chatTitleLabel.text = cellModel.dataModel.name;
    
    self.chatTimeLabel.frame = cellModel.chatTimeF;
    self.chatTimeLabel.text = cellModel.dataModel.lastMessageAt.wb_chatListTimeString;
    
    self.chatMessageLabel.frame = cellModel.chatMessageF;
    self.chatMessageLabel.text = cellModel.dataModel.lastMessage.content;
}



- (UIImageView *)chatHeaderView{
    if (!_chatHeaderView) {
        _chatHeaderView = [[UIImageView alloc]init];
        _chatHeaderView.layer.cornerRadius = 5;
        _chatHeaderView.layer.masksToBounds = YES;
    }
    return _chatHeaderView;
}

- (UILabel *)chatTitleLabel{
    if (!_chatTitleLabel) {
        _chatTitleLabel = [[UILabel alloc]init];
        _chatTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _chatTitleLabel.font = [UIFont systemFontOfSize:16];
        _chatTitleLabel.textColor = [UIColor blackColor];
    }
    return _chatTitleLabel;
}
- (UILabel *)chatMessageLabel{
    if (!_chatMessageLabel) {
        _chatMessageLabel = [[UILabel alloc]init];
        _chatMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _chatMessageLabel.font = [UIFont systemFontOfSize:14];
        _chatMessageLabel.textColor = [UIColor lightGrayColor];
    }
    return _chatMessageLabel;
}
- (UILabel *)chatTimeLabel{
    if (!_chatTimeLabel) {
        _chatTimeLabel = [[UILabel alloc]init];
        _chatTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _chatTimeLabel.font = [UIFont systemFontOfSize:12];
        _chatTimeLabel.textColor = [UIColor lightGrayColor];
        _chatTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _chatTimeLabel;
}

@end