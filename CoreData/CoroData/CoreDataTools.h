//
//  CoreDataTools.h
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^SearchResult)(NSArray *array);

@interface CoreDataTools : NSObject

/**
 *  单例初始化方法
 */
+ (instancetype)shareTools;

/**
 *  删除CoreData数据库
 */
+ (void)deleteCoreData;

#pragma mark - 插入数据
/**
 *  添加一条数据
 *
 *  @param entityName 数据类型
 *  @param data 要添加的数据 (字典或者模型)
 */
- (void)insertWithEntityName:(NSString *)entityName data:(id)data;

/**
 *  添加一组数据
 *
 *  @param entityName 数据类型
 *  @param dataArray  要添加的数据数组 (字典数组或者模型数组)
 */
- (void)insertWithEntityName:(NSString *)entityName dataArray:(NSArray *)dataArray;

#pragma mark - 删除数据
/**
 *  删除某一个表的数据
 *
 *  @param entityName 数据类型
 */
- (void)deleteWithEntityName:(NSString *)entityName;

/**
 *  删除符合某一条件的数据
 *
 *  @param entityName 数据类型
 *  @param predicate  查询条件
 */
- (void)deleteWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate;

#pragma mark - 更新数据
/**
 *  替换某种类型的所有数据
 *
 *  @param entityName   数据类型
 *  @param newDataArray 新数据数组
 *
 *  @return 是否更新成功
 */
- (void)updateWithEntityName:(NSString *)entityName newDataArray:(NSArray *)newDataArray;

/**
 *  更新符合某一条件的数据
 *
 *  @param entityName 数据类型
 *  @param predicate  查询条件
 *  @param newDataArr 新数据
 */
- (void)updateWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate newData:(NSArray *)newDataArr;

#pragma mark - 查找数据


/**
 根据objectID查询数据

 @param objectID ManagerObject的唯一标识
 @param isManagerObject 是否返回NSManagerObject类型，YES返回NSManagerObject类型，NO时返回NSObject类型
 @return 查询结果
 */
- (id)seachWithObjectID:(NSManagedObjectID *)objectID isManagerObject:(BOOL)isManagerObject;

/**
 *  查询某种类型的所有数据
 *
 *  @param entityName 数据类型
 *
 *  @param resultArray 查询到的结果回调
 */
- (void)seachWithEntityName:(NSString *)entityName result:(SearchResult)resultArray;

/**
 *  查询符合某一条件的数据
 *
 *  @param entityName  数据类型
 *  @param predicate   查询条件
 
 *  @param resultArray 查询到的结果回调
 */
- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate result:(SearchResult)resultArray;

/**
 *  查询符合某一条件的数据
 *
 *  @param entityName  数据类型
 *  @param predicate   查询条件
 *  @param key         根据 key 排序
 *  @param ascending   排序方式: YES为升序,NO为降序
 *
 *  @param resultArray 查询到的结果回调
 */
- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending result:(SearchResult)resultArray;

/**
 *  查询符合某一条件的数据
 *
 *  @param entityName  数据类型
 *  @param predicate   查询条件
 *  @param fetchLimit  分页显示,每页数据条数
 *  @param fetchOffset 从查询到的数据中的第 fetchOffset 条数据开始取 fetchLimit 条
 *
 *  @param resultArray 查询到的结果回调
 */
- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate fetchLimit:(NSInteger)fetchLimit fetchOffset:(NSInteger)fetchOffset result:(SearchResult)resultArray;


/**
 *  查询符合某一条件的数据
 *
 *  @param entityName  数据类型
 *  @param predicate   查询条件
 *  @param fetchLimit  分页显示,每页数据条数
 *  @param fetchOffset 从查询到的数据中的第 fetchOffset 条数据开始取 fetchLimit 条
 *  @param key         根据 key 排序
 *  @param ascending   排序方式: YES为升序,NO为降序
 *
 *  @param resultArray 查询到的结果回调
 */
- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate fetchLimit:(NSInteger)fetchLimit fetchOffset:(NSInteger)fetchOffset sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending result:(SearchResult)resultArray;


@end



