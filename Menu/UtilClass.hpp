//
//  UtilClass.hpp
//  ABC
//
//  Created by ABC on 2022/11/18.
//
#include <stdint.h>
#pragma once

namespace SDK {

#define DEFINE_MEMBER_N(type, name, offset) struct { char __pad__##name[offset]; type name; }
#define DEFINE_MEMBER_N0(type, name) struct { type name; }

#define UObject_d \
DEFINE_MEMBER_N0(UVTabel*, VTable);\
DEFINE_MEMBER_N(int, ObjectIndex, 0xC);\
DEFINE_MEMBER_N(void*, Type, 0x10);\
DEFINE_MEMBER_N(int, FNameIndex, 0x18);

struct UtilClass
{
    template<typename T> T read(const unsigned short& offset) { return *(T*)((uintptr_t)this + offset); }
    template<typename T> void write(const unsigned short& offset, const T& value) { return *(T*)((uintptr_t)this + offset) = value; }
};

struct UVTabel
{
    inline uintptr_t operator[](const int index) { return items[index]; }

    inline uintptr_t offset(const int offset) { return *(uintptr_t*)((uintptr_t)this + offset); }

    uintptr_t items[256];
};

struct GActor : UtilClass
{
    union
    {
        UObject_d;
        DEFINE_MEMBER_N(bool, bHidden, 0x88);
        //DEFINE_MEMBER_N(FString, *PlayerName, 0x8f0);
        DEFINE_MEMBER_N(int, TeamID, 0x8c8);
        DEFINE_MEMBER_N(bool, bIsAI, 0x9db);
        DEFINE_MEMBER_N(float, Health, 0x2c4);
        DEFINE_MEMBER_N(float, HealthMax, 0x2c0);
        DEFINE_MEMBER_N(bool, bDead, 0xdcc);
        DEFINE_MEMBER_N(bool, bIsGunADS, 0xf59);
        DEFINE_MEMBER_N(float, NearDeathBreath, 0x17d8);
        DEFINE_MEMBER_N(bool, bIsWeaponFiring, 0x1688);
        DEFINE_MEMBER_N(uintptr_t, RootComponent, 0x1a8);
    };
};

}

