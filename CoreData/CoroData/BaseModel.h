//
//  BaseModel.h
//  CoroData
//
//  Created by ZXW on 17/1/14.
//  Copyright © 2017年 xuewei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

+ (instancetype)modelWithDict:(NSDictionary *)dict;

- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 *  将数组 转成模型数组
 */
+ (NSArray *)modelsWithArray:(NSArray *)array;

/**
 *  将字典的key 转成模型的属性名的映射关系，默认属性名与key相同；
 *  如需改变映射关系，只需复写此方法将需要修改的映射关系返回
 */
-(NSDictionary *) propertyMapDic;

/**
 *  将字典的value值 赋给相应的属性；
 */
- (void)setValueWithDict:(NSDictionary *)dict;

/**
 *  将模型对象转成字典，模型属性目前必须是
 */
- (NSDictionary *)modelToDict;

@end
