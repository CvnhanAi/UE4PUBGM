//
//  PUBGEngine.m
//  PUBGEngine
//
//  Created by ABC on 2021/10/11.
//
#include "Bone.hpp"
#include "utf.hpp"
#include <array>
#import "mahoa.h"
#include "PUBGEngine.hpp"
#include "PUBGOffsets.hpp"
#import "菜单.h"
#include <notify.h>
static long GWorld, UName, Engine, PersistentLevel, PlayerController, Character, PlayerCameraManager, ControlRotation, MyHUD, TinyFont, SmallFont, HUD, Canvas;
static int totalEnemies = 0;
static int robotcounts= 0;
static int MyTeam, pickItemCount;
static int WeaponId = 0;
static float tDistance = 0, markDistance,Health, markDis;
float Aimbot_Circle_Radius = 100;
static bool needAdjustAim = false , sniperrifle = false;
bool 显示盒子=NO;
static FVector CameraCache, TracktargetPos;
bool 投掷物预警=NO;
static FVector2D CanvasSize, markScreenPos;
static FVector2D rootScreen;
static MinimalViewInfo POV;
int 圆圈模式 = 1;
int 自瞄部位 = 0;
int 雷达大小 = 400;
int 雷达X = 500;
int 雷达Y = 60;
int 人物美化;
int 枪械美化;

int 圆圈固定 = 75;
int 预警范围 = 38;
float 自瞄速度 = 0.1;
float 命中率 = 1.00;
float 压枪速率 = 0;
float 击打距离 = 500;
//float 相机视野 = 80;
float 物资距离 = 500;

bool 屏蔽人机=NO;
const char *kDrawText;
const char *kDrawLine;
const char *kDrawRectFilled;
const char *kDrawCircleFilled;


const char *kEngine;
const char *kUWorld;
const char *kGNames;

const char *hookHUD;
const char *kGetHUD;

const char *kLineOfSight_1;
const char *kLineOfSight_2;
const char *kLineOfSight_3;
const char *kLineOfSight_4;
const char *kLineOfSight_5;

const char *kBonePos;

const char * kProjectWorldLocationToScreen;
//static const char *kDrawLine = "0x10560FED0";
//static const char *kDrawRectFilled = "0x10560FE40";
//static const char *kDrawCircleFilled = "0x1059B7238";
//
//
//static const char *kEngine = "0x1093514D8";
//static const char *kUWorld = "0x105D13894";
//static const char *kGNames = "0x1044748F4";
//
//
//static const char *hookHUD = "0x107814DF0";
//static const char *kGetHUD = "0x10332B270";
//
//
//static const char *kLineOfSight_1 = "0x1090410B8";
//static const char *kLineOfSight_2 = "0x10933A6D0";
//static const char *kLineOfSight_3 = "0x10546AE34";
//static const char *kLineOfSight_4 = "0x10546AF20";
//static const char *kLineOfSight_5 = "0x10547A940";

//static const char *kBonePos = "0x10302FE30";

#pragma mark - 内存读写
static uintptr_t Get_module_base() {
    
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        std::string path = (const char *)_dyld_get_image_name(i);
        if (path.find("ShadowTrackerExtra.app/ShadowTrackerExtra") != path.npos) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}
static bool IsValidAddress(long address) {
    return address && address > 0x100000000 && address < 0x3000000000;
}

static uintptr_t GetHexAddr(string address) {
    return (uintptr_t)strtoul(address.c_str(), nullptr, 16);
}

static uintptr_t GetRealOffset(string address) {
    return (Get_module_base() + GetHexAddr(address));
}

template<typename T>
static T Read(uintptr_t address) {
#if 0
    T data = *(T *)(address);
    return data;
#else
    T data;
    vm_copy(mach_task_self(), (vm_address_t)address, sizeof(T), (vm_address_t)&data);
    return data;
#endif
}

template<typename T>
static void Write(uintptr_t address, T data) {
#if 0
    *(T *)(address) = data;
#else
    vm_copy(mach_task_self(), (vm_address_t)&data, sizeof(T), (vm_address_t)address);
#endif
}

static bool Read_data(long Adder, int Size, void* buff) {
    kern_return_t kret = vm_copy(mach_task_self(), (vm_address_t)Adder, (vm_size_t)Size, (vm_address_t)buff);
    return kret == 0;
}

static uint64_t I64(string address) {
    return (uint64_t)strtoul(address.c_str(), nullptr, 16);
}

#pragma mark - 字符串工具

static bool isEqual(string s1, const char* check) {
    string s2(check);
    return (s1 == s2);
}

static bool isContain(string str, const char* check) {
    size_t found = str.find(check);
    return (found != string::npos);
}

template<typename ... Args>
static string string_format(const string& format, Args ... args){
    size_t size = 1 + snprintf(nullptr, 0, format.c_str(), args ...);  // Extra space for \0
    char bytes[size];
    snprintf(bytes, size, format.c_str(), args ...);
    return string(bytes);
}

#pragma mark - 颜色工具
static int PlayerColos(bool isVisible, bool isAi) {
    if (isAi) return isVisible ? Colour_黄色 : Colour_白色;
    else return isVisible ? Colour_绿色 : Colour_红色;
}
static int PColos(bool isVisible, bool isAi) {
    if (isAi) return isVisible ? Colour_绿色 : Colour_白色;
    else return isVisible ? Colour_绿色 : Colour_红色;
}
static int WeaponNameColor(bool IsAI, bool HeadSight) {
    if (IsAI) return Colour_白色;
    else return !HeadSight ? Colour_黄色 : Colour_红色;
}

static int HeadLineColor(bool IsAI, bool HeadSight) {
    if (IsAI) return Colour_白色;
    else return !HeadSight ? Colour_红色 : Colour_绿色;
}

static int BoneColos(bool b1, bool b2, bool isAi) {
    
    if (isAi) return b1 || b2 ? Colour_绿色 : Colour_白色;
    else return b1 || b2 ? Colour_绿色 : Colour_红色;
}

#pragma mark - 引擎绘制

static void DrawLine(FVector2D startPoint, FVector2D endPoint, int color, float thicknes = 1) {
    reinterpret_cast<void(__fastcall*)(long, struct FVector2D, struct FVector2D, struct FLinearColor, float) > (GetRealOffset(kDrawLine))(HUD, startPoint, endPoint, FLinearColor(color), thicknes);
}

static void DrawRectFilled(FVector2D pos, FVector2D size, int color, float thicknes = 2) {
    reinterpret_cast<void(__fastcall*)(long, struct FLinearColor, struct FVector2D, struct FVector2D) > (GetRealOffset(kDrawRectFilled))(HUD, FLinearColor(color), pos, size);
}
static void ADrawRectFilled(FVector2D pos, float w, float h, int color) {
    for (float i = 0.f; i < h; i += 1.f)
        DrawLine(FVector2D(pos.x, pos.y + i), FVector2D(pos.x + w, pos.y + i), 1.f, color);
}
static void DrawRect(FVector2D pos, FVector2D size, int color, float thicknes) {
    DrawLine(FVector2D(pos.x, pos.y), FVector2D(pos.x + size.x, pos.y), color, thicknes);
    DrawLine(FVector2D(pos.x, pos.y + size.y), FVector2D(pos.x + size.x, pos.y + size.y), color, thicknes);
    DrawLine(FVector2D(pos.x, pos.y), FVector2D(pos.x, pos.y + size.y), color, thicknes);
    DrawLine(FVector2D(pos.x + size.x, pos.y), FVector2D(pos.x + size.x, pos.y + size.y), color, thicknes);
}

static void DrawText(string text, FVector2D pos, int color, int fontsize = 12) {
    if (text.length() == 0) return;
    
    char str[text.length()];
    int i;
    for(i = 0; i < text.length(); i++)
        str[i] = text[i];
    str[i] = '\0';
    
    Write<long>(SmallFont + I64(kLegacyFontSize), fontsize);
    
    reinterpret_cast<void(__fastcall*)(long, long, const class FString&, struct FVector2D, struct FLinearColor, float, struct FLinearColor, struct FVector2D, bool, bool, bool, struct FLinearColor) > (GetRealOffset(kDrawText))(Canvas, SmallFont, FString(str), pos, FLinearColor(color), 0.5f, FLinearColor(0, 0, 0, 1.f), FVector2D(), true, false, true, FLinearColor(Colour_黑色));
}
static void DrawText2(string text, FVector2D pos, int color, int fontsize = 20) {
    if (text.length() == 0) return;
    
    char str[text.length()];
    int i;
    for(i = 0; i < text.length(); i++)
        str[i] = text[i];
    str[i] = '\0';
    
    Write<long>(SmallFont + I64(kLegacyFontSize), fontsize);
    
    reinterpret_cast<void(__fastcall*)(long, long, const class FString&, struct FVector2D, struct FLinearColor, float, struct FLinearColor, struct FVector2D, bool, bool, bool, struct FLinearColor) > (GetRealOffset(kDrawText))(Canvas, SmallFont, FString(str), pos, FLinearColor(color), 0.5f, FLinearColor(0, 0, 0, 1.f), FVector2D(), true, false, true, FLinearColor(Colour_黑色));
}
static void DrawTitle(string text, FVector2D pos, int color, int fontsize = 30) {
    if (text.length() == 0) return;
    
    char str[text.length()];
    int i;
    for(i = 0; i < text.length(); i++)
        str[i] = text[i];
    str[i] = '\0';
    
//    if (fontsize != 40)
        Write<long>(TinyFont + I64(kLegacyFontSize), fontsize);
    
    reinterpret_cast<void(__fastcall*)(long, long, const class FString&, struct FVector2D, struct FLinearColor, float, struct FLinearColor, struct FVector2D, bool, bool, bool, struct FLinearColor)>(GetRealOffset(kDrawText))(Canvas, TinyFont, FString(str), pos, FLinearColor(color), 1.f, FLinearColor(0, 0, 0, 1.f), FVector2D(8.f, 8.f), true, false, true, FLinearColor(Colour_黑色));
}

