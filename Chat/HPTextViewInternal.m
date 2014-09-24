//
//  HPTextViewInternal.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPTextViewInternal.h"


@implementation HPTextViewInternal

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    if (text != nil) {
        [super setAttributedText:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
    }
    [self setScrollEnabled:originalValue];
    
    if (!text.length) {
        self.attachedImage = nil;
    }
}

- (NSString *)text;
{
    return self.attributedText.string ? self.attributedText.string : self.text;
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
		//initiated by user...
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
	} else {

		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomOffset && self.scrollEnabled){            
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;            
        }
	}
    
    // Fix "overscrolling" bug
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;

	[super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    // is this an iOS5 bug? Need testing!
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor)
    {
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            DLog(@"FONT: %@", self.font);
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = self.textAlignment;
            [self.placeholder drawInRect:CGRectMake(5,
                                                    8 + self.contentInset.top,
                                                    self.frame.size.width - self.contentInset.left,
                                                    self.frame.size.height - self.contentInset.top)
                          withAttributes:@{NSFontAttributeName:self.font,
                                           NSForegroundColorAttributeName:self.placeholderColor,
                                           NSParagraphStyleAttributeName:paragraphStyle}];
        }
        else {
            [self.placeholderColor set];
            [self.placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f)
                          withAttributes:@{NSFontAttributeName : self.font}];
        }
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
	_placeholder = placeholder;
	
	[self setNeedsDisplay];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
{
    NSLog(@"Action? %@ Sender? %@", NSStringFromSelector(action), sender);
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    
    if ([NSStringFromSelector(action) isEqualToString:@"paste:"] && gpBoard.image) { //add more types later.
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)paste:(id)sender;
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    UIImage *image = [gpBoard image];
    if (image) {
        [self addImage:image];
    } else {
        [super paste:sender];
    }
}

- (void)addImage:(UIImage *)image;
{
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    CGFloat max = 150.0;
    
    if (height > width && height > 150) {
        CGFloat ratio = height / max;
        height = height / ratio;
        width = width / ratio;
    } else if (width >= height && width > 150) {
        CGFloat ratio = width / max;
        height = height / ratio;
        width = width / ratio;
    }
    
    CGSize size = CGSizeMake(width, height);
                   
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);

    self.displayPlaceHolder = NO;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    self.attributedText = string;
    self.font = [UIFont systemFontOfSize:16];
    
    /// again, only supporting 1 for now.
    self.attachedImage = image;
    [self setNeedsDisplay];
}

- (BOOL)hasAttachment;
{
    return [self numberOfAttachments] > 0;
}

- (NSInteger)numberOfAttachments;
{
    return [[self locationOfAttachments] count];
}

- (NSArray *)locationOfAttachments;
{
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < self.attributedText.length; i++) {
        NSInteger character = [self.attributedText.string characterAtIndex:i];
        if (character == NSAttachmentCharacter) {
            [locations addObject:[NSValue valueWithRange:NSMakeRange(i, 1)]];
        }
    }
    return locations;
}

@end
