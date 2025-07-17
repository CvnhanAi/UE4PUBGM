//  PUBGOffsets.h
//  libShadowTrackerExtraDylib
//
//  Created by y on 2022/4/12.
//

#ifndef PUBGOffsets_hpp
#define PUBGOffsets_hpp

#include <stdio.h>
#include <string.h>


//完成
#define kPersistentLevel "0x30"      // Class: World. -> Level* PersistentLevel;
#define kActorList "0xA0"
#define kNetDriver "0x38"            // Class: World. -> NetDriver* NetDriver;
#define kServerConnection "0x78"     // Class: NetDriver. -> NetConnection* ServerConnection;
#define kPlayerController "0x98"     // Class: NetConnection. -> Actor* OwningActor;
#define klocalPlayerController "0x30"//不知道
////////////////////完成
#define kPawn "0x440"//0x430                // Class: Controller. -> Pawn* Pawn;
#define kCharacter "0x450"//0x440           //ch Class: Controller. -> Character* Character;
#define kControlRotation "0x468"//0x458     // Class: Controller. -> Rotator ControlRotation;

#define kMyTeam "0x8c8"//0x890              // Class: UAEPlayerController. -> int TeamID;
/////完成
#define kCameraCache "0x4b0"//0x470         // Class: PlayerCameraManager. -> CameraCacheEntry CameraCache;
#define kViewTarget "0x1030"//0xff0          // Class: PlayerCameraManager. -> TViewTarget ViewTarget;

#define kPlayerCameraManager "0x4d0"//0x4c0 // Class: PlayerController. -> PlayerCameraManager* PlayerCameraManager;
#define kMyHUD "0x4c8"//0x4b8               //ch Class: PlayerController. -> HUD* MyHUD;
////完成
#define kLegacyFontSize "0x134"         // Class: Font. -> int LegacyFontSize;设置字体的大小
#define kCanvas "0x480"//0x470               // Class: HUD. -> Canvas* Canvas;
#define kSizeX "0x40"                // Class: Canvas. -> int SizeX;
#define kSizeY "0x44"               // Class: Canvas. -> int SizeY;
//完成
#define kHealth "0xdb0"//0xd98    // Class: STExtraCharacter. -> float Health;血量
#define kHealthMax "0xdb4"//0xd9c // Class: STExtraCharacter. -> float HealthMax;最大血量
#define kbDead "0xdcc"//0xdb4     // Class: STExtraCharacter. -> bool bDead;判断死亡
#define kbIsGunADS "0x1069"//0x1029 // Class: STExtraCharacter. -> bool bIsGunADS;开镜自瞄
#define kCurrentVehicle "0xdf8"//0xde0   // Class: STExtraCharacter. -> STExtraVehicleBase* CurrentVehicle;交通工具控制
#define kPoseState "0x16f8"//未调用//0x15d8  //Class: STExtraBaseCharacter.STExtraCharacter.UAECharacter.Character.Pawn.Actor.Object  -> enum class ESTEPoseState PoseState;姿态
#define kNearDeatchComponent "0x1aa0"//ch未调用//0x18c0// Class: STExtraCharacter. -> STCharacterNearDeathComp* NearDeatchComponent;倒地状态 X
#define kBreathMax "0x16c"//ch未调用 // Class: STCharacterNearDeathComp. -> float BreathMax;倒地血量 X
/////完成
#define kbHidden "0x88"//ch未调用    // Class: Actor. -> bool bHidden;对象是否隐藏 X
#define kPlayerName "0x8f0"//0x8d8// Class: UAECharacter. -> FString PlayerName;名字
#define kNation "0x900"//未调用//0x8b8// Class: UAECharacter. -> struct FString Nation;;国家
#define kTeamID "0x928"//0x920    // Class: UAECharacter. -> int TeamID;队伍
#define kbIsAI "0x9c0"//0x9d1     // Class: UAECharacter. -> bool bIsAI;人机
#define kbIsMLAI "0x9c1"//ch未调用//0x9a2     // Class: UAECharacter. -> bool bIsMLAI;智能人机
#define kMLAIPlayer "0x928"//ch未调用//0x8e0// Class: UAECharacter. -> struct FString MLAIPlayerUID;智能人机
#define kMesh "0x498"//0x488      // Class: Character. -> SkeletalMeshComponent* Mesh;
#define kStaticMesh "0x8a8"//未调用//0x820// Class: StaticMeshComponent. -> StaticMesh* StaticMesh; X
#define kLastRenderTime "0x424"//ch未调用//0x400// float LastRenderTime;
#define kVelocity "0x12c"//ch未调用 // Class: MovementComponent. -> Vector Velocity;3D速度向量 X
///完成

