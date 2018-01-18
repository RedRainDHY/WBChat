//
//  WBChatListDao.m
//  WBChat
//
//  Created by RedRain on 2018/1/17.
//  Copyright © 2018年 RedRain. All rights reserved.
//

#import "WBChatListDao.h"
#import "WBChatInfoDao.h"

#define WBChatListDaoTableName @"t_ChatList"

#define WBChatListDaoKeyId @"conversationID"
#define WBChatListDaoKeyData @"data"
#define WBChatListDaoKeyUnreadCount @"unreadCount"
#define WBChatListDaoKeyMentioned @"mentioned"
#define WBChatListDaoKeyLastMessageAt @"lastMessageAt"
#define WBChatListDaoKeyExtend @"extend"

@implementation WBChatListDao
WB_SYNTHESIZE_SINGLETON_FOR_CLASS(WBChatListDao)



- (BOOL)createDBTable{
    
    __block BOOL ret=NO;
    NSString *sql =@"CREATE TABLE IF NOT EXISTS t_ChatList(\
    conversationID          VARCHAR(63) PRIMARY KEY,\
    data                    BLOB NOT NULL,\
    unreadCount             INTEGER DEFAULT 0,\
    lastMessageAt           INTEGER DEFAULT 0,\
    mentioned               BOOL DEFAULT FALSE,\
    extend                  Text\
    );";
    
    
    [[WBDBClient sharedInstance].dbQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:sql];
    }];
    
    
    return ret;
}

- (BOOL)insertChatListModel:(WBChatListModel *)chatListModel{
    __block BOOL result = NO;
    
    
    [[WBDBClient sharedInstance].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        @try {
            
            result = [self updateDB:db listModel:chatListModel];
            
            if (result == NO) {
                *rollback = YES;
            }
            
        }@catch (NSException *exception){
            
            result = NO;
            *rollback = YES;
            
        }@finally{
            
        }
        
    }];
    return result;
}

- (BOOL)insertChatListModelArray:(NSArray<WBChatListModel *> *)chatListModelArray{
    __block BOOL result = NO;
    [[WBDBClient sharedInstance].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        @try {
            for (WBChatListModel *model in chatListModelArray) {
                result = [self updateDB:db listModel:model];
                if (result == NO) {
                    *rollback = YES;
                    break;
                }
            }
        }@catch (NSException *exception){
            
            result = NO;
            *rollback = YES;
            
        }@finally{
            
        }
    }];
    return result;
}

- (void)loadChatListWithClient:(AVIMClient *)client result:(void (^)(NSArray<WBChatListModel *> *modelArray))resultBlock{

    __block NSMutableArray *chatListArray = [[NSMutableArray alloc] init];
    
    
    [[WBDBClient sharedInstance].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        @try {
            // 1. 取置顶会话项
            NSString *selectSql =
            [NSString stringWithFormat:
             @"SELECT a.conversationID, a.data, a.unreadCount, a.lastMessageAt, a.mentioned, a.extend,\
             b.topTime, b.draft \
             FROM t_ChatList a left join t_ChatInfo b on (a.conversationID = b.conversationID) \
             WHERE b.topTime > 0  ORDER BY b.topTime desc"];
            
            FMResultSet *resultSet = [db executeQuery:selectSql];
            while ([resultSet next]) {
                WBChatListModel *listModel = [self createChatListModelFromResultSet:resultSet client:client];
                [chatListArray addObject:listModel];
            }
            [resultSet close];
            
            // 2. 取置 非 顶会话项
            selectSql =
            [NSString stringWithFormat:
             @"SELECT a.conversationID, a.data, a.unreadCount, a.lastMessageAt, a.mentioned, a.extend,\
             b.topTime, b.draft \
             FROM t_ChatList a left join t_ChatInfo b on (a.conversationID = b.conversationID) \
             WHERE (b.topTime = 0 Or b.topTime not in (select topTime FROM t_ChatInfo WHERE conversationID = \'a.conversationID\'))\
             order by a.lastMessageAt desc"];
            
            resultSet = [db executeQuery:selectSql];
            while ([resultSet next]) {
                WBChatListModel *listModel = [self createChatListModelFromResultSet:resultSet client:client];
                [chatListArray addObject:listModel];
            }
            [resultSet close];
            
            resultBlock(chatListArray);
        }
        @catch (NSException *exception) {

        }
        @finally {
            resultBlock(chatListArray);
        }
    }];
}

