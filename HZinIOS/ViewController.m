//
//  ViewController.m
//  HZinIOS
//
//  Created by tony on 13-11-22.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

const int fontRow = 16;
const int fontCol = 16/8;
const unsigned int fontOffset = 1;//16*16,24*24 -1 ,font pixal > 24 -16
NSString * fontName = @"HZK16";
unsigned char buffer[fontRow*fontCol];

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goDraw:(id)sender {
    NSString *fPath = [[NSBundle mainBundle] pathForResource:fontName ofType:@""];
    //FILE *file = fopen([fPath cStringUsingEncoding:1], "rb");
    const char *filePath = [fPath cStringUsingEncoding:1];
    NSLog(@"File Open Path:%@",fPath);
    *buffer = convHz(filePath,"谭");    
    bool flag;
    unsigned char key[8] = {
        0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01
    };
    int i,j,k;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 255, 1);
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(ctx, 255, 0, 0, 1);
    for(k=0; k<fontRow; k++){
        for(j=0; j<fontCol; j++){
            for(i=0; i<8; i++){
                flag = buffer[k*fontCol+j]&key[i];
                // printf("%s", flag?"*":" ");
                //if flag true draw a point
                if (flag) {
                    CGContextFillRect(ctx, CGRectMake(i+(j*8) + 10,k + 10, 1, 1));
                    //CGContextFillRect(ctx, CGRectMake(k,i+(j*8), 1, 1));
                }
            }
        }
        //printf("\n");
    }
    
    *buffer = convHz(filePath,"新");
    for(k=0; k<fontRow; k++){
        for(j=0; j<fontCol; j++){
            for(i=0; i<8; i++){
                flag = buffer[k*fontCol+j]&key[i];
                // printf("%s", flag?"*":" ");
                //if flag true draw a point
                if (flag) {
                    CGContextFillRect(ctx, CGRectMake(i*2+(j*8)*2 + 30,k*2 + 10, 2, 2));
                    //CGContextFillRect(ctx, CGRectMake(k,i+(j*8), 1, 1));
                }
            }
        }
        //printf("\n");
    }
    
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 100,0);
    CGContextAddLineToPoint(ctx, 100,100);
    CGContextAddLineToPoint(ctx, 0,100);
    CGContextAddLineToPoint(ctx, 0,0);
    CGContextStrokePath(ctx);
    //CGContextFillPath(ctx);
    
    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    UIImageView *iv = [[UIImageView alloc]initWithImage:im];
    [self.view addSubview:iv];
    iv.center = self.view.center;
    
    NSLog(@"Draw down");
    //fclose(file);
}

char * ConvertEnc( char *encFrom, char *encTo, const char * in)
{
    
    static char  bufout[1024], *sin, *sout;
    size_t lenin, lenout, ret;
    iconv_t c_pt;
    
    if ((c_pt = iconv_open(encTo, encFrom)) == (iconv_t)-1)
    {
#ifdef _DEBUG_XML_
        printf("iconv_open false: %s ==> %s\n", encFrom, encTo);
#endif
        return NULL;
    }
    iconv(c_pt, NULL, NULL, NULL, NULL);
    lenin  = strlen(in) + 1;
    lenout = 1024;
    sin    = (char *)in;
    sout   = bufout;
    ret = iconv(c_pt, &sin, (size_t *)&lenin, &sout, (size_t *)&lenout);
    if (ret == -1)
    {
        return NULL;
    }
    iconv_close(c_pt);
    return bufout;
    
}

unsigned char * convHz(char * path,const char *c)
{
    FILE* fphzk = NULL;
    int i, j, k, offset;
    int flag;
    //const char * word = "谭";
    const char * gbWord="";
    unsigned char key[8] = {
        0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01
    };
    
    fphzk = fopen(path, "rb");
    if(fphzk == NULL){
        fprintf(stderr, "error hzk16\n");
        return 1;
    }
    gbWord = ConvertEnc("UTF-8", "GB2312", c);
    offset = (94*(unsigned int)((unsigned int)(gbWord[0]&0xFF)-0xa0-fontOffset)+(unsigned int)(gbWord[1]&0xFF)-0xa0-1)*fontRow*fontCol;//Font 16*16 -1 ;Font 48*48 -16
    //offset = 130048;
    printf("H:%0X  L:%0X OffSet:%i\n",gbWord[0]&0xFF,gbWord[1]&0xFF,offset);
    //offset = (94*(unsigned int)(0xcc-0xa0-1)+(0xb7-0xa0-1))*32;
    fseek(fphzk, offset, SEEK_SET);
    fread(buffer, 1, fontRow*fontCol, fphzk);
    for(k=0; k<32; k++){
        printf("%02X ", buffer[k]);
    }
    printf("\n");
    for(k=0; k<fontRow; k++){
        for(j=0; j<fontCol; j++){
            for(i=0; i<8; i++){
                flag = buffer[k*fontCol+j]&key[i];
                printf("%s", flag?"*":" ");
            }
        }
        printf("\n");
    }
    fclose(fphzk);
    fphzk = NULL;
    return buffer;
}
@end
