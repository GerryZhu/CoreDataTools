# CoreDataTools
对CoreData的一个简单封装，使用CoreData对普通的数据模型直接存储，工具内部完成NSObject与NSManagerObject的互转；一行代码完成数据的CoreData增删改查

注意：
1、使用时只需将数据模型继承自BaseModel即可实现多表关联查询，如不想使用BaseModel可修改源码
2、为了对网络数据统一处理，BaseModel会将NSNumber类型的数据统一处理成NSString,如不需要可修改源码
3、BaseModel 暂不支持基本类型的属性与对象的互转，字典 key对应的 @property 属性需定义为对象
4、字典转模型时，如果要修改 字典 key对应的 @property 属性映射关系时，可以在模型类中实现 -(NSDictionary *) propertyMapDic 方法，将特殊的映射关系以字典形式返回
5、如需对数据进行特殊处理可在模型类中实现 - (void)setValueWithDict:(NSDictionary *)dict 方法，调用父类 [super setValueWithDict:dict] 后，对数据处理后，对属性重新赋值；也可以新添加属性，赋值给新添加属性；


如在使用中有任何问题，欢迎交流！  QQ:  1141189194
