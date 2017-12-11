//
//  WBConst.h
//  Whiteboard
//
//  Created by RedRain on 2017/11/5.
//  Copyright © 2017年 RedRain. All rights reserved.
//

#ifndef WBConst_h
#define WBConst_h


#define kBoardHoldImage [UIImage imageNamed:@"star_bg"]
#define kUserHeaderHoldImage [UIImage imageNamed:@"header_male"]WB
#define kWBScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kWBScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kWBNavigationBarHeight (64)
#define kWBSearchBarHeightHeight (55)
#define WBNotificationCenter [NSNotificationCenter defaultCenter]
#define WBRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]



//如果有Debug这个宏的话,就允许log输出...可变参数
#ifdef DEBUG
#define WBLog(...) LxPrintf(__VA_ARGS__)
#else
#define WBLog(...)
#endif

// 重写对象的debugDescription方法, 方便于控制台打印
#define kWBOverwriteDebugDescription \
- (NSString *)debugDescription { \
NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];\
uint count;\
objc_property_t *properties = class_copyPropertyList([self class], &count);\
for(int i = 0; i<count; i++) {\
objc_property_t property = properties[i];\
NSString *name = @(property_getName(property));\
id value = [self valueForKey:name]?:@"nil";\
[dictionary setObject:value forKey:name];\
}\
free(properties);\
return [NSString stringWithFormat:@"<%@: %p> -- %@",[self class],self,dictionary];\
}

#define kWBAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

#define kWBOverwriteCopyWithZone \
- (id)copyWithZone:(NSZone *)zone{\
id newOne = [[self class] new];\
[[OPPropertyListManager shareInstance] setupPropertyValueFromObj:self toObj:newOne];\
return newOne;\
}




/*
 
 
 // 打印属性的值
 kWBOverwriteDebugDescription
 
 // 用户支持 NSCopying 协议
 kWBOverwriteCopyWithZone
 
 */

#endif /* WBConst_h */
