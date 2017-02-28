//
//  ViewController.m
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataTools.h"
#import "FriendModel.h"
#import "MessageModel.h"

@interface ViewController ()
{
    NSInteger _fetchOffset;//从第几条开始读取数据
}

@property (weak, nonatomic) IBOutlet UITextField *imageUrl;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITextField *messageId;
@property (weak, nonatomic) IBOutlet UITextField *icon;

@end

@implementation ViewController

/*
 // 查询条件
 // 1.查询以wang开头员工
 //NSPredicate *pre = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@",@"wang"];
 
 // 2.以si 结尾
 //NSPredicate *pre = [NSPredicate predicateWithFormat:@"name ENDSWITH %@",@"si"];
 
 // 3.名字包含 g
 //NSPredicate *pre = [NSPredicate predicateWithFormat:@"name CONTAINS %@",@"g"];
 
 // 4.like 以si结尾
 //NSPredicate *pre = [NSPredicate predicateWithFormat:@"name like %@",@"li*"];
 
 // 5.多条件
 //NSPredicate *pre = [NSPredicate predicateWithFormat:@"name=%@ AND height > %@",@"zhangsan",@(1.8)];
 */



//增
- (IBAction)insertMessage:(id)sender
{
    NSDictionary *dic = @{
                          @"message":_message.text,
                          @"messageId":_messageId.text,
                          @"imageUrl":_imageUrl.text,
                          @"friendInfo":@{@"name":@"张三",@"nickName":@"nickName",@"iconUrl":@"https://12.10.1:8080/IconImage/1.png",@"userId":@"72u7937r6"}
                          };
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 1000; i ++) {
        [marr addObject:dic];
    }
    [[CoreDataTools shareTools] insertWithEntityName:@"MessageModel" dataArray:marr];
}

//删
- (IBAction)deleteMessage:(id)sender
{
    [[CoreDataTools shareTools] deleteWithEntityName:@"MessageModel"];
}

//改
- (IBAction)updateMessage:(id)sender
{
    NSDictionary *dic = @{
                          @"message":_message.text,
                          @"messageId":_messageId.text,
                          @"imageUrl":_imageUrl.text,
                          @"friendInfo":@{@"name":@"张三",@"nickName":@"nickName",@"iconUrl":@"https://12.10.1:8080/IconImage/1.png",@"userId":@"72u7937r6"}
                          };
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId=%@",_messageId.text];
    [[CoreDataTools shareTools] updateWithEntityName:@"MessageModel" predicate:predicate newData:@[dic]];
}

//查
- (IBAction)seachMessage:(id)sender
{
//    //关联表查询
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendInfo.name = %@",@"张三"];
    
    //查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageId = %@",self.messageId.text];
    [[CoreDataTools shareTools] seachWithEntityName:@"MessageModel" predicate:predicate fetchLimit:10 fetchOffset:_fetchOffset result:^(NSArray *array) {
//        NSLog(@"查询到的数据 array = %@",array);
        NSLog(@"%ld",array.count);
        
            //改变读取数据的位置
            _fetchOffset += array.count;
        
            if (array.count < 10) {
                NSLog(@"没有更多数据");
            }
    }];
    
}
- (IBAction)deleteCoreData:(UIButton *)sender
{
    [CoreDataTools deleteCoreData];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
