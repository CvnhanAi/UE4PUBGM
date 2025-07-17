//
//  ABC.h
//  ABC
//
//  Created by ABC on 2022/11/17.
//

#ifndef ABC_hpp
#define ABC_hpp
#include <array>  // Include the array header
#include <iostream>
#include <stdio.h>
#include <cmath>
#include <string>
#include <map>
#include <vector>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include <math.h>
#include <MacTypes.h>
#include <CoreFoundation/CoreFoundation.h>
//#include "Basic.hpp"
//#include "CoreUObject_structs.hpp"
//#include "CoreUObject_classes.hpp"
//#include "CoreUObject_parameters.hpp"
//#include "Actor.hpp"
//#include "PickUpWrapper.hpp"
#include "Header.hpp"


#define __fastcall
#define Colour_浅红 0x4F0000FF
#define Colour_浅绿 0x4F00FF00
#define Colour_红色 0xFF0000FF
#define Colour_绿色 0xFF00FF00
#define Colour_粉红 0xFFCBC0FF
#define Colour_蓝色 0xFFFF0000
#define Colour_浅蓝 0xFFFACE87
#define Colour_青色 0xFFFFFF00
#define Colour_碧绿 0xFFAAFF7F
#define Colour_草绿 0xFF00FC7C
#define Colour_金色 0xFF00D7FF
#define Colour_橙黄 0x9F00A5FF
#define Colour_橙色 0xFF0066FF
#define Colour_桃红 0xFFB9DAFF
#define Colour_珊瑚红 0xFF507FFF
#define Colour_紫色 0xFFEE677A
#define Colour_石板灰 0xFF908070
#define Colour_白色 0xFFFFFFFF
#define Colour_黑色 0xFF000000
#define Colour_绿黄 0xFFADFF2F
#define Colour_黄色 0xFF00FFFF
#define Colour_透明红色 0x800000FF
#define Colour_透明橙黄 0x8000A5FF
#define Colour_透明绿黄 0x80ADFF2F
#define Colour_透明绿色 0x8000FF00
#define Colour_透明石板灰 0x80908070
#define donhat 0x9600BFFF
#define hong 0xB0FF1493
using namespace std;
//using namespace SDK;

struct FVector {
    float x;
    float y;
    float z;

    FVector() {
        this->x = 0;
        this->y = 0;
        this->z = 0;
    }

    FVector(float x, float y, float z) {
        this->x = x;
        this->y = y;
        this->z = z;
    }

    FVector operator+(const FVector &v) const {
        return FVector(x + v.x, y + v.y, z + v.z);
    }

    FVector operator-(const FVector &v) const {
        return FVector(x - v.x, y - v.y, z - v.z);
    }

    bool operator==(const FVector &v) {
        return x == v.x && y == v.y && z == v.z;
    }

    bool operator!=(const FVector &v) {
        return !(x == v.x && y == v.y && z == v.z);
    }

    FVector operator-= (const FVector &A) {
        this->x -= A.x;
        this->y -= A.y;
        this->z -= A.z;
        return *this;
    }

    FVector operator-= (const float A) {
        this->x -= A;
        this->y -= A;
        this->z -= A;
        return *this;
    }

    FVector operator/ (const float A) {
        return FVector(this->x/A, this->y/A, this->z/A);
    }

    static FVector Zero() {
        return FVector(0.0f, 0.0f, 0.0f);
    }

    static float Dot(FVector a, FVector b) {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    static float Distance(FVector a, FVector b) {
        FVector vector = FVector(a.x - b.x, a.y - b.y, a.z - b.z);
        return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
    }
    float Size ()
    {
        return sqrt( ( this->x * this->x ) + ( this->y * this->y ) + ( this->z * this->z) );
    }
};

struct FVector2D {
    float x;
    float y;
   
    inline FVector2D()
        : x(0), y(0)
    { }