#define kRelativeRotation "0x190"//人物朝向
#define kRootComponent "0x1b0"                // Class: Actor. -> SceneComponent* RootComponent;场景组件
#define kRelativeLocation "0x184"           // 184 Class: RootComponent. -> Vector RelativeLocation;三维向量 X
#define kRelativeScale3D "0x19c"//未调用           // 19c Class: SceneComponent. -> Vector RelativeScale3D;三维向量 X
#define kComponentVelocity "0x260"        // Class: SceneComponent. -> Vector ComponentVelocity; 三维移动速度
#define kRepMovement "0xb0"    // RepMovement ReplicatedMovement; 载具向量
#define kNearDeathBreath "0x1ab8"//未调用//0x18e0        // Class: STExtraBaseCharacter. -> float NearDeathBreath;倒地血量
#define kbIsWeaponFiring "0x16e8"//0x1600        // Class: STExtraBaseCharacter. -> bool bIsWeaponFiring;开火自瞄
//#define kbIsGunADS "0x1029"
#define kWeaponManagerComponent "0x24d8"//0x2298 // Class: STExtraBaseCharacter. -> CharacterWeaponManagerComponent* WeaponManagerComponent;武器管理组件
#define kCurrentWeaponReplicated "0x558" // Class: WeaponManagerComponent. -> STExtraWeapon* CurrentWeaponReplicated;武器复制状态
#define kShootWeaponComponent "0xef0"//0xec8    // Class: STExtraShootWeapon. -> STExtraShootWeaponComponent* ShootWeaponComponent;武器射击组件 X
#define kShootWeaponEntityComp "0x11b8"//0x1048   // Class: STExtraShootWeapon. -> ShootWeaponEntity* ShootWeaponEntityComp;武器实体组件
#define kShootWeaponEntityComponent "0x288"//未调用 // Class: STExtraShootWeaponComponent. -> ShootWeaponEntity* ShootWeaponEntityComponent;武器射击组件  X
#define kWeaponId "0x178"                  // Class: WeaponEntity. -> int WeaponId; //武器ID
#define kBulletFireSpeed "0x4c0"           // Class: ShootWeaponEntity. -> float BulletFireSpeed;子弹速度
#define kRecoilKickADS "0xbf8"//0xc58             // Class: ShootWeaponEntity. -> float RecoilKickADS;开镜后坐力

#define kGameDeviationFactor "0xb34"//未调用//0xba0       // Class: ShootWeaponEntity. -> float GameDeviationFactor;子弹据点


#define kShootMode "0xfe8"//0xf20           //武器射击模式enum class EShootWeaponShootMode ShootMode; 或者byte ShootMode; //武器射击模式

#define kCurBullet "0xf78"//0xea0//未调用  // int CurBulletNumInClip; 弹夹子弹
#define kCurMaxBullet "0xf90"//0xec0//未调用  // int CurMaxBulletNumInOneClip; 最大子弹

#define kVehicleCommon "0xbc0"//0xa08  // Class: STExtraVehicleBase. -> VehicleCommonComponent* VehicleCommon; 车辆组件
#define kHP "0x334"//0x2a4             // Class: VehicleCommonComponent. -> float HP;车辆血
#define kHPMax "0x330"//0x2a0          // Class: VehicleCommonComponent. -> float HPMax;车辆最大血
#define kFuel "0x3f4"//0x318           // Class: VehicleCommonComponent. -> float Fuel;车辆油
#define kFuelMax "0x3f0"//0x314        // Class: VehicleCommonComponent. -> float FuelMax;车辆最大油


#define kPickUpDataList "0x8a0"//未调用//0x848  // PickUpDataList; 盒子列表
#define kGoodsID "0x38"  // 不变; 盒子ID
#define kTableName "0x910"//未调用//0x870  // struct FString ItemTableName;;盒子物资数量

#define kCurrentStates "0xfa0"//未调用//0xf30  // uint64 CurrentStates;敌人状态
#define kFPS "0x128"  //未调用
////完成
#define kGameReplayType "0x9a4"
#define kScopeFov "0x1bac"
#define kPickUpAnim "0x2108"


#define kPressingFireBtn "0x36a0"

#define kCurrentReloadWeapon "0x2fe8"  ///
#define kCachedBulletTrackComponent "0xee8"  ///
#define wuhou    "0x190"  //


#define kYaw "0x880"
#define kRoll "0x888"
#define kPitch "0x878"
#endif /* PUBGOffsets_h */