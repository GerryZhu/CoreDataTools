//
//  CoreDataTools.m
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import "CoreDataTools.h"
#import "BaseModel.h"
#import <objc/runtime.h>

#define SQLitePath  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CoreData"]

static CoreDataTools *instance;
static dispatch_once_t onceToken;
@interface CoreDataTools ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end


@implementation NSManagedObject (properties)

- (NSArray *)getPropertyList
{
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:5];
    [self.entity.properties enumerateObjectsUsingBlock:^(NSPropertyDescription *propertyDescription, NSUInteger idx, BOOL * _Nonnull stop) {
        [properties addObject:propertyDescription.name];
    }];
    return properties;
}

@end

@implementation CoreDataTools

+ (void)deleteCoreData
{
    [[CoreDataTools shareTools].context performBlockAndWait:^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        onceToken = 0;
        [fileManager removeItemAtPath:SQLitePath error:nil];
    }];
    
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:zone] init];
        [instance setupContext];
    });
    return instance;
}

+ (instancetype)shareTools
{
    return [[CoreDataTools alloc] init];
}

- (void)setupContext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error1 = nil;
    [fileManager createDirectoryAtPath:SQLitePath withIntermediateDirectories:YES attributes:nil error:&error1];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;   
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[SQLitePath stringByAppendingString:@"/coreData.sqlite"]] options:options error:&error];
    context.persistentStoreCoordinator = store;
    self.context = context;
}

#pragma mark - 插入数据

- (void)insertWithEntityName:(NSString *)entityName data:(id)data
{
        NSArray *dataArr = @[data];
        if ([data isKindOfClass:[NSArray class]]) dataArr = data;
        [self insertWithEntityName:entityName dataArray:dataArr];
}

- (void)insertWithEntityName:(NSString *)entityName dataArray:(NSArray *)dataArray
{
    [self.context performBlockAndWait:^{
        [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self insertAnEntity:entityName data:obj];
            if (idx%200 == 199 || idx == dataArray.count-1) { 
                NSError *error = nil;
                [self.context save:&error];
                if (error != nil) {
                    [self.context undo];
                    NSLog(@"数据保存失败 error: %@", error);
                    return ;
                }
            }
        }];
        NSLog(@"数据保存成功");
    }];
}

- (NSManagedObject *)insertAnEntity:(NSString *)entityName data:(id)data
{   
    if ([data isKindOfClass:[NSDictionary class]]) data = [NSClassFromString(entityName) modelWithDict:data];
    NSManagedObject *managedModel = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    NSArray *propertyList = [managedModel getPropertyList];
    [propertyList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL getKey = NSSelectorFromString(key);
        NSObject *value = nil;
        if ([data respondsToSelector:getKey]) {
#pragma clang diagnostic push  
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"  
            value = [data performSelector:getKey];
#pragma clang diagnostic pop 
            if ([value isKindOfClass:[BaseModel class]]) {
                value = [self insertAnEntity:NSStringFromClass([value class]) data:value];
            }
        }
        if (value != nil && ![value isKindOfClass:[NSNull class]]) {
            [managedModel setValue:value forKey:key];
        }
    }];
    return managedModel;
}

#pragma mark - 删除数据
- (void)deleteWithEntityName:(NSString *)entityName
{
    [self deleteWithEntityName:entityName predicate:nil];
}

- (void)deleteWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate
{
    [self.context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.predicate = predicate;
        NSError *error = nil;
        NSArray *models = [self.context executeFetchRequest:request error:&error];
        if (error != nil) {
            NSLog(@"删除错误 error: %@",error);
            return ;
        }
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.context deleteObject:obj];
        }];
        [self.context save:&error];
        if (error != nil) {
            [self.context undo];
            NSLog(@"删除错误 error: %@",error);
        }
        NSLog(@"删除成功!");
    }];
}

#pragma mark - 更新数据
- (void)updateWithEntityName:(NSString *)entityName newDataArray:(NSArray *)newDataArray
{
    [self deleteWithEntityName:entityName];
    [self insertWithEntityName:entityName dataArray:newDataArray];
}

