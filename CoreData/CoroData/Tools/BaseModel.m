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

- (void)setValueWithDict:(NSDictionary *)dict
{
    NSDictionary *dic = [self jsonKeyToPropertyNameDict:dict]; 
    NSDictionary *propertyDict = [self propertyListDict]; 
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *jsonKey, NSString *propertyName, BOOL * _Nonnull stop) {
        id value = [dict objectForKey:jsonKey];
        if ([value isKindOfClass:[NSNull class]]) value = nil;  
        if ([value isKindOfClass:[NSNumber class]]) {   //为了简化， 将Number 类型处理成String；（ 可以不作处理）
            value = [NSString stringWithFormat:@"%@",value];
        }
        NSString *propertyType = [propertyDict objectForKey:propertyName];
        if ([NSClassFromString(propertyType) isSubclassOfClass:[BaseModel class]]) {
            BaseModel *model = [NSClassFromString(propertyType) modelWithDict:value];
            value = model;
        }
        SEL sel = [self setSelFromString:propertyName]; 
#pragma clang diagnostic push  
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"  
        if ([self respondsToSelector:sel])  [self performSelector:sel withObject:value]; 
#pragma clang diagnostic pop 
    }];
}

- (SEL)setSelFromString:(NSString *)string
{
    NSString *firstCharacter = [string substringToIndex:1];
    firstCharacter = [firstCharacter uppercaseString];
    NSString *lastCharacters = [string substringFromIndex:1];
    NSString *selString = [NSString stringWithFormat:@"set%@%@:",firstCharacter,lastCharacters];
    SEL sel = NSSelectorFromString(selString);
    return sel;
}

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

- (NSDictionary *)propertyListDict
{
    unsigned int numIvars; 
    Ivar *vars = class_copyIvarList(self.class, &numIvars);
    NSMutableDictionary *propertyDict = [NSMutableDictionary dictionaryWithCapacity:5];
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        key = [key substringFromIndex:1];
        NSString *keyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(thisIvar)];
        if ([keyType containsString:@"@\""]) {
            keyType = [keyType substringWithRange:NSMakeRange(2, keyType.length-3)];
        }
        [propertyDict setObject:keyType forKey:key];
    }
    free(vars);
    return propertyDict;
}

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
