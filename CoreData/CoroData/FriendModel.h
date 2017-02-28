//
//  FriendModel.h
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import "BaseModel.h"

@interface FriendModel : BaseModel

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *message;
@property (nonatomic, copy)NSString *messageId;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, strong)NSDictionary *dict;


@end
