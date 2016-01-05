//
//  GraphView.m
//  PerfectSitup
//
//  Created by lion on 7/28/14.
//  Copyright (c) 2014 speech. All rights reserved.
//

#import "GraphView.h"

@interface GraphView ()

@property (assign, nonatomic) BOOL isShowEntry;
@property (assign, nonatomic) CGFloat maxTouchDelta;
@property (strong, nonatomic) UILabel *entryInfoLabel;

@property (assign, nonatomic) float minimumCount;
@property (assign, nonatomic) float maximumCount;
@property (assign, nonatomic) float averageCount;
@property (strong, nonatomic) NSDate *earliestDate;
@property (strong, nonatomic) NSDate *latestDate;

@property (assign, nonatomic) CGFloat barWidth;

@property (assign, nonatomic) CGFloat topY;
@property (assign, nonatomic) CGFloat bottomY;
@property (assign, nonatomic) CGFloat minX;
@property (assign, nonatomic) CGFloat maxX;



@end

@implementation GraphView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)drawBar
{
    for (UIView *bar in _barViews) {
        [bar removeFromSuperview];
    }
    self.barViews = [[NSMutableArray alloc] init];
    
    BOOL maxShowed = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    for (int n = 0; n < _situpEntries.count; n++) {
        
        //bar
        SitupEntry *entry = [_situpEntries objectAtIndex:n];
        CGRect rect = [self calculateBarRect:n];
        UIView *bar = [[UIView alloc] initWithFrame:rect];
        if (entry.count == 0)
            bar.backgroundColor = [UIColor clearColor];
        else
            bar.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bar];
        [self.barViews addObject:bar];
        
        //bottom of bar
        rect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height,
                                  rect.size.width, MIN_BAR_HEIGHT);
        [[UIColor whiteColor] setFill];
        [[UIBezierPath bezierPathWithRect:rect] fill];

        //max info
        if (maxShowed == NO && entry.count == self.maximumCount && entry.count > 0) {
            maxShowed = YES;
            [self showMaxInfo:n];
        }

        //bottom label
        switch (_viewMode) {
            case VIEW_TOTAL:
                if (_situpEntries.count == 12 ||
                    n == 0 || n % 12 == 11) {
                    [dateFormatter setDateFormat:@"MM"];
                    int mm = [[dateFormatter stringFromDate:entry.date] intValue];
                    [self showDateInfo:n date:[NSString stringWithFormat:@"%d", mm]];
                }
                break;
            case VIEW_MONTH:
                if (n == 0 || n % 7 == 6) {
                    [dateFormatter setDateFormat:@"dd"];
                    int dd = [[dateFormatter stringFromDate:entry.date] intValue];
                    [self showDateInfo:n date:[NSString stringWithFormat:@"%d", dd]];
                }
                break;
            case VIEW_WEEK:
                [self showDateInfo:n date:_weekDay[n]];
                break;
        }
    }
}

- (int) touchedBar:(CGPoint)point
{
    
    for (int n = 0; n < _barViews.count; n++) {
        UIView *bar = [_barViews objectAtIndex:n];
        if (CGRectContainsPoint([bar frame], point)) {
            return n;
        }
    }
    return -1;
}

- (CGFloat) calculateBarWidth
{
    CGFloat w = 0;
    
    if (_situpEntries.count > 0)
        w = (self.maxX - self.minX) / (_situpEntries.count * 2 - 1);
    
    return w;
}

