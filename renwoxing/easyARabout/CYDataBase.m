

#import "CYDataBase.h"
#import "FMDatabase.h"

@implementation CYDataBase
{
    FMDatabase *_fmDataBase;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *path =   NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        path = [path stringByAppendingPathComponent:@"BusinessInformation.db"];
        
        NSLog(@"%@",path);
        
        _fmDataBase = [FMDatabase databaseWithPath:path];
        
        [_fmDataBase open];
        //[_fmDataBase executeUpdate:[NSString stringWithFormat: @"create table provincecity (valuekey text PRIMARY KEY, scene_id,name text, image1 text,image2 text,lng text,lat text,optype text,CONSTRAINT province FOREIGN KEY(province) REFERENCES province(valuekey) ON DELETE CASCADE ON UPDATE CASCADE)"]];
        [_fmDataBase executeUpdate:@"create table if not exists BusinessInformation1 (id integer primary key autoincrement,scene_id,name text, image1 text,image2 text,lng text,lat text,optype text,descript text)"];
        
        [_fmDataBase close];
    }
    
    return self;
}

-(void)insertData:(HQModel *)Information
{
    [_fmDataBase open];
    
    
    [_fmDataBase executeUpdate:@"insert into BusinessInformation1 (scene_id,name,image1,image2,lng,lat,optype,descript) values (?,?,?,?,?,?,?,?)",Information.scene_id,Information.name,Information.image1,Information.image2,Information.lng,Information.lat,Information.optype,Information.descript];
    
    [_fmDataBase close];
}

-(BOOL)dataExists
{
    BOOL ret = NO;
    [_fmDataBase open];
    
    FMResultSet *result = [_fmDataBase executeQuery:@"select * from BusinessInformation1"];
    
    ret = [result next];
    
    [_fmDataBase close];
    
    return ret;
}

-(void)deleteAllDatas
{
    [_fmDataBase open];
    
    [_fmDataBase executeUpdate:@"delete from BusinessInformation1"];
    
    [_fmDataBase close];
}

-(NSMutableArray *)getAllInformation
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [_fmDataBase open];
    
    FMResultSet *result = [_fmDataBase executeQuery:@"select * from BusinessInformation1"];
    while ([result next]) {
        HQModel *Information = [[HQModel alloc] init];
        Information.scene_id = [result stringForColumn:@"scene_id"];
        Information.name = [result stringForColumn:@"name"];
        Information.image1 =[result stringForColumn:@"image1"];
        Information.image2 =[result stringForColumn:@"image2"];
        Information.lng = [result stringForColumn:@"lng"];
         Information.lat = [result stringForColumn:@"lat"];
        Information.optype = [result stringForColumn:@"optype"];
        Information.descript = [result stringForColumn:@"descript"];

        [arr addObject:Information];
    }
    [_fmDataBase close];
    return arr;
}
-(HQModel *)SearchModelFromName:(NSString *)scene_id
{
    
    HQModel * model = [[HQModel alloc]init];
    [_fmDataBase open];
    
    FMResultSet *result = [_fmDataBase executeQuery:@"select * from BusinessInformation1 where scene_id = ?",scene_id];
    while ([result next]) {
        model.scene_id = [result stringForColumn:@"scene_id"];
        model.name = [result stringForColumn:@"name"];
        model.image1 =[result stringForColumn:@"image1"];
        model.image2 =[result stringForColumn:@"image2"];
        model.lng = [result stringForColumn:@"lng"];
        model.lat = [result stringForColumn:@"lat"];
        model.optype = [result stringForColumn:@"optype"];
        model.descript = [result stringForColumn:@"descript"];
    }
    [_fmDataBase close];
    
    
    return model;
}

+(CYDataBase *)sharedDataBase
{
    static CYDataBase *dataBase = nil;
    if(dataBase == nil)
    {
        dataBase = [[CYDataBase alloc] init];
    }
    return dataBase;
}

@end