    inline FVector2D(float _x, float _y)
        : x(_x),
          y(_y)
    { }
    FVector2D operator+(const FVector2D& rhs) const {
          return FVector2D(this->x + rhs.x, this->y + rhs.y);
      }
};

struct FVector4D {
    float x;
    float y;
    float z;
    float w;
};

struct FVectorRect {
    int x;
    int y;
    int w;
    int h;
};
struct Rotator {
    float x;
    float y;
    float Roll;
};

struct Tracking {
    Rotator aim_angle;
    FVector loc;
};

struct FRotator {
    float Pitch;
    float Yaw;
    float Roll;

    inline FRotator()
        : Pitch(0.0f), Yaw(0.0f), Roll(0.0f)
    { }

    inline FRotator(float pitch, float yaw, float roll)
        : Pitch(pitch), Yaw(yaw), Roll(roll)
    { }

    inline FRotator operator+ (const FRotator &A) {
        return FRotator(this->Pitch + A.Pitch, this->Yaw + A.Yaw, this->Roll + A.Roll);
    }

    inline FRotator operator- (const FRotator &A) {
        return FRotator(this->Pitch - A.Pitch, this->Yaw - A.Yaw, this->Roll - A.Roll);
    }

    inline FRotator operator* (const FRotator &A) {
        return FRotator(this->Pitch * A.Pitch, this->Yaw * A.Yaw, this->Roll * A.Roll);
    }

    inline FRotator operator* (const float A) {
        return FRotator(this->Pitch * A, this->Yaw * A, this->Roll * A);
    }

    inline FRotator operator/ (const FRotator &A) {
        return FRotator(this->Pitch / A.Pitch, this->Yaw / A.Yaw, this->Roll / A.Roll);
    }

    inline FRotator operator/ (const float A) {
        return FRotator(this->Pitch / A, this->Yaw / A, this->Roll / A);
    }
};

struct LTMatrix{
    float a1, a2, a3, a4;
    float b1, b2, b3, b4;
    float c1, c2, c3, c4;
    float d1, d2, d3, d4;
};

struct FTransform {
    FVector4D Rotation;
    FVector Translation;
    FVector Scale3D;
    
    LTMatrix ToMatrixWithScale() {
        LTMatrix m;
        m.d1 = Translation.x;
        m.d2 = Translation.y;
        m.d3 = Translation.z;
        
        float x2 = Rotation.x + Rotation.x;
        float y2 = Rotation.y + Rotation.y;
        float z2 = Rotation.z + Rotation.z;
        
        float xx2 = Rotation.x * x2;
        float yy2 = Rotation.y * y2;
        float zz2 = Rotation.z * z2;
        m.a1 = (1.0f - (yy2 + zz2)) * Scale3D.x;
        m.b2 = (1.0f - (xx2 + zz2)) * Scale3D.y;
        m.c3 = (1.0f - (xx2 + yy2)) * Scale3D.z;
        
        float yz2 = Rotation.y * z2;
        float wx2 = Rotation.w * x2;
        m.c2 = (yz2 - wx2) * Scale3D.z;
        m.b3 = (yz2 + wx2) * Scale3D.y;
        
        float xy2 = Rotation.x * y2;
        float wz2 = Rotation.w * z2;
        m.b1 = (xy2 - wz2) * Scale3D.y;
        m.a2 = (xy2 + wz2) * Scale3D.x;
        
        float xz2 = Rotation.x * z2;
        float wy2 = Rotation.w * y2;
        m.c1 = (xz2 + wy2) * Scale3D.z;
        m.a3 = (xz2 - wy2) * Scale3D.x;
        
        m.a4 = 0.0f;
        m.b4 = 0.0f;
        m.c4 = 0.0f;
        m.d4 = 1.0f;
        
        return m;
    }
};

struct FMatrix {
    float Matrix[4][4];

    float *operator[](int index) {
        return Matrix[index];
    }
};

struct MinimalViewInfo {
    FVector Location;
    FVector LocationLocalSpace;
    FRotator Rotation;
    float FOV;
};
struct FLinearColor {
    float R;
    float G;
    float B;
    float A;

