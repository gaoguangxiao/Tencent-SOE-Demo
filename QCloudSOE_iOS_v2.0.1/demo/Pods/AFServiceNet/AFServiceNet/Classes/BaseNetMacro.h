//
//  BaseNetMacro.h
//  Demo_xxx
//
//  Created by 高广校 on 2023/4/13.
//

#ifndef BaseNetMacro_h
#define BaseNetMacro_h

#define HOSTDOMAIN @"gateway-test.risekid.cn"
#define HOSLOGOMAIN [NSString stringWithFormat:@"http://%@/",HOSTDOMAIN]
#define WEBSEARVICE [NSString stringWithFormat:@"http://%@/",HOSTDOMAIN]

//设置Webservice变量结构
#define API_CODE @"code"
#define API_DATA @"data"
#define API_DATALIST @"list"
#define API_DATAPAGES @"pages"
#define API_DATATOTAL @"total"
#define API_SUCCESS @"success"
#define API_MSG @"msg"

#endif /* BaseNetMacro_h */
