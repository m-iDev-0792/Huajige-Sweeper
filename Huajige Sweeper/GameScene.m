//
//  GameScene.m
//  Huajige Sweeper
//
//  Created by 何振邦 on 16/10/22.
//  Copyright (c) 2016年 何振邦. All rights reserved.
//

#import "GameScene.h"
#import "GameNode.h"
@implementation SKView (Right_Mouse)
-(void)rightMouseDown:(NSEvent *)theEvent {
    [self.scene rightMouseDown:theEvent];
}
- (void) resetCursorRects
{
    [super resetCursorRects];
    NSCursor *shovel=[NSCursor alloc];
    NSImage *img=[NSImage imageNamed:@"shovel"];
    [shovel initWithImage:img hotSpot:CGPointMake(11, 20)];
    [self addCursorRect: [self bounds]
                 cursor: shovel];
    
}
@end
@implementation GameScene
@synthesize xNum;
@synthesize yNum;

-(void)didMoveToView:(SKView *)view {
    boomAnimate=[[NSMutableArray alloc]init];
    for (int i=1; i<=17; ++i) {
        [boomAnimate addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"boom%d",i]]];
    }
    //NSLog(@"boom%lu",(unsigned long)[boomAnimate count]);
    mineObject=[[NSMutableArray alloc]init];
    SKLabelNode* note=[SKLabelNode labelNodeWithText:@"选择游戏难度"];
    note.position=CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4);
    note.fontSize=50;
    note.fontColor=[SKColor blackColor];
    [self addChild:note];
    SKSpriteNode* background=[SKSpriteNode spriteNodeWithImageNamed:@"soil1"];
    background.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    background.zPosition=-1;
    [self addChild:background];
    [self showDifficultyChoose];

}