    inline FLinearColor(): R(0), G(0), B(0), A(0){ }
    inline FLinearColor(float r, float g, float b, float a): R(r), G(g), B(b), A(a){ }
    inline FLinearColor(int rgba) {
        float sc = 1.0f / 255.0f;
        R = (float)((rgba >> 0) & 0xFF) * sc;
        G = (float)((rgba >> 8) & 0xFF) * sc;
        B = (float)((rgba >> 16) & 0xFF) * sc;
        A = (float)((rgba >> 24) & 0xFF) * sc;
    }
};

struct FString {
    char* PText;
    int Count;
    int Max;

    int Utf8ToUnicode(const char *utf8, unsigned short* unicode) {
        long len8 = strlen(utf8);
        int len16 = 0;
        unsigned short t, r;
        if(unicode != NULL) {
            for (int i = 0; i < len8;) {
                t = utf8[i] & 0xff;
                if(t < 0x80) {
                    r = t;
                    i++;
                }else if(t < 0xe0) {
                    r = t & 0x1f;
                    r <<= 6;
                    t = utf8[i + 1];
                    r += t & 0x3f;
                    i += 2;
                }else if(t < 0xf0){
                    r = t & 0x0f;
                    r <<= 6;
                    t = utf8[i + 1];
                    r += t & 0x3f;
                    r <<= 6;
                    t = utf8[i + 2];
                    r += t & 0x3f;
                    i += 3;
                }else {//出错，不处理
                    r = 0;
                    i++;
                }
                unicode[len16++] = r;
            }
            unicode[len16] = 0;
        }else {
            for (int i = 0; i < len8;) {
                t = utf8[i] & 0xff;
                if(t < 0x80) {
                    i++;
                }else if(t < 0xe0) {
                    i += 2;
                }else if(t < 0xf0){
                    i += 3;
                }else {
                    i++;
                }
                len16++;
            }
        }
        return len16;
    }

    static void UnicodeToUTF_8(char* pOut, wchar_t* pText, int Len) {
        char* pchar = (char *)pText;
        int coun = 0;
        for (int i = 0; i < Len; i++) {
            if (pchar[i*2+1] == 0) {
                pOut[coun] = pchar[i*2];
                coun++;
            } else {
                pOut[coun] = (0xE0 | ((pchar[i*2+1] & 0xF0) >> 4));
                pOut[coun+1] = (0x80 | ((pchar[i*2+1] & 0x0F) << 2)) + ((pchar[i*2] & 0xC0) >> 6);
                pOut[coun+2] = (0x80 | (pchar[i*2] & 0x3F));
                coun+=3;
            }
        }
    }

    inline FString(const char* strl) {
        char FText[256];
        Count = Max = Utf8ToUnicode(strl, (unsigned short *)FText) + 1;
        PText = FText;
    }
};

template<class TEnum>
class TEnumAsByte
{
public:
    inline TEnumAsByte()
    {
    }

    inline TEnumAsByte(TEnum _value)
        : value(static_cast<uint8_t>(_value))
    {
    }

    explicit inline TEnumAsByte(int32_t _value)
        : value(static_cast<uint8_t>(_value))
    {
    }

    explicit inline TEnumAsByte(uint8_t _value)
        : value(_value)
    {
    }

    inline operator TEnum() const
    {
        return (TEnum)value;
    }

