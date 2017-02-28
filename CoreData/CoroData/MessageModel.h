//
//  MessageModel.h
//  CoroData
//
//  Created by elion on 17/2/28.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import "BaseModel.h"
#import "FriendModel.h"

@interface MessageModel : BaseModel

@property (nonatomic, copy)NSString *messageId;
@property (nonatomic, copy)NSString *message;
@property (nonatomic, copy)NSString *imageUrl;
@property (nonatomic, strong)FriendModel *friendInfo;

@end