static void DrawCircle(FVector2D pos, float radius, int color, float thicknes = 1) {
    int num_segments = 360;
    float a_min = 0;
    float a_max = (M_PI * 2.0f) * ((float)num_segments - 1.0f) / (float)num_segments;
    
    std::vector<struct FVector2D> arcPoint;
    
    for (int i = 0; i <= num_segments; i++) {
        const float a = a_min + ((float)i / (float)num_segments) * (a_max - a_min);
        arcPoint.push_back(FVector2D(pos.x + cos(a) * radius, pos.y + sin(a) * radius));
    }
    
    for (int i = 1; i < arcPoint.size(); i++) {
        reinterpret_cast<void(__fastcall*)(long, struct FVector2D, struct FVector2D, struct FLinearColor, float)> (GetRealOffset(kDrawLine))(HUD, arcPoint[i-1], arcPoint[i], FLinearColor(color), thicknes);
    }
}

static void DrawCircleFilled(FVector2D pos, float radius, int color) {
    reinterpret_cast<void(__fastcall*)(long, long, struct FVector2D, struct FVector2D, int, struct FLinearColor)> (GetRealOffset(kDrawCircleFilled))(Canvas, 0, pos, FVector2D(radius, radius), 60, FLinearColor(color));
}

#pragma mark - 坐标系转换

static FMatrix RotatorToMatrix(FRotator rotation) {
    float radPitch = rotation.Pitch * ((float) M_PI / 180.0f);
    float radYaw = rotation.Yaw * ((float) M_PI / 180.0f);
    float radRoll = rotation.Roll * ((float) M_PI / 180.0f);

    float SP = sinf(radPitch);
    float CP = cosf(radPitch);
    float SY = sinf(radYaw);
    float CY = cosf(radYaw);
    float SR = sinf(radRoll);
    float CR = cosf(radRoll);

    FMatrix matrix;

    matrix[0][0] = (CP * CY);
    matrix[0][1] = (CP * SY);
    matrix[0][2] = (SP);
    matrix[0][3] = 0;

    matrix[1][0] = (SR * SP * CY - CR * SY);
    matrix[1][1] = (SR * SP * SY + CR * CY);
    matrix[1][2] = (-SR * CP);
    matrix[1][3] = 0;

    matrix[2][0] = (-(CR * SP * CY + SR * SY));
    matrix[2][1] = (CY * SR - CR * SP * SY);
    matrix[2][2] = (CR * CP);
    matrix[2][3] = 0;

    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;

    return matrix;
}

static FVector2D WorldToScreen(FVector worldLocation, MinimalViewInfo camViewInfo) {
    FMatrix tempMatrix = RotatorToMatrix(camViewInfo.Rotation);

    FVector vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
    FVector vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
    FVector vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);

    FVector vDelta = worldLocation - camViewInfo.Location;

    FVector vTransformed(FVector::Dot(vDelta, vAxisY), FVector::Dot(vDelta, vAxisZ), FVector::Dot(vDelta, vAxisX));

    if (vTransformed.z < 1.0f) vTransformed.z = 1.0f;

    float fov = camViewInfo.FOV;
    float screenCenterX = (CanvasSize.x / 2.0f);
    float screenCenterY = (CanvasSize.y / 2.0f);

    return FVector2D((screenCenterX + vTransformed.x * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.z),
                     (screenCenterY - vTransformed.y * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.z));
}
static void BoxConversion(FVector worldLocation, FVectorRect *rect,MinimalViewInfo POV) {
    FVector worldLocation2 = worldLocation;
    worldLocation2.z += 90.f;
    

    FVector2D calculate = WorldToScreen(worldLocation,POV);
    FVector2D calculate2 = WorldToScreen(worldLocation2,POV);

    
    rect->h = calculate.y - calculate2.y;
    rect->w = rect->h / 2.5;
    rect->x = calculate.x - rect->w;
    rect->y = calculate2.y;
    rect->w = rect->w * 2;
    rect->h = rect->h * 2;
}
static bool isScreenVisible(FVector2D LocationScreen) {
    if (LocationScreen.x > 0 && LocationScreen.x < CanvasSize.x &&
        LocationScreen.y > 0 && LocationScreen.y < CanvasSize.y) return true;
    else return false;
}

static bool GetInsideFov(float ScreenWidth, float ScreenHeight, FVector2D PlayerBone, float FovRadius) {
    FVector2D Cenpoint;
    Cenpoint.x = PlayerBone.x - (ScreenWidth / 2);
    Cenpoint.y = PlayerBone.y - (ScreenHeight / 2);
    if (Cenpoint.x * Cenpoint.x + Cenpoint.y * Cenpoint.y <= FovRadius * FovRadius) return true;
    return false;
}

static int GetCenterOffsetForVector(FVector2D point) {
    return sqrt(pow(point.x - CanvasSize.x/2, 2.0) + pow(point.y - CanvasSize.y/2, 2.0));
}
static FRotator Clamp(FRotator Rotation)
{
    if (Rotation.Yaw > 180.f)
        Rotation.Yaw -= 360.f;
    else if (Rotation.Yaw < -180.f)
        Rotation.Yaw += 360.f;

    if (Rotation.Pitch > 180.f)
        Rotation.Pitch -= 360.f;
    else if (Rotation.Pitch < -180.f)
        Rotation.Pitch += 360.f;

    if (Rotation.Pitch < -89.f)
        Rotation.Pitch = -89.f;
    else if (Rotation.Pitch > 89.f)
        Rotation.Pitch = 89.f;

    Rotation.Roll = 0.f;

    return Rotation;
}
static FRotator CalcAngle(FVector aimPos) {
    float hyp = sqrt(aimPos.x * aimPos.x + aimPos.y * aimPos.y + aimPos.z * aimPos.z);
    float Yaw =  atan2(aimPos.y, aimPos.x) * 180 / M_PI;
    float Pitch = asin(aimPos.z / hyp) * 180 / M_PI;
    FRotator aimRotation = {Pitch, Yaw, 0};
    return aimRotation;
}




#pragma mark -ActorsArray Decryption

struct ActorsEncryption {
    uint64_t Enc_1, Enc_2;
    uint64_t Enc_3, Enc_4;
};
struct Encryption_Chunk {
    uint32_t val_1, val_2, val_3, val_4;
    uint32_t val_5, val_6, val_7, val_8;
};
 
uint64_t DecryptActorsArray(uint64_t PersistentLevel, int Actors_Offset, int EncryptedActors_Offset)
{
    PersistentLevel = Read<long>(GWorld + I64(kPersistentLevel));
    if (!IsValidAddress(PersistentLevel)) return 0;
    if (PersistentLevel < 0x10000000) return 0;
     
    if (Read<uint64_t>(PersistentLevel + Actors_Offset) > 0)
        return PersistentLevel + Actors_Offset;
 
    if (Read<uint64_t>(PersistentLevel + EncryptedActors_Offset) > 0)
        return PersistentLevel + EncryptedActors_Offset;
 
    auto Encryption = Read<ActorsEncryption>(PersistentLevel + EncryptedActors_Offset + 0x10);
 
    if (Encryption.Enc_1 > 0)
    {
        auto Enc = Read<Encryption_Chunk>(Encryption.Enc_1 + 0x80);
        return (((((Read<uint8_t>(Encryption.Enc_1 + Enc.val_1)
        |(Read<uint8_t>(Encryption.Enc_1 + Enc.val_2) << 8))
        |(Read<uint8_t>(Encryption.Enc_1 + Enc.val_3) << 0x10)) & 0xFFFFFF)
        |((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_4) << 0x18)
        |((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_5) << 0x20)) & 0xFFFF00FFFFFFFFFF)
        |((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_6) << 0x28)
        |((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_7) << 0x30)
        |((uint64_t)Read<uint8_t>(Encryption.Enc_1 + Enc.val_8) << 0x38);
    }
    else if (Encryption.Enc_2 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_2);
        if (Encrypted_Actors > 0)
        {
            return ((uint16_t)(Encrypted_Actors - 0x400) & 0xFF00)
            |(uint8_t)(Encrypted_Actors - 0x04)
            |((Encrypted_Actors + 0xFC0000) & 0xFF0000)
            |((Encrypted_Actors - 0x4000000) & 0xFF000000)
            |((Encrypted_Actors + 0xFC00000000) & 0xFF00000000)
            |((Encrypted_Actors + 0xFC0000000000) & 0xFF0000000000)
            |((Encrypted_Actors + 0xFC000000000000) & 0xFF000000000000)
            |((Encrypted_Actors - 0x400000000000000) & 0xFF00000000000000);
        }
    }
    else if (Encryption.Enc_3 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_3);
        if (Encrypted_Actors > 0)
            return (Encrypted_Actors >> 0x38) | (Encrypted_Actors << (64 - 0x38));
    }
    else if (Encryption.Enc_4 > 0)
    {
        auto Encrypted_Actors = Read<uint64_t>(Encryption.Enc_4);
        if (Encrypted_Actors > 0)
            return Encrypted_Actors ^ 0xCDCD00;
    }
    return 0;
}

#pragma mark - 游戏数据
static long GetWorldPtr() {
    const auto function_address = reinterpret_cast<void*>(GetRealOffset(kUWorld));
    if (function_address) {
        long world = 0;
        return reinterpret_cast<long(__fastcall*)(long*)>(function_address)(&world);
    }
    return 0;
}

static long GetGnamePtr() {
    const auto function_address = reinterpret_cast<void*>(GetRealOffset(kGNames));
    if (function_address) {
        long gname = 0;
        return reinterpret_cast<long(__fastcall*)(long*)>(function_address)(&gname);
    }
    return 0;
}



static FVector GetBonePos(long actor, const struct FName BoneName) {
    const auto function_address = reinterpret_cast<void*>(GetRealOffset(kBonePos));
    if (function_address) {
        return reinterpret_cast<FVector(__fastcall*)(long, const struct FName, const struct FVector)>(function_address)(actor, BoneName, FVector());
    }
    return FVector();
}

