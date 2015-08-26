//
//  NSString+StringHelper.m
//  CommonLibrary
//
//  Created by rang on 13-1-7.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import "NSString+TPCategory.h"
#import "NSData+TPCategory.h"
#import <CommonCrypto/CommonDigest.h>
#import <RegexKitLite.h>

@implementation NSString (TPCategory)
//生成一个guid值
+ (NSString*)createGUID{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
    return nil;
}
//向前查找字符串
- (NSInteger)indexOf:(NSString*)search{
    NSRange r=[self rangeOfString:search];
    if (r.location!=NSNotFound) {
        return r.location;
    }
    return -1;
}
//向后查找字符串
- (NSInteger)lastIndexOf:(NSString*)search{
    NSRange r=[self rangeOfString:self options:NSBackwardsSearch];
    if (r.location!=NSNotFound) {
        return r.location;
    }
    return -1;
}
//去除字符串前后空格
- (NSString*)Trim{
    if (self) {
        //whitespaceAndNewlineCharacterSet 去除前后空格与回车
        //whitespaceCharacterSet 除前后空格
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return @"";
}
- (BOOL)isEmptyString
{
    if ([[self Trim] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//产生MD5字符串
- (NSString *) stringFromMD5{
    if(self == nil || [self length] == 0)
        return nil;
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
- (NSString *)SHA1Sum {
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:self.length];
	return [data SHA1Sum];
}


- (NSString *)SHA256Sum {
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:self.length];
	return [data SHA256Sum];
}

//url字符串编码处理
- (NSString*)URLEncode{
    
    NSString *encodedString = ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                   (CFStringRef)self,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8));
	
	return encodedString;
    /***
    NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                   (CFStringRef)self,
                                                                                   NULL,
                                                                                   NULL,
                                                                                   kCFStringEncodingUTF8);
    return encodedString;
     ***/
}
- (NSString *)URLEncodedParameterString {
	static CFStringRef toEscape = CFSTR(":/=,!$&'()*+;[]@#?");
    return ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																				 ( CFStringRef)self,
																				 NULL,
																				 toEscape,
																				 kCFStringEncodingUTF8));
}


- (NSString *)URLDecodedString {
	return ( NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																								 ( CFStringRef)self,
																								 CFSTR(""),
																								 kCFStringEncodingUTF8));
}

- (NSString *)URLString{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    return [[self URLDecodedString] stringByAddingPercentEscapesUsingEncoding:enc];
}

- (BOOL) isEmail{
	
    NSString *emailRegEx =
	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
	@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
	@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
	@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
	@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
	@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
	@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (BOOL) isURLString{
    NSString *emailRegEx =@"^http(s)?://([\\w-]+.)+[\\w-]+(/[\\w-./?%&=]*)?$";
	
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (BOOL) isPhone{
    NSString *phoneRegEx =@"^[0-9]{11}$";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (BOOL) isChinese{
    //[^\x80-\xff]
    NSString *chineseRegEx = @"[\u4E00-\u9FA5]*";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chineseRegEx];
    return [regExPredicate evaluateWithObject:[self lowercaseString]];
}

- (NSString *) escapeHTML{
	NSMutableString *s = [NSMutableString string];
	
	NSUInteger start = 0;
	NSUInteger len = [self length];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
				//			case '…':
				//				[s appendString:@"&hellip;"];
				//				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}

- (NSString *) unescapeHTML{
	NSMutableString *s = [NSMutableString string];
	NSMutableString *target = [self mutableCopy];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&#39;"]) {
			[s appendString:@"'"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&hellip;"]) {
			[s appendString:@"…"];
			[target deleteCharactersInRange:NSMakeRange(0, 8)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

//判断是否为整形：

- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

#pragma mark - URL Escaping and Unescaping

- (NSString *)stringByEscapingForURLQuery {
	NSString *result = self;
    
	static CFStringRef leaveAlone = CFSTR(" ");
	static CFStringRef toEscape = CFSTR("\n\r:/=,!$&'()*+;[]@#?%");
    
	CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, ( CFStringRef)self, leaveAlone,
																	 toEscape, kCFStringEncodingUTF8);
    
	if (escapedStr) {
		NSMutableString *mutable = [NSMutableString stringWithString:(__bridge  NSString *)escapedStr];
		CFRelease(escapedStr);
        
		[mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
		result = mutable;
	}
	return result;
}


- (NSString *)stringByUnescapingFromURLQuery {
	NSString *deplussed = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [deplussed stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*) stringByRemovingHTML{
	
	NSString *html = self;
    NSScanner *thescanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
	
    while ([thescanner isAtEnd] == NO) {
		[thescanner scanUpToString:@"<" intoString:NULL];
		[thescanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@" "];
    }
	return html;
}
- (BOOL) hasString:(NSString*)substring{
	return !([self rangeOfString:substring].location == NSNotFound);
	
}
#pragma mark - Base64 Encoding

- (NSString *)base64EncodedString  {
    if ([self length] == 0) {
        return nil;
	}
	
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}
- (NSString*)base64replaceString{
    if ([self length] == 0) {
        return nil;
	}
	
	 NSString *string =  [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    string = [string stringByReplacingOccurrencesOfString:@"=" withString:@"."];
    string = [string stringByReplacingOccurrencesOfString:@"+" withString:@"*"];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"-"];

    return string;
}

+ (NSString *)stringWithBase64String:(NSString *)base64String {
	return [[NSString alloc] initWithData:[NSData dataFromBase64EncodedString:base64String] encoding:NSUTF8StringEncoding];
}


+ (NSString*)strToShowText:(NSString*)sourStr
{
    return [NSString strToShowText:sourStr defaultStr:@""];
}

+ (NSString*)strToShowText:(NSString*)sourStr defaultStr:(id)defaultStr
{
    if(!sourStr)
    {
        return defaultStr;
    }
    
    return sourStr;
}

+ (NSString*)strFilterHtml:(NSString *)sourStr
{
    return [sourStr stringByReplacingOccurrencesOfRegex:@"<\\/*\\s*span\\s*\\w*[=*\"*\\w*\"*]*\\s*>" withString:@""];
}

@end