- (CGRect) calculateBarRect: (int)index
{
    SitupEntry *entry = [_situpEntries objectAtIndex:index];
    CGRect rect;
    CGFloat left, height;
    
    left = self.minX + self.barWidth * index * 2;
    
    if (self.maximumCount == 0 || entry.count == 0)
    {
        height = MIN_BAR_HEIGHT;
    }
    else if (self.minimumCount == self.maximumCount)
    {
        height = (self.bottomY - self.topY) / (CGFloat)2.0;
    }
    else
    {
        CGFloat percent = (entry.count - self.minimumCount) / (self.maximumCount - self.minimumCount);
        height = (self.bottomY - self.topY) * percent;
        height = (height > MIN_BAR_HEIGHT) ? height : MIN_BAR_HEIGHT;
    }
    
    rect.origin.x = left;
    rect.origin.y = self.bottomY - height;
    rect.size.height = height;
    rect.size.width = self.barWidth;
    
    return rect;
}
- (void)drawGraph
{
    // if we don’t have any entries, we’re done
    if ([self.situpEntries count] == 0) return;
    
    
    UIBezierPath *barGraph = [UIBezierPath bezierPath];
    barGraph.lineWidth = self.graphLineWidth;
    
    UIBezierPath *barGrid = [UIBezierPath bezierPath];
    barGrid.lineWidth = self.gridLineWidth;
    
    UIBezierPath *barAxis = [UIBezierPath bezierPath];
    barAxis.lineWidth = self.axisLineWidth;
    
    
    BOOL firstEntry = YES;
    for (SitupEntry *entry in self.situpEntries) {
        
        //graph
        CGFloat x = [self calculateXForDate:entry.date];
        CGFloat y = [self calculateYForCount:entry.count];
        CGPoint point = CGPointMake(x, y);
        
        if (firstEntry)
        {
            [barGraph moveToPoint:point];
            firstEntry = NO;
        }
        else
        {
            [barGraph addLineToPoint:point];
        }
        //guide
        if (entry.count == self.maximumCount) {
            [self drawGuidelineAtY:point withLabelText:[NSString stringWithFormat:@"MAX: %d sit ups", entry.count]];
        }
        //grid
        [barGrid moveToPoint:CGPointMake(x, self.bottomY)];
        [barGrid addLineToPoint:CGPointMake(x, y)];
        
    }

    //axis
//    [barAxis moveToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds))];
//    [barAxis addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
//    [barAxis moveToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds))];
//    [barAxis addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds))];
    [barAxis moveToPoint:CGPointMake(self.minX, self.bottomY)];
    [barAxis addLineToPoint:CGPointMake(self.maxX, self.bottomY)];
    [barAxis moveToPoint:CGPointMake(self.minX, self.bottomY)];
    [barAxis addLineToPoint:CGPointMake(self.minX, self.topY)];
    
    [self.axisLineColor setStroke];
    [barAxis stroke];

    [self.gridLineColor setStroke];
    [barGrid stroke];

    [self.graphLineColor setStroke];
    [barGraph stroke];

    for (SitupEntry *entry in self.situpEntries) {
        
        //dot
        [self drawDotForEntry:entry];
    }
    
}

- (void)drawGuidelineAtY:(CGPoint)p withLabelText:(NSString *)text
{
    
    NSDictionary *textAttributes =
    @{NSFontAttributeName:self.labelFont,
      NSForegroundColorAttributeName:self.fontColor};
    
    //show max situp
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(self.minX,
                                 p.y - textSize.height - 1,
                                 textSize.width,
                                 textSize.height);
    
    textRect = CGRectIntegral(textRect);
    
//    UIBezierPath *textbox = [UIBezierPath bezierPathWithRect:textRect];
//    [self.superview.backgroundColor setFill];
//    [textbox fill];
    
    [text drawInRect:textRect withAttributes:textAttributes];

    //show begin date
    textSize = [self.beginDate sizeWithAttributes:textAttributes];
    textRect = CGRectMake(CGRectGetMinX(self.bounds),
                          self.bottomY + 1,
                          textSize.width,
                          textSize.height);
    
    textRect = CGRectIntegral(textRect);
    
//    textbox = [UIBezierPath bezierPathWithRect:textRect];
//    [self.superview.backgroundColor setFill];
//    [textbox fill];
    
    [self.beginDate drawInRect:textRect withAttributes:textAttributes];
    
    //show end date
    textSize = [self.endDate sizeWithAttributes:textAttributes];
    textRect = CGRectMake(CGRectGetMaxX(self.bounds) - textSize.width,
                          self.bottomY + 1,
                          textSize.width,
                          textSize.height);
    
    textRect = CGRectIntegral(textRect);
    
//    textbox = [UIBezierPath bezierPathWithRect:textRect];
//    [self.superview.backgroundColor setFill];
//    [textbox fill];
    
    [self.endDate drawInRect:textRect withAttributes:textAttributes];
    
    CGFloat pattern[] = {5, 2};
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    line.lineWidth = self.guideLineWidth;
    [line setLineDash:pattern count:2 phase:0];
    
    [line moveToPoint:CGPointMake(self.minX, p.y)];
    [line addLineToPoint:CGPointMake(p.x, p.y)];
    
    [self.guideLineColor setStroke];;
    [line stroke];
}