- (NSData *)dataFromConversation:(AVIMConversation *)conversation {
    AVIMKeyedConversation *keydConversation = [conversation keyedConversation];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:keydConversation];
    return data;
}

- (WBChatListModel *)createChatListModelFromResultSet:(FMResultSet *)resultSet client:(AVIMClient *)client {
    WBChatListModel *listModel = [WBChatListModel new];


    NSData *data = [resultSet dataForColumn:WBChatListDaoKeyData];
    AVIMKeyedConversation *keyedConversation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    AVIMConversation *conversation = [client conversationWithKeyedConversation:keyedConversation];
    listModel.conversation = conversation;
    
    listModel.conversationID = [resultSet stringForColumn:WBChatListDaoKeyId];
    listModel.unreadCount = [resultSet intForColumn:WBChatListDaoKeyUnreadCount];
    listModel.lastMessageAt = [resultSet longLongIntForColumn:WBChatListDaoKeyLastMessageAt];
    listModel.mentioned = [resultSet boolForColumn:WBChatListDaoKeyMentioned];
    listModel.extend = [resultSet stringForColumn:WBChatListDaoKeyExtend];
    
    
    listModel.draft = [resultSet stringForColumn:WBChatInfoDaoKeyDraft];
    listModel.topTime = [resultSet longLongIntForColumn:WBChatInfoDaoKeyTopTime];
    listModel.isTop = listModel.topTime > 0;

    return listModel;
}


- (BOOL)updateDB:(FMDatabase *)db listModel:(WBChatListModel *)chatListModel{
    BOOL result = NO;
    // 1.把基本信息,插入list表中
    NSString *sql = @"INSERT OR REPLACE INTO " WBChatListDaoTableName @" ("
    WBChatListDaoKeyId             @", "
    WBChatListDaoKeyData           @", "
    WBChatListDaoKeyUnreadCount    @", "
    WBChatListDaoKeyLastMessageAt  @", "
    WBChatListDaoKeyMentioned      @", "
    WBChatListDaoKeyExtend
    @") VALUES(?, ?, ?, ?, ?, ?);";
    
    NSData *data = [self dataFromConversation:chatListModel.conversation];
    result = [db executeUpdate:sql withArgumentsInArray:
              @[chatListModel.conversationID,
                data,
                @(chatListModel.unreadCount),
                @(chatListModel.lastMessageAt),
                @(chatListModel.mentioned),
                chatListModel.extend.length ? chatListModel.extend : @""
                ]
              ];
    
    
    // 2.查询info表,对应消息是否有置顶
    NSString *sqlAll = [NSString stringWithFormat:@"select topTime from t_ChatInfo where conversationID = ?;"];
    FMResultSet *set = [db executeQuery:sqlAll withArgumentsInArray:@[chatListModel.conversationID]];
    NSTimeInterval topTime = 0;
    if ([set next]) {
        topTime = [set longLongIntForColumn:WBChatInfoDaoKeyTopTime];
    }
    [set close];
    
    // 3.如果这个会话是`置顶`, 那么更新置顶时间
    if (topTime > 0) {
        topTime = [NSDate wb_currentTimeStamp].integerValue;
        sql = [NSString stringWithFormat:@"Update t_ChatInfo Set topTime = ? where conversationID = ?;"] ;
        result = [db executeUpdate:sql withArgumentsInArray:@[@(topTime),chatListModel.conversationID]];
    }
    return result;
}

@end

