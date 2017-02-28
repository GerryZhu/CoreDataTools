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
#import "StuModel.h"

@interface ViewController ()
{
    NSInteger _fetchOffset;//从第几条开始读取数据
}

@property (weak, nonatomic) IBOutlet UITextField *name;
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
                          @"name":_name.text,
                          @"message":_message.text,
                          @"messageId":_messageId.text,
                          @"icon":_icon.text,
                          @"dict":@{@"1":@"张三",@"2":@"李四",@"3":@"王五",@"4":@"赵六"}
                          };
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 1000; i ++) {
        [marr addObject:dic];
    }
    [[CoreDataTools shareTools] insertWithEntityName:@"FriendModel" dataArray:marr];
}

//删
- (IBAction)deleteMessage:(id)sender
{
    [[CoreDataTools shareTools] deleteWithEntityName:@"FriendModel"];
}

//改
- (IBAction)updateMessage:(id)sender
{
    NSDictionary *dic = @{
                          @"name":_name.text,
                          @"message":_message.text,
                          @"messageId":_messageId.text,
                          @"icon":_icon.text
                          };
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@",_name.text];
    [[CoreDataTools shareTools] updateWithEntityName:@"FriendModel" predicate:predicate newData:@[dic]];
}

//查
- (IBAction)seachMessage:(id)sender
{
    [[CoreDataTools shareTools] seachWithEntityName:@"FriendModel" predicate:nil fetchLimit:10 fetchOffset:_fetchOffset result:^(NSArray *array) {
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


@end