    inline TEnum GetValue() const
    {
        return (TEnum)value;
    }

private:
    uint8_t value;
};

enum class ESTEPoseState : uint8_t
{
    ESTEPoseState__Stand           = 0,
    ESTEPoseState__Crouch          = 1,
    ESTEPoseState__Prone           = 2,
    ESTEPoseState__Sprint          = 3,
    ESTEPoseState__CrouchSprint    = 4,
    ESTEPoseState__Crawl           = 5,
    ESTEPoseState__Swim            = 6,
    ESTEPoseState__SwimSprint      = 7,
    ESTEPoseState__Dying           = 8,
    ESTEPoseState__DyingBeCarried  = 9,
    ESTEPoseState__DyingSwim       = 10,
    ESTEPoseState__ESTEPoseState_MAX = 11
};

static string GetWeaponIDName(int WeaponId) {
    string namea;
    switch (WeaponId) {
        case 0:
            namea = "拳头";
            break;
        case 102008:
            namea = "AKS-74U";
            break;
        case 106094:
            namea = "召回信号枪";
            break;
        case 107008:
            namea = "复合弓";
            break;
        case 602088:
            namea = "彩烟弹";
            break;
        case 101001:
            namea = "AK47";
            break;
        case 101002:
            namea = "M16A4";
            break;
        case 101003:
            namea = "SCAR-L";
            break;
        case 101004:
            namea = "M416";
            break;
        case 101005:
            namea = "GROZA";
            break;
        case 101006:
            namea = "AUG";
            break;
        case 101007:
            namea = "QBZ";
            break;
        case 101008:
            namea = "M762";
            break;
        case 101009:
            namea = "Mk47";
            break;
        case 101010:
            namea = "G36C";
            break;
        case 101011:
            namea = "AC-VAL";
            break;
        case 101012:
            namea = "蜜獾";
            break;
        case 102001:
            namea = "UZI";
            break;
        case 102002:
            namea = "UNP45";
            break;
        case 102003:
            namea = "Vector";
            break;
        case 102004:
            namea = "汤姆逊";
            break;
        case 102005:
            namea = "野牛";
            break;
        case 102007:
            namea = "MP5K";
            break;
        case 102105:
            namea = "P90";
            break;
        case 103001:
            namea = "Kar98K";
            break;
        case 103002:
            namea = "M24";
            break;
        case 103003:
            namea = "AWM";
            break;
        case 103004:
            namea = "SKS";
            break;
        case 103005:
            namea = "VSS";
            break;
        case 103006:
            namea = "Mini14";
            break;
        case 103007:
            namea = "Mk14";
            break;
        case 103008:
            namea = "Win94";
            break;
        case 103009:
            namea = "SLR";
            break;
        case 103010:
            namea = "QBU";
            break;
        case 103011:
            namea = "莫辛纳甘";
            break;
        case 103012:
            namea = "AMR";
            break;
        case 103014:
            namea = "MK20-H";
            break;
        case 103013:
            namea = "M417";
            break;
        case 103015:
            namea = "M200";
            break;
        case 104001:
            namea = "S686";
            break;
        case 104002:
            namea = "S1897";
            break;
        case 104003:
            namea = "S12K";
            break;
        case 104004:
            namea = "DBS";
            break;
        case 104100:
            namea = "SPAS-12";
            break;
        case 105002:
            namea = "DP-28";
            break;
        case 105010:
            namea = "MG3";
            break;
        case 105001:
            namea = "M249";
            break;
        case 105012:
            namea = "PMK";
            break;
        case 106001:
            namea = "P92";
            break;
        case 106002:
            namea = "P1911";
            break;
        case 106003:
            namea = "R1895";
            break;
        case 106004:
            namea = "P18C";
            break;
        case 106005:
            namea = "R45";
            break;
        case 106006:
            namea = "短管霰弹枪";
            break;
        case 106008:
            namea = "蝎式手枪";
            break;
        case 106010:
            namea = "沙漠之鹰";
            break;
        case 106011:
            namea = "TMP-9";
            break;
        case 106107:
            namea = "信号枪";
            break;
        case 107001:
            namea = "十字弩";
            break;
        case 107007:
            namea = "爆炸猎弓";
            break;
        case 107010:
            namea = "突击盾牌";
            break;
        case 108001:
            namea = "大砍刀";
            break;
        case 108002:
            namea = "撬棍";
            break;
        case 108003:
            namea = "镰刀";
            break;
        case 108004:
            namea = "平底锅";
            break;
        case 602004:
            namea = "手雷弹";
            break;
        case 602001:
            namea = "震爆弹";
            break;
        case 602002:
            namea = "烟雾弹";
            break;
        case 602003:
            namea = "燃烧瓶";
            break;
        case 602075:
            namea = "铝热弹";
            break;
        case 602069:
            namea = "紧急呼救器";
            break;
        case 603004:
            namea = "燃料电池包";
            break;
        case 604014:
            namea = "自救类除颤器";
            break;
        default:
            namea = "未知";
            break;
    }
    return namea;
}

namespace UI{
    
    
    void onEvent(float X,float Y,bool Down);
    
}


#endif /* ABC_hpp */

