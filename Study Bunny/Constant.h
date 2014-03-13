//
//  Constant.h
//  Study Bunny
//
//  Created by Gregoire on 2/1/14.
//  Copyright (c) 2014 jhurrayApps. All rights reserved.
//

#ifndef Study_Bunny_Constant_h
#define Study_Bunny_Constant_h

// UMICH API
#define KEY @"y9FajljRGd7FGreCniY7oAU9T44a"
#define SECRET @"H6vAEO18J60ZINLKVC2_ZNPaDI8a"
#define KEYSECRET64 @"eTlGYWpsalJHZDdGR3JlQ25pWTdvQVU5VDQ0YTpINnZBRU8xOEo2MFpJTkxLVkMyX1pOUGFESThh"
#define WN14 @"1970"

//PARSE

#define PARSE_YES = [NSNumber numberWithBool:YES]
#define PARSE_NO = [NSNumber numberWithBool:NO]

//MAP
#define METERS_PER_MILE 1609.344

// FEATURE HEIGHT CONSTANTS
#define KEYBOARDHEIGHT 216
#define STATUSBARHEIGHT 20
#define NAVBARHEIGHT 44
#define DEVICEHEIGHT [[UIScreen mainScreen] bounds].size.height
#define DEVICEWIDTH [[UIScreen mainScreen] bounds].size.width
#define BARBUTTONFRAME CGRectMake(0, 0, 30, 30)
#define CELLHEIGHT 60

#define MATCHCELLHEIGHT 100

// COLORS / FONTS

#define MAINCOLOR [UIColor whiteColor]
#define SECONDARYCOLOR [UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:0.8]
#define TERTIARYCOLOR [UIColor colorWithRed:107.0/255.0 green:185.0/255.0 blue:240.0/255.0 alpha:0.7]
#define FONT @"AppleSDGothicNeo-Light"

#endif
