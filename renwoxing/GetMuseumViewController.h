//
//  GetMuseumViewController.h
//  renwoxing
//
//  Created by YangBing on 16/3/29.
//  Copyright © 2016年 paixiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MuseumModel.h"
#import "DetaileViewController.h"
@interface GetMuseumViewController : UIViewController
{
    
    NSMutableData *webData;
    NSMutableString *soapResults;
    BOOL recordResults;
}
@property (nonatomic,strong)NSMutableArray * data;
@property (nonatomic,strong)UITableView * mytableView;

@end