- (CGFloat) calculateXForDate:(NSDate *)date
{
    NSAssert([self.situpEntries count] > 0,
             @"You must have more than one entry "
             @"before you call this method");
    
    if ([self.earliestDate compare:self.latestDate] == NSOrderedSame )
    {
        return (self.maxX + self.minX) / (CGFloat)2.0;
    }
    
    NSTimeInterval max =
    [self.latestDate timeIntervalSinceDate:self.earliestDate];
    
    NSTimeInterval interval =
    [date timeIntervalSinceDate:self.earliestDate];
    
    CGFloat width = self.maxX - self.minX;
    CGFloat percent = (CGFloat)(interval / max);
    return percent * width + self.minX;
}

- (CGFloat)calculateYForCount:(CGFloat)Count
{
    NSAssert([self.situpEntries count] > 0,
             @"You must have more than one entry "
             @"before you call this method");
    
    if (self.minimumCount == self.maximumCount)
    {
        return (self.bottomY + self.topY) / (CGFloat)2.0;
    }
    
    CGFloat height = self.bottomY - self.topY;
    CGFloat percent = (CGFloat)1.0 - (Count - self.minimumCount) / (self.maximumCount - self.minimumCount);
    
    return height * percent + self.topY;
}

- (void)drawDotForEntry:(SitupEntry *)entry
{
    CGFloat x = [self calculateXForDate:entry.date];
    CGFloat y = [self calculateYForCount:entry.count];
    CGRect boundingBox =
    CGRectMake(x - (self.dotSize / (CGFloat)2.0),
               y - (self.dotSize / (CGFloat)2.0),
               self.dotSize,
               self.dotSize);
    
    UIBezierPath *dot =
    [UIBezierPath bezierPathWithOvalInRect:boundingBox];
    
    [self.dotColor setFill];
    [dot fill];
}

- (void)calculateGraphSize
{
    CGRect innerBounds =
    CGRectInset(self.bounds, self.margin, self.margin);
    self.topY = CGRectGetMinY(innerBounds) + self.margin;
    self.bottomY = CGRectGetMaxY(innerBounds);
    self.minX = CGRectGetMinX(innerBounds);
    self.maxX = CGRectGetMaxX(innerBounds);
    
    self.barWidth = [self calculateBarWidth];
}

- (void)clearGraphSize
{
    self.topY = 0.0;
    self.bottomY = 0.0;
    self.minX = 0.0;
    self.maxX = 0.0;
}

- (void)drawRect:(CGRect)rect
{
    [self redrawRect];
}