- (void)updateWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate newData:(NSArray *)newDataArr
{
    [self deleteWithEntityName:entityName predicate:predicate];
    [self insertWithEntityName:entityName dataArray:newDataArr];;
}

#pragma mark - 查找数据

- (id )seachWithObjectID:(NSManagedObjectID *)objectID isManagerObject:(BOOL)isManagerObject
{
    if (![objectID isKindOfClass:[NSManagedObjectID class]]) return nil;
    NSManagedObject *manageObject = [self.context objectWithID:objectID];
    if (isManagerObject) return manageObject;
    return [self managerObjectToObject:manageObject];
}

- (void)seachWithEntityName:(NSString *)entityName result:(SearchResult)resultArray
{
    [self seachWithEntityName:entityName predicate:nil fetchLimit:0 fetchOffset:0 sortDescriptorWithKey:nil ascending:YES result:^(NSArray *array) {
        resultArray(array);
    }];
}

- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate result:(SearchResult)resultArray
{
    [self seachWithEntityName:entityName predicate:predicate fetchLimit:0 fetchOffset:0 sortDescriptorWithKey:nil ascending:YES result:^(NSArray *array) {
        resultArray(array);
    }];
}

- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending result:(SearchResult)resultArray
{
    [self seachWithEntityName:entityName predicate:predicate fetchLimit:0 fetchOffset:0 sortDescriptorWithKey:key ascending:ascending result:^(NSArray *array) {
        resultArray(array);
    }];
}

- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate fetchLimit:(NSInteger)fetchLimit fetchOffset:(NSInteger)fetchOffset result:(SearchResult)resultArray
{
    [self seachWithEntityName:entityName predicate:predicate fetchLimit:fetchLimit fetchOffset:fetchOffset sortDescriptorWithKey:nil ascending:YES result:^(NSArray *array) {
        resultArray(array);
    }];
}

- (void)seachWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate fetchLimit:(NSInteger)fetchLimit fetchOffset:(NSInteger)fetchOffset sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending result:(SearchResult)resultArray
{
    [self.context performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        if (predicate != nil) request.predicate = predicate;
        if (key) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
            request.sortDescriptors = @[sort];
        }
        if (fetchLimit > 0) request.fetchLimit = fetchLimit;
        if (fetchOffset > 0) request.fetchOffset = fetchOffset;
        
        NSError *error = nil;
        NSArray *models = [self.context executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"查找失败");
            return ;
        }
        NSLog(@"查找成功");
        [self managerObjectToObject:models result:^(NSArray *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultArray(array);
            });
        }];
    }];
}

//根据成员变量名获取 成员变量的 set方法
- (SEL)getSelFromAttributeString:(NSString *)attributeString
{
    NSString *firstCharacter = [attributeString substringToIndex:1];
    firstCharacter = [firstCharacter uppercaseString];
    NSString *lastCharacters = [attributeString substringFromIndex:1];
    NSString *selString = [NSString stringWithFormat:@"set%@%@:",firstCharacter,lastCharacters];
    
    SEL sel = NSSelectorFromString(selString);
    return sel;
}

- (void)managerObjectToObject:(NSArray *)managerObjectArr result:(SearchResult)resultArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *objectArr = [NSMutableArray arrayWithCapacity:5];
        [managerObjectArr enumerateObjectsUsingBlock:^(NSManagedObject *managerObject, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *object = [self managerObjectToObject:managerObject];
            [objectArr addObject:object];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            resultArray(objectArr);
        });
    });
}

- (NSObject *)managerObjectToObject:(NSManagedObject *)managerObject
{
    NSString *name = managerObject.entity.name;
    NSObject *object = [[NSClassFromString(name) alloc] init];
    NSArray *array = [managerObject getPropertyList];
    for (NSString *key in array) {
        SEL setKey = [self getSelFromAttributeString:key];
        if ([object respondsToSelector:setKey]) {
            id value = [managerObject valueForKey:key];
            if ([value isKindOfClass:[NSManagedObject class]]) value = [self managerObjectToObject:value];
#pragma clang diagnostic push  
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"  
            [object performSelector:setKey withObject:value];
#pragma clang diagnostic pop 
        }
    }
    return object;
}

@end


