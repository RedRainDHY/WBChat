//
//  WBChatMessageImageCell.m
//  WBChat
//
//  Created by RedRain on 2018/2/5.
//  Copyright © 2018年 RedRain. All rights reserved.
//

#import "WBChatMessageImageCell.h"
#import "WBChatMessageImageCellModel.h"

@interface WBChatMessageImageCell()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) UIImageView *dialogCellImageView;
@property (nonatomic, strong) UILabel *picProcessLabel;
@property (nonatomic, strong) UIImageView *picProcessImageView;
@property (nonatomic, strong) CALayer *cutMaskBorderLayer;

@property (nonatomic, weak) WBMessageModel * tempChatModel;

@end
@implementation WBChatMessageImageCell
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"WBChatMessageImageCell";
    WBChatMessageImageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[WBChatMessageImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.dialogCellImageView];
        
        
        [self.dialogCellImageView addSubview:self.picProcessImageView];
        [self.dialogCellImageView addSubview:self.picProcessLabel];
        
    }
    return self;
}


- (void)setCellModel:(WBChatMessageBaseCellModel *)cellModel{
    [super setCellModel:cellModel];
    
    //1.设置图片显示位置及图片
    WBChatMessageImageCellModel *imageFrameModel = (WBChatMessageImageCellModel *)cellModel;
    
    self.dialogCellImageView.frame = imageFrameModel.imageRectFrame;
    self.tempChatModel = imageFrameModel.messageModel;

    if (self.tempChatModel.thumbImage) {
        self.dialogCellImageView.image = self.tempChatModel.thumbImage;
    }
    
    
    //apply mask to image layer￼
    self.cutMaskBorderLayer.frame = self.dialogCellImageView.bounds;
    self.cutMaskBorderLayer.contents = (__bridge id)self.bubbleImageView.image.CGImage;
    self.dialogCellImageView.layer.mask = self.cutMaskBorderLayer;
    
    //2.给图片添加气泡的形状
    self.bubbleImageView.frame = self.dialogCellImageView.frame;
    
    //3.给图片添加进度显示效果--添加进度圈及进度百分比
    if (self.tempChatModel.status == AVIMMessageStatusSending) {
        self.picProcessImageView.hidden = NO;
        self.picProcessLabel.hidden = NO;
        self.picProcessImageView.frame = imageFrameModel.imageProcessRectFrame;
        self.picProcessLabel.frame = imageFrameModel.labelProcessRectFrame;
    } else {
        self.picProcessLabel.hidden = YES;
        self.picProcessImageView.hidden = YES;
    }
}


#pragma mark - Getter
- (CALayer *)cutMaskBorderLayer{
    if (!_cutMaskBorderLayer) {
        _cutMaskBorderLayer = [CALayer layer];
        _cutMaskBorderLayer.contentsCenter = CGRectMake(0.5, 0.8, 0.1, 0.1);
        _cutMaskBorderLayer.contentsScale = 2;
        
    }
    return _cutMaskBorderLayer;
}


- (UIImageView *)dialogCellImageView {
    if (!_dialogCellImageView) {
        _dialogCellImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _dialogCellImageView.userInteractionEnabled = NO;
        _dialogCellImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _dialogCellImageView;
}

- (UILabel *)picProcessLabel {
    if (_picProcessLabel == nil) {
        _picProcessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _picProcessLabel.textColor = [UIColor whiteColor];
        _picProcessLabel.textAlignment = NSTextAlignmentCenter;
        _picProcessLabel.font = [UIFont systemFontOfSize:15];
        _picProcessLabel.text = [NSString stringWithFormat:@"%.0f%%",0.00];
    }
    return _picProcessLabel;
}

- (UIImageView *)picProcessImageView {
    if (_picProcessImageView == nil) {
        _picProcessImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_icon"]];
    }
    // 1,图片旋转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithInt:0];
    animation.toValue = [NSNumber numberWithInt:2*M_PI];
    animation.duration = 1;
    animation.autoreverses = NO ;
    animation.repeatCount = INT16_MAX;
    animation.removedOnCompletion = NO;
    [_picProcessImageView.layer addAnimation:animation forKey:@"rotateAnimation"];
    return _picProcessImageView;
}
@end
