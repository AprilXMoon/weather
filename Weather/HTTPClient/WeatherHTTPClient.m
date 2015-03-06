//
//  WeatherHTTPClient.m
//  Weather
//
//  Created by April Lee on 2015/3/4.
//  Copyright (c) 2015年 Scott Sherwood. All rights reserved.
//

#import "WeatherHTTPClient.h"

static NSString *const WorldWeatherOnlineAPIKey = @"paste your API key"; //paste your API key here

static NSString *const WorldWeatherOnlineURLString = @"http://api.worldweatheronline.com/free/v2/";

@implementation WeatherHTTPClient

+ (WeatherHTTPClient *)shareWeatherHTTPClient
{
    //The sharedWeatherHTTPClient method uses Grand Central Dispatch to ensure the shared singleton object is only allocated once. 
    static WeatherHTTPClient *_shareWeatherHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareWeatherHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:WorldWeatherOnlineURLString]];
    });
    
    return _shareWeatherHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    
    return self;
}

- (void)updateWeatherAtLocation:(CLLocation *)location forNumberOfDays:(NSUInteger)number
{
    NSMutableDictionary *paramenters = [NSMutableDictionary dictionary];
    
    paramenters[@"num_of_days"] = @(number);
    paramenters[@"q"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude ,location.coordinate.longitude];
    paramenters[@"format"] = @"json";
    paramenters[@"key"] = WorldWeatherOnlineAPIKey;
    
    [self GET:@"weather.ashx" parameters:paramenters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didUpdateWithWeather:)]) {
            [self.delegate weatherHTTPClient:self didUpdateWithWeather:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didFailWithError:)]) {
            [self.delegate weatherHTTPClient:self didFailWithError:error];
        }
    }];
    
}

@end
