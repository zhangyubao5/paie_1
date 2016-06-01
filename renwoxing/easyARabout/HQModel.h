//
//  HQModel.h
//  DownloadZip1
//
//  Created by YangBing on 16/5/23.
//  Copyright © 2016年 paixiao. All rights reserved.
//

#import "JSONModel.h"

@interface HQModel : JSONModel
@property (nonatomic,strong)NSString * scene_id;
@property (nonatomic,strong)NSString * name;
@property (nonatomic,strong)NSString * image1;
@property (nonatomic,strong)NSString * image2;
@property (nonatomic,assign)NSString * lng;
@property (nonatomic,assign)NSString * lat;
@property (nonatomic,strong)NSString * optype;
@property (nonatomic,strong)NSString * descript;
@end
