//
//  HQModel.m
//  DownloadZip1
//
//  Created by YangBing on 16/5/23.
//  Copyright © 2016年 paixiao. All rights reserved.
//

#import "HQModel.h"

@implementation HQModel

+(JSONKeyMapper *)keyMapper
{
    
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"descript":@"descript"}];
    
}
@end
