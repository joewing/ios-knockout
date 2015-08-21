
#import "BaseView.h"

#define BASE_VERSION_STRING "v1.2"
#ifdef LITE_VERSION
#define VERSION_STRING BASE_VERSION_STRING " Lite"
#else
#define VERSION_STRING BASE_VERSION_STRING
#endif

#define CREDITS_STRING1 "by Joe Wingbermuehle"
#define CREDITS_STRING2 "http://joewing.net"

static void DrawText(CGContextRef context, int x, int y, const char *str);

@implementation BaseView

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(self) {

      // Load the background image.
      bg_image = [UIImage imageNamed:@"bg.png"];

      // We only work in LandscapeRight mode, so set up a transform
      // for that mode.
      self.transform = CGAffineTransformMakeRotation(M_PI_2);
      self.bounds = CGRectMake(0, 0, 480, 320);
   }
   return self;

}

- (void)drawRect:(CGRect)rect {

   [bg_image drawAsPatternInRect:rect];

   [super drawRect:rect];

   CGContextRef context = UIGraphicsGetCurrentContext();

   CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 32.0, NULL);

   // Draw the title.
   CGContextSetTextPosition(context, 0, 0);
   CGContextSaveGState(context);
   CGContextSelectFont(context, "Helvetica-Bold", 32.0,
                       kCGEncodingMacRoman);
   CGContextSetRGBFillColor(context, 0.75, 0.0, 0.0, 1.0); 
   CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
   CGContextSetTextDrawingMode(context, kCGTextFillStroke);
   CGContextTranslateCTM(context, 8, 40);
   CGContextScaleCTM(context, 1.0, -1.0);

   CTFontRef font = CTFontCreateWithName("Helvetica-Bold", 12.0, NULL);
   CFStringRef keys[] = { kCTFontAttributeName };
   CFTypeRef values[] = { font };
   CFDictionaryRef attr = CFDictionaryCreate(kCFAllocatorDefault, &keys,
                                             &values,
                                             sizeof(keys) / sizeof(keys[0]));
   CFAttributedStringRef as = CFAttributedStringCreate(kcFAllocatoDefault,
                                                       "Knockout", attr);
   CFRelease(attr);
   CFRelease(font);
   CTLineRef line = CTLineCreateWithAttributedString(as);
   CTLineDraw(line, context);
   CFRelease(line);

   CGContextRestoreGState(context);

   // Draw the version.
   DrawText(context, 160, 40, VERSION_STRING);

   // Draw credits.
   DrawText(context, 8, 56, CREDITS_STRING1);
   DrawText(context, 8, 72, CREDITS_STRING2);

}

- (void)transitionComplete {
   // Nothing to do here.
}

- (void)dealloc {
   [super dealloc];
}

@end

void DrawText(CGContextRef context, int x, int y, const char *str) {

   CTFontRef font = CTFontCreateWithName("Helvetica-Bold", 12.0, NULL);
   CFStringRef keys[] = { kCTFontAttributeName };
   CFTypeRef values[] = { font };
   CFDictionaryRef attr = CFDictionaryCreate(kCFAllocatorDefault, &keys,
                                             &values,
                                             sizeof(keys) / sizeof(keys[0]));
   CFAttributedStringRef as = CFAttributedStringCreate(kcFAllocatoDefault,
                                                       str, attr);
   CFRelease(attr);
   CFRelease(font);

   CGContextSaveGState(context);
   CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); 
   CGContextSetTextPosition(context, 0, 0);
   CGContextTranslateCTM(context, x, y);
   CGContextScaleCTM(context, 1.0, -1.0);

   CTLineRef line = CTLineCreateWithAttributedString(as);
   CTLineDraw(line, context);
   CFRelease(line);

   CGContextRestoreGState(context);

}