static string vm_str(long address, int max_len) {
    std::vector<char> chars(max_len);
    if (!Read_data(address, max_len, chars.data()))
        return "";

    std::string str = "";
    for (int i = 0; i < chars.size(); i++)
    {
        if (chars[i] == '\0')
            break;
        str.push_back(chars[i]);
    }

    chars.clear();
    chars.shrink_to_fit();

    if ((int)str[0] == 0 && str.size() == 1)
        return "";

    return str;
}

static string GetNameByID(uint32_t index) {
    static std::map<uint32_t, std::string> namesCachedMap;
    if (namesCachedMap.count(index) > 0) return namesCachedMap[index];
    std::string name = "";
    
    uint32_t ElementsPerChunk = 16384;
    uint32_t ChunkIndex = index / ElementsPerChunk;
    uint32_t WithinChunkIndex = index % ElementsPerChunk;
    uint8_t *FNameEntryArray = Read<uint8_t *>(UName + ChunkIndex * sizeof(uintptr_t));
    if (!FNameEntryArray) return name;
    
    uint8_t *FNameEntryPtr = Read<uint8_t *>((uintptr_t)FNameEntryArray + WithinChunkIndex * sizeof(uintptr_t));
    if (!FNameEntryPtr) return name;
    
    int32_t name_index = 0;
    if (!Read_data((long)FNameEntryPtr, (sizeof(int32_t) || (name_index & 0x1)), &name_index))return name;
    
    name = vm_str((long)FNameEntryPtr + 0xC, 0xff);
    namesCachedMap[index] = name;
    return name;
}

static string GetFName(long actor) {
    UInt32 FNameID = Read<UInt32>(actor + 0x18);
    if (FNameID < 0 || FNameID >= 2000000) return "";
    if (IsValidAddress(UName)) return GetNameByID(FNameID);
    return "";
}



static string GetPlayerName(long player) {
#if 0
    long PlayerName = Read<long>(player + I64(kPlayerName));
    int length = Read<int>(player + I64(kPlayerName) + 0x8);
    if (length > 32) return "";
    char Name [128];
    FString::UnicodeToUTF_8(Name, (wchar_t*)PlayerName, length);
    return string(Name);
#else
    string n = "";
    long PlayerName = Read<long>(player + I64(kPlayerName));
    if (IsValidAddress(PlayerName)) {
        UTF8 name[32] = "";
        UTF16 buf16[16] = {0};
        Read_data(PlayerName, 28, buf16);
        Utf16_To_Utf8(buf16, name, 28, strictConversion);
        n = string((const char *)name);
    }
    return n;
#endif
}
//
static FVector GetRelativeLocation2(long actor) {

    return Read<FVector>(Read<long>(actor + I64("0x1B0") + I64("0x184")));

}
static FVector GetRelativeLocation(long actor) {
#if 1
    return Read<FVector>(Read<long>(actor + I64(kRootComponent)) + I64("0x1C0"));
#else
    return Read<FVector>(Read<long>(actor + I64(kRootComponent)) + I64(kRelativeLocation));
#endif
}
static string CameraManagerClassName ,PlayerControllerClassName;
static bool (*LineOfSightTo)(void *controller, void *actor, FVector bone_point, bool ischeck);
static bool GetLineOfSightTo(long player, FVector BonePoint) {
    if (PlayerController <= 0) return 0;
    
    int LineTraceData[100] = {0};
    long IDLineOfSight = Read<long>(GetRealOffset(kLineOfSight_1));
    
    long Hit = GetRealOffset(kLineOfSight_2);
    FVector CameraCache = Read<FVector>(PlayerCameraManager + I64(kCameraCache) + 0x10);
    
    reinterpret_cast<void(__fastcall*)(long, long, long, long, long)> (GetRealOffset(kLineOfSight_3))((long)&LineTraceData[0], IDLineOfSight, (long)&LineTraceData[40], 1, Character);
    
    reinterpret_cast<void(__fastcall*)(long, long)> (GetRealOffset(kLineOfSight_4))((long)&LineTraceData[0], player);
    
    int ret = reinterpret_cast<int(__fastcall*)(long, FVector*, FVector*, long, long, long)>(GetRealOffset(kLineOfSight_5))(GWorld, &CameraCache, &BonePoint, 3, (long)&LineTraceData[0], Hit);
    
    return (ret&0x1) == 0;
}
static FVector WorldToRadar(float Yaw, FVector Origin, FVector LocalOrigin, float PosX, float PosY, FVector Size, bool& outbuff) {
    bool flag = false;
    double num = (double)Yaw;
    double num2 = num * 0.017453292519943295;
    float num3 = (float)cosl(num2);
    float num4 = (float)sin(num2);
    float num5 = Origin.x - LocalOrigin.x;
    float num6 = Origin.y - LocalOrigin.y;

    FVector vector;
    vector.x = (num6 * num3 - num5 * num4) / 150.f;
    vector.y = (num5 * num3 + num6 * num4) / 150.f;

    FVector vector2;
    vector2.x = vector.x + PosX + Size.x / 2.f;
    vector2.y = -vector.y + PosY + Size.y / 2.f;

    bool flag2 = vector2.x > PosX + Size.x;
    if (flag2) {
        vector2.x = PosX + Size.x;
    } else {
        bool flag3 = vector2.x < PosX;
        if (flag3) {
            vector2.x = PosX;
        }
    }
    bool flag4 = vector2.y > PosY + Size.y;
    if (flag4) {
        vector2.y = PosY + Size.y;
    } else {
        bool flag5 = vector2.y < PosY;
        if (flag5) {
            vector2.y = PosY;
        }
    }
    bool flag6 = vector2.y == PosY || vector2.x == PosX;
    if (flag6) {
        flag = true;
    }
    outbuff = flag;
    return vector2;
}

static string GetClassName(int FNameID) {
    char *buf = (char *)malloc(64);
   long UName =GetGnamePtr();
    if (FNameID > 0 && FNameID < 2000000) {
        int page = FNameID / 16384;
        int index = FNameID % 16384;
        if (IsValidAddress(UName)) {
            uintptr_t pageAddr = Read<long>(UName + page * sizeof(uintptr_t));
            uintptr_t nameAddr = Read<long>(pageAddr + index * sizeof(uintptr_t)) + 0xC;
            Read_data(nameAddr, 64, buf);
        }
    }
    return buf;
}
static void GetModuleBaseAddress() {
    GWorld = GetWorldPtr();
    UName  = GetGnamePtr();
    Engine = Read<long>(GetRealOffset(kEngine));
    if (!IsValidAddress(GWorld) || !IsValidAddress(UName) || !IsValidAddress(Engine)) return;
    
    PersistentLevel = Read<long>(GWorld + I64(kPersistentLevel));
    if (!IsValidAddress(PersistentLevel)) return;
    
    long NetDriver = Read<long>(GWorld + I64(kNetDriver));//38
    if (!IsValidAddress(NetDriver)) return;
    
    long ServerConnection = Read<long>(NetDriver + I64(kServerConnection));//78
    if (!IsValidAddress(ServerConnection)) return;
    
    
    PlayerController = Read<long>(ServerConnection + I64(kPlayerController));
    if (!IsValidAddress(PlayerController)) PlayerController = Read<long>(ServerConnection + I64(klocalPlayerController));
    if (!IsValidAddress(PlayerController)) return;
    

    
    Character = Read<long>(PlayerController + I64(kPawn));
    
    PlayerCameraManager = Read<long>(PlayerController + I64(kPlayerCameraManager));
    if (!IsValidAddress(PlayerCameraManager)) return;
    
    ControlRotation = PlayerController + I64(kControlRotation);
    
    MyHUD = Read<long>(PlayerController + I64(kMyHUD));
    if (!IsValidAddress(MyHUD)) return;
    
    MyTeam = (int)Read<long>(PlayerController + I64(kMyTeam));
    CameraCache = Read<FVector>(PlayerCameraManager + I64(kCameraCache) + 0x10);
    POV = Read<MinimalViewInfo>(PlayerCameraManager + I64(kViewTarget) + 0x10);
    
    
    
    
}
static void (*AddControllerYawInput)(void *actot, float val);

//旋转
static void (*AddControllerRollInput)(void *actot, float val);

//移动Y轴
static void (*AddControllerPitchInput)(void *actot, float val);

static bool enabledAimbot = false;
static float get3dDistance(FVector self, FVector object, float divice) {
    FVector xyz;
    xyz.x = self.x - object.x;
    xyz.y = self.y - object.y;
    xyz.z = self.z - object.z;
    return sqrt(pow(xyz.x, 2) + pow(xyz.y, 2) + pow(xyz.z, 2)) / divice;
}
static FVector2D rotateAngleView(FVector selfCoord, FVector targetCoord) {
    
    float osx = targetCoord.x - selfCoord.x;
    float osy = targetCoord.y- selfCoord.y;
    float osz = targetCoord.z - selfCoord.z;
    
    return {(float) (atan2(osy, osx) * 180 / M_PI), (float) (atan2(osz, sqrt(osx * osx + osy * osy)) * 180 / M_PI)};
}
int 自瞄模式= 0;
static FVector aimObjInfo;
static float getAngleDifference(float angle1, float angle2) {
    float diff = fmod(angle2 - angle1 + 180, 360) - 180;
    return diff < -180 ? diff + 360 : diff;
}
static float change(float num) {
    if (num < 0) {
        return abs(num);
    } else if (num > 0) {
        return num - num * 2;
    }
    return num;
}
bool isHookAngle = false;
static FRotator ToRotator(const FVector &local, const FVector &target) {
    FVector rotation = local - target;
    float hyp = sqrt(rotation.x * rotation.x + rotation.y * rotation.y);
    FRotator newViewAngle;
    
    newViewAngle.Pitch = -atan(rotation.z / hyp) * (180.f / (float) 3.14159265358979323846);
    newViewAngle.Yaw = atan(rotation.y / rotation.x) * (180.f / (float) 3.14159265358979323846);
    newViewAngle.Roll = (float) 0.f;
    if (rotation.x >= 0.f)
        newViewAngle.Yaw += 180.0f;
    return newViewAngle;
}

