//
//  GameScene.h
//  Huajige Sweeper
//

//  Copyright (c) 2016年 何振邦. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene{
    BOOL mine[64][64];
    int xNum;
    int yNum;
    int mineNum;
    int mineMarked;
    int mineGuessed;//猜中的地雷个数
    BOOL reached[64][64];
    enum gameStateCode{
        gaming=0,
        win=1,
        fail=2
    };
    enum gameStateCode gameState;
    NSMutableArray* mineObject;
    NSMutableArray* test;
    CFTimeInterval lastTime;
    long totalTime;
    NSMutableArray* boomAnimate;
}
@property int xNum;
@property int yNum;
-(void)mineClear;//把mine全部初始化为false
-(void)startWithXNum:(int)XNum YNum:(int)YNum;//初始化界面
-(int)numOfMineAroundwithX:(int)X Y:(int)Y;
-(void)gameEnd;
@end
