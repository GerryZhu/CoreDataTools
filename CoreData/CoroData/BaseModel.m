//
//  BaseModel.m
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

+ (NSArray *)modelsWithArray:(NSArray *)array
{
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in array) {
        [models addObject:[self modelWithDict:dic]];
    }
    return models;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValueWithDict:dict];
    }
    return self;
}

// 根据字典给模型属性赋值
// 子类 重写时 应先调父类    [super setValueWithDict: dict];
// 然后  再对属性值 进行自定义操作
- (void)setValueWithDict:(NSDictionary *)dict
{
    NSDictionary *dic = [self jsonKeyToPropertyNameDict:dict]; //  key ：value (字典数据的key ： 属性名)
    NSDictionary *propertyDict = [self propertyListDict];    //  key ：value (属性名 ： 属性类型)
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *jsonKey, NSString *propertyName, BOOL * _Nonnull stop) {
        id value = [dict objectForKey:jsonKey];
        if ([value isKindOfClass:[NSNull class]]) value = nil;   // null 处理
        if ([value isKindOfClass:[NSNumber class]]) {   //为了简化， Number 类型处理成String；（ 可以不作处理）
            value = [NSString stringWithFormat:@"%@",value];
        }
        NSString *propertyType = [propertyDict objectForKey:propertyName];
        if ([NSClassFromString(propertyType) isSubclassOfClass:[BaseModel class]]) {  // 模型 中的 模型转换 
            BaseModel *model = [NSClassFromString(propertyType) modelWithDict:value];
            value = model;
        }
        SEL sel = [self setSelFromString:propertyName];     //  根据属性名生成  属性的set 方法
#pragma clang diagnostic push  
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"  
        if ([self respondsToSelector:sel])  [self performSelector:sel withObject:value];  // 如果属性的set方法实现了，调用属性的  set 方法 给属性赋值
#pragma clang diagnostic pop 
    }];
}

//  根据属性名生成  属性的set 方法
- (SEL)setSelFromString:(NSString *)string
{
    NSString *firstCharacter = [string substringToIndex:1];
    firstCharacter = [firstCharacter uppercaseString];
    NSString *lastCharacters = [string substringFromIndex:1];
    NSString *selString = [NSString stringWithFormat:@"set%@%@:",firstCharacter,lastCharacters];
    SEL sel = NSSelectorFromString(selString);
    return sel;
}

// 生成  jsonKey：property  的字典，子类中重写此方法，可以修改  jsonKey与property的对应关系
// 子类重写时， 先调父类   NSMutableDictionary * mDict = [super jsonKeyToPropertyNameDict: dict];
//    然后再修改  jsonKey与property的对应关系
- (NSMutableDictionary *)jsonKeyToPropertyNameDict:(NSDictionary *)dict
{
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mDict setObject:key forKey:key];
    }];
    NSDictionary *mapDic = [self propertyMapDic];
    if (![mapDic isKindOfClass:[NSDictionary class]] || !mapDic.count) return mDict;
    [mapDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mDict setObject:obj forKey:key];
    }] ;
    return mDict;
}
-(NSDictionary *) propertyMapDic
{
    return @{};
}

//获取某个类的成员变量名及对应的数据类型
- (NSDictionary *)propertyListDict
{
    unsigned int numIvars; //成员变量个数
    Ivar *vars = class_copyIvarList(self.class, &numIvars);
    NSMutableDictionary *propertyDict = [NSMutableDictionary dictionaryWithCapacity:5];
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];  //成员变量的名字
        key = [key substringFromIndex:1];
        NSString *keyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)]; //成员变量的数据类型
        if ([keyType containsString:@"@\""]) {
            keyType = [keyType substringWithRange:NSMakeRange(2, keyType.length-3)];
        }
        [propertyDict setObject:keyType forKey:key];
    }
    free(vars);
    return propertyDict;
}

//  模型转字典
- (NSDictionary *)modelToDict
{
    NSArray *propertyArr = [[self propertyListDict] allKeys];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:5];
    [propertyArr enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = nil;
        SEL sel = NSSelectorFromString(key);
#pragma clang diagnostic push  
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"  
        if ([self respondsToSelector:sel]) [self performSelector:sel];
#pragma clang diagnostic pop 
        if ([value isKindOfClass:[BaseModel class]]) value = [self modelToDict];
        if (value) [dic setObject:value forKey:key];
    }];
    return dic;
}

@end