-(void)mouseDown:(NSEvent *)theEvent {
    CGPoint location = [theEvent locationInNode:self];
    GameNode* node=(GameNode*)[self nodeAtPoint:location];
        if([node isKindOfClass:[GameNode class]]){
            if(gameState!=gaming)return;
            if ([node isMine]) {
                //下面是处理失败的代码
                gameState=fail;
                [self gameEnd];
            }else{
                if (reached[node.x][node.y])return;//访问过了不必再访问了
                [self DFSatX:node.x Y:node.y];
            }
        }else if([node isKindOfClass:[SKSpriteNode class]]){
            
            if ([node.name isEqualToString:@"restart"]) {
                [self removeAllChildren];
                [self startWithXNum:xNum YNum:yNum];
            }else if([node.name isEqualToString:@"change"]){
                [self showDifficultyChoose];
            }else if([node.name isEqualToString:@"beginner"]){
                mineNum=9;
                xNum=9;yNum=9;
                [self removeAllChildren];
                [self startWithXNum:xNum YNum:yNum];
            }else if([node.name isEqualToString:@"intermediate"]){
                mineNum=40;
                xNum=20;yNum=16;
                [self removeAllChildren];
                [self startWithXNum:xNum YNum:yNum];
            }else if([node.name isEqualToString:@"high"]){
                mineNum=99;
                xNum=28;yNum=20;
                [self removeAllChildren];
                [self startWithXNum:xNum YNum:yNum];
            }else if([node.name isEqualToString:@"crazy"]){
                mineNum=200;
                xNum=30;yNum=20;
                [self removeAllChildren];
                [self startWithXNum:xNum YNum:yNum];
            }
        }
}
//显示难度选择界面
-(void)showDifficultyChoose{
    SKLabelNode* author=[SKLabelNode labelNodeWithText:@"何振邦版权所有 2016"];
    author.fontName=@"Lantinghei";
    author.fontSize=18;
    author.position=CGPointMake(512, 20);
    [self addChild:author];
    SKSpriteNode* beginner=[SKSpriteNode spriteNodeWithImageNamed:@"beginner"];
    SKSpriteNode* intermediate=[SKSpriteNode spriteNodeWithImageNamed:@"intermediate"];
    SKSpriteNode* high=[SKSpriteNode spriteNodeWithImageNamed:@"high"];
    SKSpriteNode* crazy=[SKSpriteNode spriteNodeWithImageNamed:@"crazy"];
    beginner.name=@"beginner";
    intermediate.name=@"intermediate";
    high.name=@"high";
    crazy.name=@"crazy";
    //初始化
    beginner.zPosition=intermediate.zPosition=high.zPosition=crazy.zPosition=4;
    beginner.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    intermediate.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    high.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    crazy.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    beginner.xScale=intermediate.xScale=high.xScale=crazy.xScale=0.6;
    beginner.yScale=intermediate.yScale=high.yScale=crazy.yScale=0.6;
    
    [self addChild:beginner];[self addChild:intermediate];
    [self addChild:high];[self addChild:crazy];
    beginner.hidden=intermediate.hidden=high.hidden=crazy.hidden=YES;
    //动画显示
    SKAction* appear=[SKAction unhide];
    [beginner runAction:[SKAction sequence:[NSArray arrayWithObjects:appear, [SKAction moveToX:self.frame.size.width/5 duration:0.5],nil]]];
    [intermediate runAction:[SKAction sequence:[NSArray arrayWithObjects: appear,[SKAction moveToX:2*self.frame.size.width/5 duration:0.5],nil]]];
    [high runAction:[SKAction sequence:[NSArray arrayWithObjects: appear,[SKAction moveToX:3*self.frame.size.width/5 duration:0.5],nil]]];
    [crazy runAction:[SKAction sequence:[NSArray arrayWithObjects: appear,[SKAction moveToX:4*self.frame.size.width/5 duration:0.6],nil]]];
}
-(void)rightMouseDown:(NSEvent *)theEvent{
    if(gameState!=gaming)return;//不是游戏状态不必响应鼠标右键了
    CGPoint location=[theEvent locationInNode:self];
    GameNode* node=(GameNode*)[self nodeAtPoint:location];
    SKLabelNode* mineRemain=(SKLabelNode*)[self childNodeWithName:@"mineRemain"];
    if ([node isKindOfClass:[GameNode class]]) {
        if(reached[node.x][node.y])return;
        if (node.textureFlag==flag) {
            node.texture=[SKTexture textureWithImageNamed:@"question"];
            --mineMarked;
            if (mine[node.x][node.y]) {
                --mineGuessed;
            }
            node.textureFlag=question;
            mineRemain.text=[NSString stringWithFormat:@"地雷数:%d",mineNum-mineMarked];
        }else if(node.textureFlag==question){
            node.texture=[SKTexture textureWithImageNamed:@"unrevealed"];
            node.textureFlag=other;
        }else{
            if (mineMarked>=mineNum) {
                return;
            }else{
                node.texture=[SKTexture textureWithImageNamed:@"flag"];
                ++mineMarked;
                node.textureFlag=flag;
                mineRemain.text=[NSString stringWithFormat:@"地雷数:%d",mineNum-mineMarked];
                if (mine[node.x][node.y]) {
                    ++mineGuessed;
                    if (mineGuessed==mineNum) {
                        //胜利了！下面是处理胜利代码
                        gameState=win;
                        [self gameEnd];
                    }
                }
            }
        }
    }
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if(gameState!=gaming)return;
    if (lastTime<0) {
        lastTime=currentTime;
        return;
    }
    if (currentTime-lastTime>=1) {
        ++totalTime;
        lastTime=currentTime;
        SKLabelNode* timeLabel=(SKLabelNode*)[self childNodeWithName:@"gameTime"];
        timeLabel.text=[NSString stringWithFormat:@"时间:%ld",totalTime];
    }
}
-(void)mineClear{
    for (int i=0; i<64; ++i) {
        for (int j=0; j<64; ++j) {
            mine[i][j]=NO;
            reached[i][j]=NO;
        }
    }
}
-(void)showScene{
    SKLabelNode* gameTime=[SKLabelNode labelNodeWithText:@"时间:"];
    gameTime.name=@"gameTime";
    gameTime.fontName=@"Lantinghei";
    gameTime.fontSize=32;
    gameTime.position=CGPointMake(73, 700);
    gameTime.zPosition=3;
    SKLabelNode* mineRemain=[SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"地雷数:%d",mineNum-mineMarked]];
    mineRemain.name=@"mineRemain";
    mineRemain.fontName=@"Lantinghei";
    mineRemain.fontSize=32;
    mineRemain.position=CGPointMake(885, 700);
    mineRemain.zPosition=3;
    gameTime.fontColor=mineRemain.fontColor= [SKColor blackColor];
    SKSpriteNode* background=[SKSpriteNode spriteNodeWithImageNamed:@"soil1"];
    background.position=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    background.zPosition=-1;
    [self addChild:gameTime];[self addChild:mineRemain];[self addChild:background];
}
-(void)startWithXNum:(int)XNum YNum:(int)YNum{
    [mineObject removeAllObjects];
    float xStart=(self.frame.size.width-32*XNum)/2+16;
    float yStart=(self.frame.size.height-32*YNum)/2+16;
    lastTime=-1;
    totalTime=0;
    [self mineClear];
    mineGuessed=0;
    mineMarked=0;
    gameState=gaming;
    int mineCount=0;
    //随机赋给产生地雷
    while (mineCount!=mineNum) {
        int tempX;int tempY;
        tempX=arc4random_uniform(XNum);
        tempY=arc4random_uniform(YNum);
        if (!mine[tempX][tempY]) {
            mine[tempX][tempY]=YES;
            ++mineCount;
            //NSLog(@"mine:(%d,%d)",tempX,tempY);
        }
    }
    //初始化界面
    [self showScene];
    for (int i=0; i<XNum; ++i) {
        for (int j=0; j<YNum; ++j) {
            GameNode* temp=[GameNode spriteNodeWithImageNamed:@"unrevealed"];
            temp.name=[NSString stringWithFormat:@"%d,%d",i,j];
            temp.x=i;temp.y=j;
            temp.isMine=mine[i][j];
            if (temp.isMine) {
                [mineObject addObject:temp];
            }
            temp.position=CGPointMake(xStart+32*i, yStart+32*j);
            temp.textureFlag=other;
            [self addChild:temp];
        }
    }
    NSLog(@"%lu",(unsigned long)[mineObject count]);
    
}
-(void)gameEnd{
    for(GameNode* temp in mineObject){
        if (temp.textureFlag==flag) {
            temp.texture=[SKTexture textureWithImageNamed:@"yinxian"];
        }else{
            [temp runAction:[SKAction animateWithTextures:[boomAnimate copy] timePerFrame:0.06 resize:YES restore:YES
                             ]];
            temp.texture=[SKTexture textureWithImageNamed:@"huaji"];
            
        }
        //NSLog(@"%@",temp.name);
    }
    SKSpriteNode *gameResult=[SKSpriteNode spriteNodeWithImageNamed:gameState==win?@"win":@"lose"];
    gameResult.position=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    gameResult.zPosition=3;
    gameResult.hidden=YES;
    [self addChild:gameResult];
    SKAction* scale1=[SKAction scaleTo:3.5 duration:0.1];
    SKAction* scale2=[SKAction scaleTo:3 duration:0.05];
    SKAction* scale3=[SKAction scaleTo:0.2 duration:0.1];
    SKAction* gameResultAppear=[SKAction unhide];
    SKAction* disapper=[SKAction removeFromParent];
    SKAction* combo=[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:2],gameResultAppear,scale1,scale2,[SKAction waitForDuration:1.5],scale3,disapper, nil]];
    [gameResult runAction:combo];
    
    //显示菜单
    SKSpriteNode* menu=[SKSpriteNode spriteNodeWithImageNamed:@"menu"];
    menu.name=@"menu";
    menu.anchorPoint=CGPointMake(0.5, 0.5);
    menu.position=CGPointMake(self.frame.size.width/2,self.frame.size.height);
    menu.zPosition=2;
    menu.hidden=YES;
    [self addChild:menu];
    SKSpriteNode* restart=[SKSpriteNode spriteNodeWithImageNamed:@"restart"];
    restart.name=@"restart";
    restart.position=CGPointMake(0,40);
    restart.zPosition=2;
    restart.xScale=0.5;restart.yScale=0.5;
    //restart.hidden=YES;
    SKSpriteNode* changeDifficult=[SKSpriteNode spriteNodeWithImageNamed:@"setting"];
    changeDifficult.name=@"change";
    changeDifficult.position=CGPointMake(0,-40);
    changeDifficult.zPosition=2;
    changeDifficult.xScale=0.6;changeDifficult.yScale=0.6;
    //changeDifficult.hidden=YES;
    [menu addChild:restart];
    [menu addChild:changeDifficult];
    SKAction* drop=[SKAction moveToY:self.frame.size.height/2 duration:0.2];
    SKAction* menuAppear=[SKAction sequence:[NSArray arrayWithObjects:[SKAction waitForDuration:4.5],[SKAction unhide],drop, nil]];
    [menu runAction:menuAppear];
    

}
-(int)numOfMineAroundwithX:(int)X Y:(int)Y{
    int num=0;
    for (int i=-1; i<=1; ++i) {
        for (int j=-1; j<=1; ++j) {
            if ((X+i<0)||(X+i>=xNum)||(Y+j<0)||(Y+j>=yNum)) {//超过边界跳过
                continue;
            }else if((i==0)&&(j==0))continue;//指向本身跳过
            else{
                if (mine[X+i][Y+j]) {
                    ++num;
                }
            }
        }
    }
    return num;
}
-(void)DFSatX:(int)X Y:(int)Y{
    if (X<0||X>=xNum||Y<0||Y>=yNum) {
        return;//越界退出
    }
    if (reached[X][Y]) {
        return;//访问过了退出
    }
    //NSLog(@"dfs at %d,%d",X,Y);
    int mineNumAround=[self numOfMineAroundwithX:X Y:Y];
    reached[X][Y]=YES;
    if (mineNumAround==0) {
        GameNode* node=(GameNode*)[self childNodeWithName:[NSString stringWithFormat:@"%d,%d",X,Y]];
        node.texture=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mines_%d",mineNumAround]];
        [self DFSatX:X-1 Y:Y+1];
        [self DFSatX:X-1 Y:Y];
        [self DFSatX:X-1 Y:Y-1];
        [self DFSatX:X Y:Y+1];
        [self DFSatX:X Y:Y-1];
        [self DFSatX:X+1 Y:Y+1];
        [self DFSatX:X+1 Y:Y];
        [self DFSatX:X+1 Y:Y-1];
    
    }else{
        GameNode* node=(GameNode*)[self childNodeWithName:[NSString stringWithFormat:@"%d,%d",X,Y]];
        node.texture=[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mines_%d",mineNumAround]];
    }
}
@end