// 追踪算法
static Tracking bulletTrack(FVector MyLoc, bool isCusimg) {
    FRotator aim_angle;
    Tracking trackData;
    //自己位置
    FVector MyLocation;
    if (isCusimg) {
        MyLocation = MyLoc;
    } else {
        MyLocation = POV.Location;
    }
    
    FRotator TargetRot = ToRotator({MyLocation.x, MyLocation.y, MyLocation.z}, {aimObjInfo.x, aimObjInfo.y, aimObjInfo.z});
    trackData.aim_angle = {TargetRot.Pitch,TargetRot.Yaw,0};
    
    return trackData;
}

//追踪函数原型
void (*UpdateVolleyShootParameters)(void *shootWeaponAddr, FVector TargetLoc, FVector* StartLoc, Rotator* BulletRot, FVector* BulletDir);

void NewBulletTracking(void *shootWeaponAddr,FVector TargetLoc, FVector* StartLoc, Rotator* BulletRot, FVector* BulletDir) {
    if (isHookAngle) {
        Tracking angle = bulletTrack(*StartLoc, true);
        BulletRot->x = angle.aim_angle.x;
        BulletRot->y = angle.aim_angle.y;
    }
    return UpdateVolleyShootParameters(shootWeaponAddr, TargetLoc, StartLoc, BulletRot, BulletDir);
}
bool intaa1=NO;
static void SetControlRotation(long Object,  FVector AimPos) {
    float Health = Read<float>(Object + I64("0xdc0"));
    long  WeaponManagerComponent =Read<long>(Character+ 0x2328);//CharacterWeaponManagerComponent* WeaponManagerComponent;
    long  CurrentWeaponReplicated = Read<long>(WeaponManagerComponent +  0x558);//STExtraWeapon* CurrentWeaponReplicated;
    long  ShootWeaponEntityComp = Read<long>(CurrentWeaponReplicated +  0x1038);
 //   int  ShootMode = Read<int>(CurrentWeaponReplicated + I64("0xED0"));
    
    
    bool bIsWeaponFiring = Read<bool>(Character +0x1650);
    
    bool bIsGunADS = Read<bool>(Character + 0x1050);
     
    if(bIsGunADS||bIsWeaponFiring){
        long RootComponent = Read<long>(Object + I64("0x1B0"));
        if (!IsValidAddress(RootComponent)) return;
        long selfFunction = Read<long>(Character + 0);
        
        // 函数偏移
         AddControllerYawInput = (void (*)(void *, float)) (Read<long>(selfFunction + I64("0x868")));
         AddControllerRollInput = (void (*)(void *, float)) (Read<long>(selfFunction + I64("0x870")));
         AddControllerPitchInput = (void (*)(void *, float)) (Read<long>(selfFunction + I64("0x860")));
         
         
         long ControlRotation = PlayerController + I64("0x468");
       
        
      
        // 子弹飞行时间
         float BulletFireSpeed = Read<float>(ShootWeaponEntityComp +I64("0x508"));
         float secFlyTime = get3dDistance(POV.Location, AimPos, BulletFireSpeed) * 1.2;
         
         FVector Velocity;
         long CurrentVehicle = Read<long>(Object + I64("0xe08"));//判断是否开车//STExtraVehicleBase* CurrentVehicle;
         if (IsValidAddress(CurrentVehicle)) {
             FVector LinearVelocity = Read<FVector>(CurrentVehicle + I64("0xB0"));//载具向量//RepMovement ReplicatedMovement;
             Velocity = LinearVelocity;
         } else {
             FVector ComponentVelocity = Read<FVector>(RootComponent + I64("0x260"));//人物向量
             //Vector ComponentVelocity;
             Velocity = ComponentVelocity;
         }
         
         AimPos.x += Velocity.x * secFlyTime;
         AimPos.y += Velocity.y * secFlyTime;
         AimPos.z += Velocity.z * secFlyTime;
         string className = GetClassName(Read<int>(ShootWeaponEntityComp +0x18));
         FVector2D aimbotMouse = rotateAngleView(POV.Location, AimPos);
        float ScopeFov = Read<float>(Character + I64("0x1a84"));
        if (Read<int>(Character + I64("0x1650")) == 1) {
             //枪械压枪幅度
             float recoil = Read<float>(ShootWeaponEntityComp + I64("0xc58"));
             float recoilTimes = 4.5 - get3dDistance(POV.Location, AimPos, 10000);
             recoilTimes += get3dDistance(POV.Location, AimPos, 10000) * 0.2;
              if (strstr(className.c_str(), "BP_Rifle_M416_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     }else if (strstr(className.c_str(), "BP_Rifle_SCAR_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_QBZ_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_VAL_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_G36_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_AUG_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.25; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.45; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.57; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.67; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.8; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_Groza_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.35; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.55; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.7; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.8; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.9; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_AKM_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.35; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.55; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.7; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.8; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.9; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_HoneyBadger_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.35; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.55; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.7; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.8; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.9; //六倍
                                         }
                                     } else if (strstr(className.c_str(), "BP_Rifle_M762_C") != 0) {
                                         if (ScopeFov > 75 && ScopeFov <= 130){
                                             recoil = 0; //不开镜
                                         }else if (ScopeFov == 70 || ScopeFov == 75){
                                             recoil = 0.35; //机瞄
                                         }else if (ScopeFov >= 55 && ScopeFov <= 56){
                                             recoil = 0.35; //红点
                                         }else if (ScopeFov >= 44 && ScopeFov <= 45){
                                             recoil = 0.55; //二倍
                                         }else if (ScopeFov >= 26 && ScopeFov <= 27){
                                             recoil = 0.7; //三倍
                                         }else if (ScopeFov >= 20 && ScopeFov <= 21){
                                             recoil = 0.8; //四倍
                                         }else if (ScopeFov >= 13 && ScopeFov <= 14){
                                             recoil = 0.9; //六倍
                                         }
                                     }
             aimbotMouse.y -= recoilTimes * recoil;
         }
         if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) {
             return;
         }
         FVector2D aimbotMouseMove;
         
         aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, Read<float>(ControlRotation + 0x4)) * 自瞄速度);
         aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, Read<float>(ControlRotation)) *自瞄速度);
         
         if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) {
             return;
         }
        if(自瞄开关){
           if (倒地不瞄 == YES && Health == 0) {
                           return;
           }else {
                 if (AddControllerYawInput != NULL) {
                     AddControllerYawInput(reinterpret_cast<void *>(Character), aimbotMouseMove.x);
                 }
                 if (AddControllerPitchInput != NULL) {
                     AddControllerPitchInput(reinterpret_cast<void *>(Character), aimbotMouseMove.y);
                 }
                 if (AddControllerRollInput != NULL) {
                     AddControllerRollInput(reinterpret_cast<void *>(Character), 0);
                 }
           }
        }
     }
    bool bIsPressingFireBtn = Read<int>(Character + I64(kbIsWeaponFiring)) == 1;
  

    
  
    
    long OwnerShootWeapon = Read<long>(Character + 0x2328);
    long CurrentWeaponReplicated1 = Read<long>(OwnerShootWeapon + 0x558);
    long ShootWeaponComponent1 = Read<long>(CurrentWeaponReplicated1 + 0xeb0);
    if (追踪开关) {
    if (AimPos.x != 0 && AimPos.y != 0 && AimPos.z != 0 < (Aimbot_Circle_Radius)) {
       
          
            if (bIsPressingFireBtn || bIsGunADS || 静默开关) {

                    if (ShootWeaponEntityComp) {
                        
                        aimObjInfo = AimPos;
                        isHookAngle = true;
                        
                        uintptr_t shootWeaponVtable = Read<long>(ShootWeaponComponent1 + 0x0);
                        if (倒地不瞄 == YES && Health == 0) {
                                        return;
                                    } else {
                        if (UpdateVolleyShootParameters == nullptr) {
                            *(uintptr_t *) &UpdateVolleyShootParameters = Read<long>(shootWeaponVtable + 0x4E8);
                        }
                       
                        if (UpdateVolleyShootParameters != nullptr) {
                            *(uintptr_t *) (shootWeaponVtable + 0x4E8) = (uintptr_t)NewBulletTracking;
                        }
                    }
                }
            }
        } else {
            isHookAngle = false;
        }
    }else {
        isHookAngle = false;
    }
}
float currentAimRadius = 160;
float targetAimRadius = 160;
float transitionSpeed = 3; // 调整这个值来控制过渡的速度
static void SetAimRadius(float distance) {
    if (distance <= 1) {
        targetAimRadius = 100; // 近处目标的视觉范围较大
    } else if (distance >= 160) {
        targetAimRadius = 100; // 远处目标的视觉范围较小
    } else {
//        float t = (distance - 1) / (40 - 1);
//        targetAimRadius = 200 - t * (160 - 15); // 在0米到40米之间线性插值
    }
    
    if (currentAimRadius != targetAimRadius) {


        // 根据过渡速度调整半径
        float step = transitionSpeed;
        if (currentAimRadius < targetAimRadius) {
            currentAimRadius = fmin(currentAimRadius + step, targetAimRadius);
        } else {
            currentAimRadius = fmax(currentAimRadius - step, targetAimRadius);
        }
        Aimbot_Circle_Radius = currentAimRadius;
        
        
        
        
                                  
                            
                        
        
        
    }
}
static void GetPlayerBone(long player, bool bIsAI, FVector* hitPoint_world, FVector2D* hitPoint_screen, FVector2D* root_screen,float distance) {
    

        
        FName BoneID[18] = {
            "Head", "neck_01", "spine_03", "spine_02", "spine_01", "pelvis",
            "upperarm_r", "lowerarm_r", "hand_r",
            "upperarm_l", "lowerarm_l", "hand_l",
            "thigh_r", "calf_r", "foot_r",
            "thigh_l", "calf_l", "foot_l"
        };
        /// 骨骼点
        bool Visible[18];
        FVector2D Bones[18];
        FVector Hitpart[18];
        FVector2D rootScreen = WorldToScreen(GetBonePos(player, FName("Root")), POV);
        root_screen->x = rootScreen.x;
        root_screen->y = rootScreen.y;
  
        
    for (int i = 0; i < 18; i++) {

                FVector boneWorldLocation = GetBonePos(player, BoneID[i]);
                Hitpart[i] = boneWorldLocation;
        Visible[i] = GetLineOfSightTo(player, boneWorldLocation);
                Bones[i] = WorldToScreen(boneWorldLocation, POV);
            }
     
    if(骨骼开关){
        DrawLine(FVector2D(Bones[1].x, Bones[1].y), FVector2D(Bones[2].x, Bones[2].y), BoneColos(Visible[1], Visible[2], bIsAI));
        DrawLine(FVector2D(Bones[2].x, Bones[2].y), FVector2D(Bones[3].x, Bones[3].y), BoneColos(Visible[2], Visible[3], bIsAI));
        DrawLine(FVector2D(Bones[3].x, Bones[3].y), FVector2D(Bones[4].x, Bones[4].y), BoneColos(Visible[3], Visible[4], bIsAI));
        DrawLine(FVector2D(Bones[4].x, Bones[4].y), FVector2D(Bones[5].x, Bones[5].y), BoneColos(Visible[4], Visible[5], bIsAI));
        
        DrawLine(FVector2D(Bones[1].x, Bones[1].y), FVector2D(Bones[6].x, Bones[6].y), BoneColos(Visible[1], Visible[6], bIsAI));
        DrawLine(FVector2D(Bones[6].x, Bones[6].y), FVector2D(Bones[7].x, Bones[7].y), BoneColos(Visible[6], Visible[7], bIsAI));
        DrawLine(FVector2D(Bones[7].x, Bones[7].y), FVector2D(Bones[8].x, Bones[8].y), BoneColos(Visible[7], Visible[8], bIsAI));
        
        DrawLine(FVector2D(Bones[1].x, Bones[1].y), FVector2D(Bones[9].x, Bones[9].y), BoneColos(Visible[1], Visible[9], bIsAI));
        DrawLine(FVector2D(Bones[9].x, Bones[9].y), FVector2D(Bones[10].x,Bones[10].y),BoneColos(Visible[9], Visible[10], bIsAI));
        DrawLine(FVector2D(Bones[10].x,Bones[10].y),FVector2D(Bones[11].x,Bones[11].y),BoneColos(Visible[10], Visible[11],bIsAI));
        
        DrawLine(FVector2D(Bones[5].x, Bones[5].y),  FVector2D(Bones[12].x,Bones[12].y),BoneColos(Visible[5], Visible[12], bIsAI));
        DrawLine(FVector2D(Bones[12].x,Bones[12].y),FVector2D(Bones[13].x,Bones[13].y),BoneColos(Visible[12], Visible[13], bIsAI));
        DrawLine(FVector2D(Bones[13].x,Bones[13].y),FVector2D(Bones[14].x,Bones[14].y),BoneColos(Visible[13], Visible[14], bIsAI));
        
        DrawLine(FVector2D(Bones[5].x, Bones[5].y), FVector2D(Bones[15].x, Bones[15].y), BoneColos(Visible[5], Visible[15], bIsAI));
        DrawLine(FVector2D(Bones[15].x,Bones[15].y), FVector2D(Bones[16].x,Bones[16].y), BoneColos(Visible[15], Visible[16], bIsAI));
        DrawLine(FVector2D(Bones[16].x,Bones[16].y), FVector2D(Bones[17].x,Bones[17].y), BoneColos(Visible[16], Visible[17], bIsAI));
    }
    switch (自瞄部位) {
        case 0:{
            for (int i = 0; i < 18; i++) {
                if (Visible[i]) {
                    if (intaa1) {
                        hitPoint_screen->x = Bones[i].x;
                        hitPoint_screen->y = Bones[i].y;
                      
                    } else {
                        // 其它枪 / 按順序攻击其它部位
                        if (Visible[0] && Visible[1] && Visible[2]) {
                            hitPoint_screen->x = Bones[i].x;
                            hitPoint_screen->y = Bones[i].y;
                            
                            hitPoint_world->x = Hitpart[i].x;
                            hitPoint_world->y = Hitpart[i].y;
                            hitPoint_world->z = Hitpart[i].z;
                            
                        }else if (Visible[0] && Visible[1]) {
                            hitPoint_screen->x = Bones[1].x;
                            hitPoint_screen->y = Bones[1].y;
                            hitPoint_world->x = Hitpart[1].x;
                            hitPoint_world->y = Hitpart[1].y;
                            hitPoint_world->z = Hitpart[1].z;
                        }else{
                            hitPoint_screen->x = Bones[i].x;
                            hitPoint_screen->y = Bones[i].y;
                            hitPoint_world->x = Hitpart[i].x;
                            hitPoint_world->y = Hitpart[i].y;
                            hitPoint_world->z = Hitpart[i].z;
                            
                       
                        }
                    }
                    break;
                }
            }
            break;
        }
        case 1:{
            
            
        
            int randomIndex =   arc4random_uniform(18);
            FName randomBoneID = BoneID[randomIndex];
          
            
            for (int i = 0; i < 18; i++) {
                FVector boneWorldLocation = GetBonePos(player, randomBoneID);
                Hitpart[i] = boneWorldLocation;
                Visible[i] = GetLineOfSightTo(player, boneWorldLocation);
                Bones[i] = WorldToScreen(boneWorldLocation, POV);
                
               
            }
    
            for (int i = 0; i < 18; i++) {
                if (Visible[i]) {
                    if (intaa1) {
                        hitPoint_screen->x = Bones[i].x;
                        hitPoint_screen->y = Bones[i].y;
                      
                    } else {
                        // 其它枪 / 按順序攻击其它部位
                        if (Visible[0] && Visible[1] && Visible[2]) {
                            hitPoint_screen->x = Bones[i].x;
                            hitPoint_screen->y = Bones[i].y;
                            
                            hitPoint_world->x = Hitpart[i].x;
                            hitPoint_world->y = Hitpart[i].y;
                            hitPoint_world->z = Hitpart[i].z;
                            
                        }else if (Visible[0] && Visible[1]) {
                            hitPoint_screen->x = Bones[1].x;
                            hitPoint_screen->y = Bones[1].y;
                            hitPoint_world->x = Hitpart[1].x;
                            hitPoint_world->y = Hitpart[1].y;
                            hitPoint_world->z = Hitpart[1].z;
                        }else{
                            hitPoint_screen->x = Bones[i].x;
                            hitPoint_screen->y = Bones[i].y;
                            hitPoint_world->x = Hitpart[i].x;
                            hitPoint_world->y = Hitpart[i].y;
                            hitPoint_world->z = Hitpart[i].z;
                            
                       
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
            
            if (GetInsideFov(CanvasSize.x, CanvasSize.y, *hitPoint_screen, Aimbot_Circle_Radius)) {
                float tDistance = GetCenterOffsetForVector(*hitPoint_screen);
                if (tDistance <= Aimbot_Circle_Radius && tDistance < markDistance&& distance<=击打距离) {
                    needAdjustAim = true;
                    markDistance = tDistance;
                    markScreenPos = *hitPoint_screen;
                    SetControlRotation(player, *hitPoint_world);
                }
            }
          
        

            
    

    
    }
static bool ProjectWorldLocationToScreen(const struct FVector WorldLocation, bool bPlayerViewportRelative, struct FVector2D* ScreenLocation);
static bool ProjectWorldLocationToScreen(const struct FVector WorldLocation, bool bPlayerViewportRelative, struct FVector2D* ScreenLocation) {
    if (!IsValidAddress(PlayerController)) return false;
    const auto function_address = reinterpret_cast<void*>(GetRealOffset(kProjectWorldLocationToScreen));//0x106AFE29C
    if (function_address) {
        return reinterpret_cast<bool(*)(long, const struct FVector*, const struct FVector2D*, bool)>(function_address)(PlayerController, &WorldLocation, ScreenLocation, bPlayerViewportRelative);
    }
    return false;
}
static void ABoxConversion(FVector worldLocation, FVectorRect *rect) {
    FVector worldLocation2 = worldLocation;
    worldLocation2.x += 90.f;
    
    FVector2D calculate; // 计算物体坐标在屏幕上的位置
    ProjectWorldLocationToScreen(worldLocation, true, &calculate);
    FVector2D calculate2; // 计算物体坐标在屏幕上的位置
    ProjectWorldLocationToScreen(worldLocation2, true, &calculate2); // 计算矩形框左上角坐标在屏幕上的位置
    
    rect->h = calculate.x - calculate2.y;
    rect->w = rect->h / 2.5;
    rect->x = calculate.x - rect->w;
    rect->y = calculate2.x;
    rect->w = rect->w * 2;
    rect->h = rect->h * 2;
}
static void GetPlayerInfo(long player,FVector2D rootScreen, string playerName, float Health, float distance, bool isAI, int TeamID) {
    FVector LocationWorldPos = GetRelativeLocation(player);
    FVector2D LocationScreen;
    ProjectWorldLocationToScreen(LocationWorldPos, true, &LocationScreen);
    FVectorRect rect;
    BoxConversion(LocationWorldPos, &rect,POV);
    float dw = 100 * 2;
    float lineHeight =3;
    float spaceHeight = 1.0;
    float rectHeight = lineHeight * 2+ spaceHeight;
    float dx = rect.x + rect.w * 0.5 - dw * 0.5;
    float dy = rect.y- rectHeight * 2;

    
    float HealthRatio = Health / 100;
    float percent = dw * HealthRatio;
    
    if(血量开关){
    //DrawRectFilled(FVector2D(dx, dy), FVector2D(dw, rectHeight), Colour_透明石板灰);
    if (HealthRatio > 0) DrawRectFilled(FVector2D(dx, dy - 27), FVector2D(percent, 25), hong);
    //else DrawRectFilled(FVector2D(dx, dy), FVector2D(dw * HealthRatio, 4), Colour_橙黄);

    /// 矩形
    DrawRect(FVector2D(dx, dy - 25), FVector2D(dw, 27), Colour_白色, lineHeight);

    /// 4 条竖线
    float offsetX = dw / 0.0;
    for (int i = 1; i < 0; i++) {
        float tx = dx+offsetX*i;
        DrawLine(FVector2D(tx, dy), FVector2D(tx, dy+rectHeight), Colour_黑色, lineHeight);
    }
    }

    if(名字开关){
    
     

        DrawText(string_format("%.0fm", distance), FVector2D((int)rootScreen.x, (int)rootScreen.y ), Colour_白色);

    DrawText(string_format("%02d %s", TeamID, playerName.c_str()), FVector2D(rect.x + rect.w/2, rect.y-35), isAI ? Colour_白色 : Colour_黄色);
    }

}
#define IM_PI                   3.14159265358979323846f
#define RAD2DEG( x )  ( (float)(x) * (float)(180.f / IM_PI) )
#define DEG2RAD( x ) ( (float)(x) * (float)(IM_PI / 180.f) )
static void VectorAnglesRadar(FVector& forward, FVector& angles)
{
    if (forward.x == 0.f && forward.y == 0.f)
    {
        angles.x = forward.z > 0.f ? -90.f : 90.f;
        angles.x = 0.f;
    }
    else
    {
        angles.x = RAD2DEG(atan2(-forward.z, forward.Size()));
        angles.x = RAD2DEG(atan2(forward.y, forward.x));
    }
    angles.z= 0.f;
}
void FixTriangle(float& XPos, float& YPos, int screenDist){

    if(XPos > (CanvasSize.x- 100)) {
        XPos = CanvasSize.x;
        XPos -= screenDist;
    }

    if(XPos < 100) {
        XPos = 16;
        XPos += screenDist;
    }

    if(YPos > (CanvasSize.y - 100)) {
        YPos = CanvasSize.y;
        YPos -= screenDist;
    }
    if(YPos < 100) {
        YPos = 16;
        YPos += screenDist;
    }
}

static bool isScreenVisible(FVector2D LocationScreen, FVector2D CanvasSize) {
    if (LocationScreen.x > 0 && LocationScreen.y < CanvasSize.x &&
        LocationScreen.x > 0 && LocationScreen.y < CanvasSize.y) return true;
    else return false;
}
static void GetVehicleData(long vehicle, const char* name, int color) {
    long VehicleCommon = Read<long>(vehicle + I64(kVehicleCommon));
    if (!IsValidAddress(VehicleCommon)) return;
    float dw = 40;
    float lineHeight = 2.0;
    float spaceHeight = 1.0;
    float rectHeight = lineHeight * 2 + spaceHeight;
    
    // 血量
    float HP = Read<float>(VehicleCommon + I64(kHP));
    float HPMax = Read<float>(VehicleCommon + I64(kHPMax));
    float Health = HP / HPMax * 100;

    // 车油量
    float Fuel = Read<float>(VehicleCommon + I64(kFuel));
    float FuelMax = Read<float>(VehicleCommon + I64(kFuelMax));
    float Oil = Fuel / FuelMax * 100;

    float Health1 = Health / 100;
    float Oil1 = Oil / 100;

    float percent = dw * Health1;
    float percent1 = dw * Oil1;
    FVector worldLocation = GetRelativeLocation(vehicle);
    FVector2D screenLocation = WorldToScreen(worldLocation, POV);


        float distance = FVector::Distance(worldLocation, POV.Location) / 100;
        if (Health != 0 && distance > 10 && distance <= 800) {
            if (isEqual(name, "PG117") && distance > 100) return;
            if (isEqual(name, "Kayak") && distance > 100) return;
            DrawText(string_format("%s[%.0fM]", name, distance), FVector2D(screenLocation.x, screenLocation.y), color ,13);
          

        
    }
}
static void GetSuppliesData(long Object, const char* name, int color) {

    FVector worldLocation = GetRelativeLocation(Object);
    FVector2D screenLocation = WorldToScreen(worldLocation, POV);
    
   
        float distance = FVector::Distance(worldLocation, POV.Location) / 100;
        if (isEqual(name, "Player Box") && distance > 80) return;
        if (distance > 2 && distance <= 物资距离) {
            DrawText(string_format("%s[%.0fM]", name, distance), screenLocation, color ,13);
        }
    
}
static void DrawUnclosedRect(float center_x, float center_y, float center_w, float center_h, float thickness, int color) {
    // Calculate distance from center to edges
    float halfWidth = center_w / 2;
    float halfHeight = center_h / 2;

    // Top-left horizontal line
    DrawLine(FVector2D(center_x - halfWidth, center_y - halfHeight), FVector2D(center_x - halfWidth / 2, center_y - halfHeight), color, thickness);
    // Top-right horizontal line
    DrawLine(FVector2D(center_x + halfWidth, center_y - halfHeight), FVector2D(center_x + halfWidth / 2, center_y - halfHeight), color, thickness);
    // Bottom-left horizontal line
    DrawLine(FVector2D(center_x - halfWidth, center_y + halfHeight), FVector2D(center_x - halfWidth / 2, center_y + halfHeight), color, thickness);
    // Bottom-right horizontal line
    DrawLine(FVector2D(center_x + halfWidth, center_y + halfHeight), FVector2D(center_x + halfWidth / 2, center_y + halfHeight), color, thickness);

    // Top-left vertical line
    DrawLine(FVector2D(center_x - halfWidth, center_y - halfHeight), FVector2D(center_x - halfWidth, center_y - halfHeight / 2), color, thickness);
    // Top-right vertical line
    DrawLine(FVector2D(center_x + halfWidth, center_y - halfHeight), FVector2D(center_x + halfWidth, center_y - halfHeight / 2), color, thickness);
    // Bottom-left vertical line
    DrawLine(FVector2D(center_x - halfWidth, center_y + halfHeight), FVector2D(center_x - halfWidth, center_y + halfHeight / 2), color, thickness);
    // Bottom-right vertical line
    DrawLine(FVector2D(center_x + halfWidth, center_y + halfHeight), FVector2D(center_x + halfWidth, center_y + halfHeight / 2), color, thickness);
}

    
void GetPlyaerData(long GWorld,long player) {
    if (player == Character) return;
    
    long RootComponent = Read<long>(player + I64(kRootComponent));
    if (!IsValidAddress(RootComponent)) return;
    
    /// 判断死亡
    bool bDead = Read<bool>(player + I64(kbDead)) & 1;
    if (bDead) return;
    
    /// 团队号
    int TeamID = Read<int>(player + I64(kTeamID));
    if (TeamID == MyTeam) return;
    
    /// 世界坐标
    FVector LocationWorldPos = GetRelativeLocation(player);
    FVector2D LocationScreen = WorldToScreen(LocationWorldPos, POV);
    
    FVector2D width = WorldToScreen(FVector(LocationWorldPos.x,LocationWorldPos.y,LocationWorldPos.z + 100), POV);
    FVector2D height = WorldToScreen(FVector(LocationWorldPos.x,LocationWorldPos.y,LocationWorldPos.z + 100),POV);
    
    FVector2D Playersize;
    Playersize.x = (LocationScreen.y - width.y) / 2;
    Playersize.y = LocationScreen.y - height.y;
    
    /// 距离
    float distance = FVector::Distance(LocationWorldPos, POV.Location) / 100;
    if (distance > 600) return;
    
    /// 血量
    float Health = Read<float>(player + I64(kHealth));
    float HealthMax = Read<float>(player + I64(kHealthMax));
    
    /// 判断人机
    bool bIsAI = true;
    bIsAI = Read<bool>(player + I64(kbIsAI)) != 0;
    if(屏蔽人机){
        if(bIsAI){
            return;
            
        }
    }
if ( !bIsAI ) { totalEnemies++; } 
if ( bIsAI ) { robotcounts++;}

    //敌人数量统计 
    FVectorRect rect;
    BoxConversion(LocationWorldPos, &rect,POV);
   
 

    if(框架开关){
        //NSLog(@"开启了方框");
        DrawUnclosedRect(LocationScreen.x, LocationScreen.y, Playersize.x + Playersize.x, Playersize.y + Playersize.y, 1.0,Colour_绿色);
//    DrawUnclosedRect(LocationWorldPos.x, LocationWorldPos.y, Playersize.x + Playersize.x, Playersize.x + Playersize.y,Colour_绿色);
    }
    FVector HeadWorldLocation = GetBonePos(player, "Head"); // GetBoneWithRotation(Mesh, 6);
    bool HeadSight = GetLineOfSightTo(player, HeadWorldLocation);
    
        /// 人物骨骼
        FVector hitPoint_world;
        FVector2D hitPoint_screen, root_screen;
        GetPlayerBone(player, bIsAI, &hitPoint_world, &hitPoint_screen, &root_screen,distance);
        
        //
    
    GetPlayerInfo(player, root_screen,  GetPlayerName(player), Health / HealthMax * 100, distance, bIsAI, TeamID);
   
    
    if(射线开关){
         DrawLine(FVector2D(CanvasSize.x/2, 10), FVector2D(rect.x + rect.w * 0.5, rect.y - 38), HeadLineColor(bIsAI, HeadSight));
    }
}
bool 框架开关=NO;
static void DrawRectFilled(FVector2D pos, float w, float h, int color) {
    for (float i = 0.f; i < h; i += 1.f)
        DrawLine(FVector2D(pos.x, pos.y + i), FVector2D(pos.x+ w, pos.y + i), 1.f, color);
}
static void Draw2DPlaneCircle(FVector center, float radius, int color) {
    int numSegments = 360; // 圆上的分段数

    for (int i = 0; i < numSegments; i++) {
        float angle1 = (i / (float)numSegments) * 2 * M_PI;
        float angle2 = ((i + 1) / (float)numSegments) * 2 * M_PI;

        FVector p1 = center + FVector(radius * cos(angle1), radius * sin(angle1), 0);
        FVector p2 = center + FVector(radius * cos(angle2), radius * sin(angle2), 0);
        FVector2D p33, p44;
        ProjectWorldLocationToScreen(p1, true, &p33);
        ProjectWorldLocationToScreen(p2, true, &p44);
        DrawLine(p33,p44, 1, color);
    }
}

static void GetThrowData(long Object,const char* name) {

    FVector worldLocation = GetRelativeLocation(Object);
    FVector2D screenLocation;
    ProjectWorldLocationToScreen(worldLocation, true, &screenLocation);

    float distance = FVector::Distance(worldLocation, POV.Location) / 100;
    if (distance < 500.f) {
        DrawCircleFilled(screenLocation,15,Colour_透明红色);
        DrawText(string_format("%s %.f",name,distance), FVector2D(screenLocation.x-1,screenLocation.y-9),Colour_白色);
        DrawTitle(string_format("Can than bom!!!!(%.fm)",distance), FVector2D(CanvasSize.x/2, CanvasSize.y*0.08f+70), Colour_红色);

    }
}
static void Draw3DBox(FVector origin, FVector extends, int color) {
    origin -= extends / 2;

    FVector one = origin;
    FVector two = origin;   two.x += extends.x;
    FVector three = origin; three.x += extends.x; three.y += extends.y;
    FVector four = origin;  four.y += extends.y;

    FVector five = one;     five.z += extends.z;
    FVector six = two;      six.z += extends.z;
    FVector seven = three;  seven.z += extends.z;
    FVector eight = four;   eight.z += extends.z;

    FVector2D s1, s2, s3, s4, s5, s6, s7, s8;

    ProjectWorldLocationToScreen(one, true, &s1);
    ProjectWorldLocationToScreen(two, true, &s2);
    ProjectWorldLocationToScreen(three, true, &s3);
    ProjectWorldLocationToScreen(four, true, &s4);
    ProjectWorldLocationToScreen(five, true, &s5);
    ProjectWorldLocationToScreen(six, true, &s6);
    ProjectWorldLocationToScreen(seven, true, &s7);
    ProjectWorldLocationToScreen(eight, true, &s8);

//    DrawLine(s1, s2, 1, color);
//    DrawLine(s2, s3, 1, color);
//    DrawLine(s3, s4, 1, color);
//    DrawLine(s4, s1, 1, color);
//
//    DrawLine(s5, s6, 1, color);
//    DrawLine(s6, s7, 1, color);
//    DrawLine(s7, s8, 1, color);
//    DrawLine(s8, s5, 1, color);
//
//    DrawLine(s1, s5, 1, color);
//    DrawLine(s2, s6, 1, color);
//    DrawLine(s3, s7, 1, color);
//    DrawLine(s4, s8, 1, color);
    DrawLine(s1, s2, color, 1);
    DrawLine(s2, s3, color, 1);
    DrawLine(s3, s4, color, 1);
    DrawLine(s4, s1, color, 1);

    DrawLine(s5, s6, color, 1);
    DrawLine(s6, s7, color, 1);
    DrawLine(s7, s8, color, 1);
    DrawLine(s8, s5, color, 1);

    DrawLine(s1, s5, color, 1);
    DrawLine(s2, s6, color, 1);
    DrawLine(s3, s7, color, 1);
    DrawLine(s4, s8, color, 1);

}
static void GetData(long Object,  const char* name, int color) {

    FVector worldLocation = GetRelativeLocation(Object);
    FVector2D screenLocation;

    if (ProjectWorldLocationToScreen(worldLocation, true, &screenLocation) && isScreenVisible(screenLocation, FVector2D(CanvasSize.x, CanvasSize.y))) { // 屏幕内
        float distance = FVector::Distance(worldLocation, POV.Location) / 100;
        if (distance < 700.f) {

            FVector extends = FVector(75, 50, 30);
            Draw3DBox(worldLocation, extends, Colour_珊瑚红);

            DrawText(string_format("%s[%.0fM]", name, distance), screenLocation, color ,13);
//            DrawText(name, screenLocation, color ,13);

        }
    }
}
static void GetActors() {
    
    // 重置数据
    isHookAngle = false;
    totalEnemies = 0; 
    robotcounts = 0;
    pickItemCount = 0;
    tDistance = 0;
    needAdjustAim = false;
    markDistance = CanvasSize.x;
    markScreenPos = FVector2D(CanvasSize.x/2, CanvasSize.y/2);
    
    
    long GWorld = GetWorldPtr();
    if (!IsValidAddress(GWorld)) return;
    
    
    auto ActorsPointerAddress = DecryptActorsArray(PersistentLevel, 0xA0, 0x448);//--Actors
    if (!ActorsPointerAddress) ActorsPointerAddress = DecryptActorsArray(PersistentLevel, 0xB0, 0x488);//--ActorsForGC
    if (!ActorsPointerAddress) return;
    
    long ActorArray = Read<uint64_t>(ActorsPointerAddress);
    int ActorCount = Read<int>(ActorsPointerAddress + 0x8);
    
        
    if (ActorCount > 0 && ActorCount < 50000) {
        for (int i = 0; i < ActorCount; i++) {
            long actor = Read<long>(ActorArray + i * 8);
            
            string FName = GetFName(actor);
            if (FName.empty()) continue;
            
            if (isContain(FName, "PlayerPawn") ||
                isContain(FName, "PlayerCharacter") ||
                isContain(FName, "PlayerControllertSl") ||
                isContain(FName, "_PlayerPawn_TPlanAI_C") ||
                isContain(FName, "CharacterModelTaget")||
                isContain(FName, "FakePlayer_AIPawn")) GetPlyaerData(GWorld,actor);
                if(显示盒子){
                if (isContain(FName, "PlayerDeadListWrapper") || isContain(FName, "TrainingBoxList")|| isContain(FName, "CharacterDeadInventoryBox")) GetSuppliesData(actor,"Hom Xac",Colour_绿色);
                }
                if (药品开关) {

                    if (isContain(FName , "FirstAidbox")) GetSuppliesData(actor,"Medkit",Colour_黄色);
                    if (isContain(FName , "Firstaid")) GetSuppliesData(actor,"First Aid",Colour_黄色);

                    if (isContain(FName , "Pills")) GetSuppliesData(actor,"Paintkiller",Colour_黄色);

                    if (isContain(FName , "Drink")) GetSuppliesData(actor,"Drink",Colour_黄色);

                    if (isContain(FName , "Injection")) GetSuppliesData(actor,"Injection",Colour_黄色);
                }
                if(显示盒子){
                if (isContain(FName ,"DeadBox")){
               
                    GetData(actor,"Hom Xac",Colour_绿黄);
                }
                }
                if(投掷物预警){
                if (isContain(FName , "FragGrenade")){
                   GetThrowData(actor,"Nade");
                }
                if (isContain(FName , "BurnGrenade")){
                   GetThrowData(actor,"Bom Xang");
                }
                if (isContain(FName , "SmokeBomb")){
                   GetThrowData(actor,"Smoke");
                }
                }

                if (枪械开关) {
                    if (isContain(FName , "BP_Rifle_M416_Wrapper_C")) GetSuppliesData(actor,"M416",Colour_青色);


                    if (isContain(FName , "BP_Rifle_M16A4_Wrapper_C")) GetSuppliesData(actor,"M16A4",Colour_青色);


                    if (isContain(FName , "BP_Rifle_M762_Wrapper_C")) GetSuppliesData(actor,"M762",Colour_青色);


                    if (isContain(FName , "BP_Rifle_AKM_Wrapper_C")) GetSuppliesData(actor,"AKM",Colour_青色);


                    if (isContain(FName , "BP_Rifle_SCAR_Wrapper_C")) GetSuppliesData(actor,"SCAR",Colour_青色);


                    if (isContain(FName , "BP_Rifle_QBZ_Wrapper_C")) GetSuppliesData(actor,"QBZ",Colour_青色);


                    if (isContain(FName , "BP_Rifle_Groza_Wrapper_C")) GetSuppliesData(actor,"Groza",Colour_青色);


                    if (isContain(FName , "BP_Rifle_AUG_Wrapper_C")) GetSuppliesData(actor,"AUG",Colour_青色);


                    if (isContain(FName , "BP_Sniper_Mini14_Wrapper_C")) GetSuppliesData(actor,"Mini14",Colour_青色);


                    if (isContain(FName , "BP_Sniper_M24_Wrapper_C")) GetSuppliesData(actor,"M24",Colour_青色);


                    if (isContain(FName , "BP_Sniper_Kar98k_Wrapper_C")) GetSuppliesData(actor,"Kar98k",Colour_青色);


                    if (isContain(FName , "BP_Other_DP28_Wrapper_C")) GetSuppliesData(actor,"DP28",Colour_青色);


                    if (isContain(FName , "BP_Other_MG3_Wrapper_C")) GetSuppliesData(actor,"MG3",Colour_青色);
                    
                    
                    if (isContain(FName , "_Pistol_Flaregun_Wrapper_C")) GetSuppliesData(actor,"Sung Thinh",Colour_红色);
                    
                    
                    if (isContain (FName , "_Grenade_EmergencyCall_Weapon_Wrapper_C")) GetSuppliesData(actor,"SOS",Colour_红色);
                    
                    
                    if (isContain(FName , "_Rifle_HoneyBadger_Wrapper_C")) GetSuppliesData(actor,"Honey Badger",Colour_青色);
                    
                    
                    if (isContain(FName , "_Other_HuntingBowEA_Wrapper_C")) GetSuppliesData(actor,"Bow",Colour_青色);
                }
                
                if (配件开关) {

                    if (isContain(FName , "BurnGrenade")) GetSuppliesData(actor,"Bom Xang",Colour_浅蓝);

                    if (isContain(FName , "FragGrenade")) GetSuppliesData(actor,"Nade",Colour_浅蓝);

                    if (isContain(FName , "SmokeBomb")) GetSuppliesData(actor,"Smoke",Colour_浅蓝);

                    //弹药显示

                    if (isContain(FName , "_Ammo_556mm")) GetSuppliesData(actor,"556mm",Colour_绿色);


                    if (isContain(FName , "_Ammo_762mm")) GetSuppliesData(actor,"762mm",Colour_黄色);



                    //三级套显示


                    if (isContain(FName , "Helmet_Lv3")) GetSuppliesData(actor,"Mu3",Colour_桃红);


                    if (isContain(FName , "Armor_Lv3")) GetSuppliesData(actor,"Giap3",Colour_桃红);


                    if (isContain(FName , "Bag_Lv3")) GetSuppliesData(actor,"Balo3",Colour_桃红);


                    //倍镜显示


                    if (isContain(FName , "MZJ_3X")) GetSuppliesData(actor,"X3",Colour_浅蓝);


                    if (isContain(FName , "_MZJ_4X")) GetSuppliesData(actor,"X4",Colour_浅蓝);


                    if (isContain(FName , "_MZJ_6X")) GetSuppliesData(actor,"X6",Colour_浅蓝);


                    if (isContain(FName , "_MZJ_8X")) GetSuppliesData(actor,"X8",Colour_浅蓝);
                }
                
                if (载具开关) {
                    //车辆显示
                    if (isContain(FName, "_UTV_C")) GetVehicleData(actor, "UTV", Colour_黄色);//大蹦蹦

                    else if (isContain(FName, "_VH_Bigfoot_C")) GetVehicleData(actor, "Bigfoot", Colour_黄色);//大脚车

                    else if (isContain(FName, "Buggy")) GetVehicleData(actor, "Buggy", Colour_黄色);//蹦蹦

                    else if (isContain(FName, "UAZ")) GetVehicleData(actor, "UAZ", Colour_黄色);//吉普

                    else if (isContain(FName, "Dacia")) GetVehicleData(actor,"Dacia", Colour_黄色);//轿车

                    else if (isContain(FName, "Scooter")) GetVehicleData(actor, "Scooter", Colour_黄色);//踏板车

                    else if (isContain(FName, "Rony")) GetVehicleData(actor, "Rony", Colour_黄色);

                    else if (isContain(FName, "MiniBus")) GetVehicleData(actor, "MiniBus", Colour_黄色);//小巴士

                    else if (isContain(FName, "Snowmobile")) GetVehicleData(actor, "Snowmobile", Colour_黄色);//雪橇

                    else if (isContain(FName, "PG117")) GetVehicleData(actor, "PG117", Colour_黄色);//大船

                    else if (isContain(FName, "_Motorcycle_")) GetVehicleData(actor, "Motorcycle", Colour_黄色);//摩托
                    else if (isContain(FName, "_Snowbike_C")) GetVehicleData(actor, "Motorcycle", Colour_黄色);//摩托

                    else if (isContain(FName, "_MotorcycleCart_")) GetVehicleData(actor, "Motorcycle", Colour_黄色);//三轮摩托
                    else if (isContain(FName, "_VH_Tuk_1")) GetVehicleData(actor, "TukTuk", Colour_黄色);//三轮摩托

                    else if (isEqual(FName, "_ny_01_C")) GetVehicleData(actor, "Truck", Colour_黄色);//皮卡
                    else if (isEqual(FName, "ckUp_07_C")) GetVehicleData(actor, "Truck", Colour_黄色);//皮卡
                    else if (isContain(FName, "PickUp_0")) GetVehicleData(actor, "Truck", Colour_黄色);//皮卡

                    else if (isContain(FName, "BRDM")) GetVehicleData(actor,"BRDM", Colour_黄色);//蟑螂车

                    else if (isContain(FName, "AquaRail")) GetVehicleData(actor, "AquaRail", Colour_黄色);//摩托艇

                    else if (isContain(FName, "VH_Tank_Beta_C")) GetVehicleData(actor,  "Tank", Colour_黄色);//坦克

                    else if (isContain(FName, "rado_open") || isContain(FName, "rado_close")) GetVehicleData(actor, "Mirado", Colour_黄色);//Mirado
                    else if (isContain(FName, "Mirado")) GetVehicleData(actor, "Mirado", Colour_黄色);//Mirado
                    else if (isEqual(FName, "_CoupeRB_Base_C")) GetVehicleData(actor, "Mirado", Colour_黄色);//Mirado
                    else if (isContain(FName, "_CoupeRB_InBornlsland_C")) GetVehicleData(actor, "Mirado", Colour_黄色);//Mirado
                    else if (isEqual(FName, "_CoupeRB_1_C")) GetVehicleData(actor,"Mirado", Colour_黄色);//Mirado

                    else if (isEqual(FName, "_Motorglider_C")) GetVehicleData(actor, "Motorglider", Colour_黄色);//滑翔机

                }
            
            
            }
        }
        
    
   
    // 绘画敌人数量
    if (totalEnemies == 0|| robotcounts == 0) {
        DrawTitle(string_format(" %d",totalEnemies), FVector2D(CanvasSize.x/2, CanvasSize.y*0.17), Colour_红色,30);

}
        DrawTitle(string_format("14th08 UE4"), FVector2D(CanvasSize.x/2, CanvasSize.y*0.12f), Colour_蓝色,20);
    
    if(自瞄开关||追踪开关){

            DrawCircle(FVector2D(CanvasSize.x/2, CanvasSize.y/2), Aimbot_Circle_Radius,  Colour_浅绿);

}
}

static long GetHUD(long hud) {
    GetModuleBaseAddress();
//    NSLog(@"进来了");
    if (hud == MyHUD) {
        if (TinyFont == 0) {
            TinyFont = Read<long>(Engine + I64("0x30"));
            SmallFont = Read<long>(Engine + I64("0x70"));
            
            Write<long>(SmallFont + I64(kLegacyFontSize), 12);
            Write<long>(TinyFont + I64(kLegacyFontSize), 40);
        }
    }
    
    HUD = hud;
    Canvas = Read<long>(HUD + I64(kCanvas));
    if (IsValidAddress(Canvas)) {
        CanvasSize.x = Read<int>(Canvas + I64(kSizeX));
        CanvasSize.y = Read<int>(Canvas + I64(kSizeY));
        
        GetActors();
    }
    
    return reinterpret_cast<long(__fastcall *)(long)>(GetRealOffset(kGetHUD))(hud);
}

#pragma mark - 启动


static void __attribute__((constructor)) initialize() {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [bundle bundleIdentifier];


    if([bundleIdentifier isEqualToString:@"com.tencent.ig"]){
        kUWorld = "0x10681620c";
        kGNames = "0x1049a3510";
        hookHUD = "0x1087b1958";
        kGetHUD = "0x10339b304";
        kDrawText = "0x1064a9628";
        kDrawLine = "0x1060c8988";
        kDrawRectFilled = "0x1060c88f8";
        kDrawCircleFilled = "0x1064a9a94";
        kEngine = "0x10a8b9ee0";
        kBonePos = "0x1030fe934";
        kProjectWorldLocationToScreen= "0x1060732b0";


  }

//台湾
        if([bundleIdentifier isEqualToString:@"com.rekoo.pubgm"]){
     hookHUD = "0x10897F2E8";
     kGetHUD = "0x10351C2D4";
     kDrawText = "0x10662A5F8";
     kDrawLine = "0x106249958";
     kDrawRectFilled = "0x1062498C8";
     kDrawCircleFilled = "0x10662AA64";
     kEngine = "0x10AA76160";
     kUWorld = "0x1069971DC";
     kGNames = "0x104B244E0";
     kBonePos = "0x10327F904";
     kProjectWorldLocationToScreen= "0x1061F4280";
}

    if([bundleIdentifier isEqualToString:@"com.pubg.krmobile"]){

     hookHUD = "0x1089A72C8";

     kGetHUD = "0x1035451C8";

     kDrawText = "0x106653BA0";

     kDrawLine = "0x106272E50";

     kDrawRectFilled="0x106272DC0";



kDrawCircleFilled="0x10665400C";

     kEngine = "0x10AA9C260";

     kUWorld = "0x1069C08B0";

     kGNames = "0x104B4D444";

     kBonePos = "0x1032A87B8";

     

kProjectWorldLocationToScreen= "0x10621D764";

    }



    //越南
    if([bundleIdentifier isEqualToString:@"vn.vng.pubgmobile"]){
        hookHUD = "0x1086D4768";//
        kGetHUD = "0x1032e82d4";//
        kDrawText = "0x1063f65f8";//
        kDrawLine = "0x106015958";//
        kDrawRectFilled = "0x1060158c8";//
        kDrawCircleFilled = "0x1063f6a64";
        kEngine = "0x10a7908e0";
        kUWorld = "0x1067631dc";//
        kGNames = "0x1048f04e0";//
        kBonePos = "0x10304b904";//
        kProjectWorldLocationToScreen= "0x105fc0280";//
//印度服
    }
    if([bundleIdentifier isEqualToString:@"com.pubg.imobile"]){
        kUWorld = "0x10415D130";
        kGNames = "0x1045AA3E8";
        hookHUD = "0x107C3E730";
        kGetHUD = "0x102C88A30";
        kDrawText = "0x105B787C8";
        kDrawLine = "0x10579C538";
        kDrawRectFilled ="0x1042FDC8C";
        kDrawCircleFilled = "0x105B78C34";
        kEngine = "0x109A711B0";
        kBonePos = "0x1029FD91C";
        kProjectWorldLocationToScreen= "0x105746FD0";

    }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Write<long>(GetRealOffset(hookHUD), (long)GetHUD);
        
        FName::GNames = (TNameEntryArray *)GetGnamePtr();
        
    });
}
