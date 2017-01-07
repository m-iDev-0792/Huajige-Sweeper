//
//  GameNode.h
//  Huajige Sweeper
//
//  Created by 何振邦 on 16/10/22.
//  Copyright © 2016年 何振邦. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
@interface GameNode : SKSpriteNode{
    int x;
    int y;
    BOOL isMine;
    enum textureType{
        other=0,
        flag=1,
        question=2
    };
    enum textureType textureFlag;//0其他纹理，1小旗子纹理，2问号纹理
}
@property int x;
@property int y;
@property BOOL isMine;
@property enum textureType textureFlag;
@end
