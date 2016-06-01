
#import <Foundation/Foundation.h>
#import "HQModel.h"

@interface CYDataBase : NSObject

+(CYDataBase *)sharedDataBase;

//
-(void)insertData:(HQModel *)Information;

//判断数据中是否已有数据
-(BOOL)dataExists;

//
-(void)deleteAllDatas;

-(NSMutableArray *)getAllInformation;

-(HQModel *)SearchModelFromName:(NSString *)scene_id;
@end
