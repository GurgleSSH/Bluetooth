//
//  LSBluetoothMicro.h
//  LSBluetooth
//
//  Created by liushuai on 16/5/14.
//  Copyright © 2016年 liushuai1992@gmail.com. All rights reserved.
//

#ifndef LSBluetoothMicro_h
#define LSBluetoothMicro_h

//字符串不为空
#define STRING_IS_NOT_NULL(str) !([str isEqual:[NSNull null]] || str == nil || [str isEqualToString:@""])

//delegate 验证
#define DELEGATE_RESPONDS(method) if (self.delegate && [self.delegate respondsToSelector:@selector(method)]) {[self.delegate method];}

//delegate 验证（含参）
#define DELEGATE_RESPONDS_WITH(method, param) if (self.delegate && [self.delegate respondsToSelector:@selector(method)]) {[self.delegate method param];}

//对象是否能够响应方法
#define RESPONDS_TO(who, method) if ([who respondsToSelector:@selector(method)])

//对象是否能够响应方法（含参）
#define RESPONDS_TO_WITH(who, method, param) if ([who respondsToSelector:@selector(method param)])



#endif /* LSBluetoothMicro_h */
