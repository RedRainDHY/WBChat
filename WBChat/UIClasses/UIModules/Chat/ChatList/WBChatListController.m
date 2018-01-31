//
//  WBChatListController.m
//  WBChat
//
//  Created by RedRain on 2017/11/17.
//  Copyright © 2017年 RedRain. All rights reserved.
//

#import "WBChatListController.h"
#import "WBChatListCell.h"
#import "WBChatViewController.h"
#import "WBServiceSDKHeaders.h"
#import "WBIMDefine.h"

@interface WBChatListController ()
@property (nonatomic, strong) NSMutableArray<WBChatListCellModel *> *dataArray;
@end

@implementation WBChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupObserver];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadListData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  Life Cycle
#pragma mark -  UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WBChatListCell *cell = [WBChatListCell cellWithTableView:tableView];
    cell.cellModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WBChatListCellModel *cellModle = self.dataArray[indexPath.row];
    
    WBChatViewController *vc = [WBChatViewController createWithConversation:cellModle.dataModel.conversation];
    [vc rr_initTitleView:cellModle.title]; 
    [self.navigationController pushViewController:vc animated:YES];
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    WBChatListCellModel *cellModel = nil;
    if ((NSUInteger)indexPath.row < self.dataArray.count) {
        cellModel = self.dataArray[indexPath.row];
    }
    else {
        return nil;
    }
    UITableViewRowAction *actionItemDelete = [UITableViewRowAction
                                              rowActionWithStyle:UITableViewRowActionStyleNormal
                                              title:@"删除"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  AVIMConversation *conversation = cellModel.dataModel.conversation;
                                                  [[WBChatKit sharedInstance] deleteConversation:conversation.conversationId];
                                                  [self reloadListData];                                                  
                                              }];
    actionItemDelete.backgroundColor = [UIColor redColor];
    return @[ actionItemDelete ];
}


#pragma mark -  CustomDelegate
#pragma mark -  Event Response
#pragma mark -  Notification Callback
- (void)connectivityUpdated:(NSNotification *)notifi{
    do_dispatch_async_mainQueue(^{
        WBLog(@"%@",@([WBChatKit sharedInstance].connectStatus));
        switch ([WBChatKit sharedInstance].connectStatus) {
            case AVIMClientStatusOpening:
            case AVIMClientStatusResuming:{
                [self rr_initTitleView:@"链接中..."];
            }
                break;
            case AVIMClientStatusClosed:{
                [self rr_initTitleView:@"未连接"];
            }
                break;
            default:
                [self rr_initTitleView:@"聊呗"];
                break;
        }
    });
}
- (void)conversationDidLoadFromServer:(NSNotification *)notifi{
    [self reloadListData];
}
- (void)receiveNewMessage:(NSNotification *)notifi{
    [self reloadListData];
}
#pragma mark -  GestureRecognizer Action
#pragma mark -  Btn Click
- (void)sendMessageClick{
    
    
    
    

}
#pragma mark -  Private Methods
- (void)setupUI{
    [self rr_initTitleView:@"聊呗"];

    [self.view addSubview:self.tableView];
    self.tableView.rowHeight = [WBChatListCell cellHeight];
}
- (void)setupObserver{

    [self notificationName:WBIMNotificationConnectivityUpdated action:@selector(connectivityUpdated:)];
    [self notificationName:WBIMNotificationDidLoadFromServer action:@selector(conversationDidLoadFromServer:)];
    [self notificationName:WBMessageNewReceiveNotification action:@selector(receiveNewMessage:)];
    
}

- (void)notificationName:(NSString *)name action:(SEL)action{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:action name:name object:nil];
}


- (void)reloadListData {
    [[WBChatKit sharedInstance] fetchAllConversationsFromLocal:^(NSArray<WBChatListModel *> * _Nullable conersations,
                                                                 NSError * _Nullable error) {
        
        NSMutableArray *tempA = [NSMutableArray arrayWithCapacity:conersations.count];
        for (WBChatListModel *obj in conersations) {
            WBChatListCellModel *cellModel = [WBChatListCellModel new];
            cellModel.dataModel = obj;
            [tempA addObject:cellModel];
        }
        self.dataArray = tempA;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.tableView reloadData];
        });
    }];
}
#pragma mark -  Public Methods
#pragma mark -  Getters and Setters
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}
@end

