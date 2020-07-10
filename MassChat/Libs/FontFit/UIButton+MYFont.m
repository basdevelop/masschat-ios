//
//  UIButton+MYFont.h
//  JCC
//
//  Created by 聚财村 on 15/10/21.
//  Copyright © 2016年 jucaicun. All rights reserved.
//

#import "UIButton+MYFont.h"

//#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
//#define SizeScale ((IPHONE_HEIGHT > 568) ? IPHONE_HEIGHT/550 : 1)

@implementation UIButton (MYFont)

@end

@implementation UIButton(myFont)

+ (void)load{
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
}

- (id)myInitWithCoder:(NSCoder *)aDecode{

    [self myInitWithCoder:aDecode];
    if (self) {
        // 部分不想改变字体的 把tag值设置成555跳过
        if (self.titleLabel.tag != 555) {
            CGFloat fontSize = self.titleLabel.font.pointSize;
                self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:fontSize * SizeScale];
//            self.titleLabel.font = [UIFont systemFontOfSize:fontSize * SizeScale];
        }
    }
    return self;
}

@end

@implementation UILabel(myFont)

+ (void)load{
    Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
    method_exchangeImplementations(imp, myImp);
}

- (id)myInitWithCoder:(NSCoder *)aDecode{
    
    [self myInitWithCoder:aDecode];
    if (self) {
        // 部分不想改变字体的 把tag值设置成555跳过
        if (self.tag != 555) {
            CGFloat fontSize = self.font.pointSize;
            self.font = [UIFont fontWithName:self.font.fontName size:fontSize * SizeScale];
//            self.font = [UIFont systemFontOfSize:fontSize * SizeScale];
        }
    }
    return self;
}

@end



@implementation UITextField(myFont)

+ (void)load{
        Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
        Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
        method_exchangeImplementations(imp, myImp);
}

- (id)myInitWithCoder:(NSCoder *)aDecode{
        
        [self myInitWithCoder:aDecode];
        if (self) {
                // 部分不想改变字体的 把tag值设置成555跳过
                if (self.tag != 555) {
                        CGFloat fontSize = self.font.pointSize;
                        self.font = [UIFont fontWithName:self.font.fontName size:fontSize * SizeScale];
//                        self.font = [UIFont systemFontOfSize:fontSize * SizeScale];
                }
        }
        return self;
}

@end


@implementation UITextView(myFont)

+ (void)load{
        Method imp = class_getInstanceMethod([self class], @selector(initWithCoder:));
        Method myImp = class_getInstanceMethod([self class], @selector(myInitWithCoder:));
        method_exchangeImplementations(imp, myImp);
}

- (id)myInitWithCoder:(NSCoder *)aDecode{
        
        [self myInitWithCoder:aDecode];
        if (self) {
                // 部分不想改变字体的 把tag值设置成555跳过
                if (self.tag != 555) {
                        CGFloat fontSize = self.font.pointSize;
                        self.font = [UIFont fontWithName:self.font.fontName size:fontSize * SizeScale];
//                        self.font = [UIFont systemFontOfSize:fontSize * SizeScale];
                }
        }
        return self;
}

@end