- (void)redrawRect
{
    [self calculateGraphSize];
    [self drawBar];
//    [self drawGraph];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Accessor Methods

- (void)setSitupEntries:(NSArray *)situpEntries
{
    _situpEntries = [NSMutableArray arrayWithArray: situpEntries];
    _weekDay = [[NSArray alloc] initWithObjects:
                        @"Mon",
                        @"Tue",
                        @"Wed",
                        @"Thu",
                        @"Fri",
                        @"Sat",
                        @"Sun",
                        nil];
    
    if ([_situpEntries count] > 0)
    {
        self.minimumCount =
        [[situpEntries valueForKeyPath:@"@min.count"] floatValue];
        
        self.maximumCount =
        [[situpEntries valueForKeyPath:@"@max.count"] floatValue];
        
        self.averageCount =
        [[situpEntries valueForKeyPath:@"@avg.count"] floatValue];
        
        self.earliestDate =
        [situpEntries valueForKeyPath:@"@min.date"];
        
        self.latestDate =
        [situpEntries valueForKeyPath:@"@max.date"];
        
        NSAssert([self.latestDate isEqualToDate:
                  [[self.situpEntries lastObject] date]],
                 @"The Count entry array must be "
                 @"in ascending chronological order");
        
        NSAssert([self.earliestDate isEqualToDate:
                  [self.situpEntries[0] date]],
                 @"The Count entry array must be "
                 @"in ascending chronological order");
    }
    else
    {
        self.minimumCount = 0.0;
        self.maximumCount = 0.0;
        self.averageCount = 0.0;
        self.earliestDate = nil;
        self.latestDate = nil;
    }
    
    
    [self setNeedsDisplay];
}


- (SitupEntry*) touchedEntry:(CGPoint)point
{
    
    for (SitupEntry *entry in self.situpEntries) {
        
        //graph
        CGFloat x = [self calculateXForDate:entry.date];
        CGFloat y = [self calculateYForCount:entry.count];
        
        if (ABS(point.x - x) < self.maxTouchDelta && ABS(point.y - y) < self.maxTouchDelta*2)
        {
            return entry;
        }
        
    }

    return NULL;
}

- (void) showEntryInfo:(int) index
{
    //show entry count
    NSDictionary *textAttributes =
    @{NSFontAttributeName:self.labelFont,
      NSForegroundColorAttributeName:self.fontColor};
    
    CGRect barRect = [[_barViews objectAtIndex:index] frame];
    SitupEntry *entry = [_situpEntries objectAtIndex:index];
    if (entry.count == self.maximumCount) {
        return;
    }
    
    NSString *text = [NSString stringWithFormat:@"%d", entry.count];
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(CGRectGetMidX(barRect) - textSize.width / 2,
                                 barRect.origin.y - textSize.height - 1,
                                 textSize.width,
                                 textSize.height);
    textRect = CGRectIntegral(textRect);
    
    self.entryInfoLabel = [[UILabel alloc] initWithFrame:textRect];
    [self.entryInfoLabel setFont:self.labelFont];
    [self.entryInfoLabel setTextColor:self.fontColor];
    [self.entryInfoLabel setText:text];
    [self addSubview:self.entryInfoLabel];
    
    self.isShowEntry = YES;
    
}

- (CGRect) showDateInfo:(int) index date:(NSString*) text
{
    //show entry count
    NSDictionary *textAttributes =
    @{NSFontAttributeName:self.dateFont,
      NSForegroundColorAttributeName:self.fontColor};
    
    CGRect barRect = [[_barViews objectAtIndex:index] frame];
    
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(CGRectGetMidX(barRect) - textSize.width / 2,
                                 barRect.origin.y + barRect.size.height + MIN_BAR_HEIGHT * 2,
                                 textSize.width,
                                 textSize.height);
    textRect = CGRectIntegral(textRect);
    [text drawInRect:textRect withAttributes:textAttributes];
    
    return textRect;
}

- (void) showMaxInfo:(int) index
{
    //show entry count
    NSDictionary *textAttributes =
    @{NSFontAttributeName:self.labelFont,
      NSForegroundColorAttributeName:self.fontColor};
    
    CGRect barRect = [[_barViews objectAtIndex:index] frame];
    SitupEntry *entry = [_situpEntries objectAtIndex:index];
    
    NSString *text = [NSString stringWithFormat:@"MAX:%d", entry.count];
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGRect textRect = CGRectMake(CGRectGetMidX(barRect) - textSize.width / 2,
                                 barRect.origin.y - textSize.height - 1,
                                 textSize.width,
                                 textSize.height);
    textRect = CGRectIntegral(textRect);
    [text drawInRect:textRect withAttributes:textAttributes];
}

#pragma touch delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    int index;

    if (self.isShowEntry == YES) {
        [self.entryInfoLabel removeFromSuperview];
        self.entryInfoLabel = NULL;
        self.isShowEntry = NO;
    }

    if ((index = [self touchedBar:pt]) >= 0) {
        [self showEntryInfo:index];
    }
}

#pragma mark - Private Methods

- (void)setDefaults
{
    
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    self.isShowEntry = NO;
    self.maxTouchDelta = 5.0;
    
    self.margin = 20.0;
    
    if (self.contentScaleFactor == 2.0)
    {
        self.guideLineYOffset = 0.0;
        
        self.guideLineWidth = 0.5;
        self.graphLineWidth = 2.0;
        self.gridLineWidth = 0.5;
        self.axisLineWidth = 1.0;
        self.dotSize = 4.0;
    }
    else
    {
        self.guideLineYOffset = 0.5;
        
        self.guideLineWidth = 1.0;
        self.graphLineWidth = 4.0;
        self.gridLineWidth = 1.0;
        self.axisLineWidth = 2.0;
        self.dotSize = 8.0;
    }
    
    self.guideLineColor = [UIColor whiteColor];
    self.graphLineColor = [UIColor blueColor];
    self.gridLineColor = [UIColor whiteColor];
    self.axisLineColor = [UIColor whiteColor];
    self.dotColor = [UIColor whiteColor];
    self.fontColor = [UIColor whiteColor];
    
    self.labelFont = [UIFont fontWithName: @"HelveticaNeue" size:15];
    self.dateFont = [UIFont fontWithName: @"HelveticaNeue" size:10];
    self.entryInfoLabel = NULL;
}
@end
