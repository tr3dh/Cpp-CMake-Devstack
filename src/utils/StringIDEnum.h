/**
 * @file    StringID.h
 * @brief   Declaration and implementation of StringID class and related utilities
 * @author  Tim Rother
 * @copyright (c) 2026 Tim Rother – MIT License
 */
#pragma once

#include <cstdint>
#include <string>
#include <string_view>
#include <iostream>
#include <limits>
#include <compare>
#include <unordered_map>
#include <functional>

#include "StringID.h"

#define DECL_ENUM(label) Enum* label = Enum::spawnEnum();
#define DECL_ENUM_MEMBER(enumLabel, memberLabel) EnumMember enumLabel##_Member_##memberLabel = enumLabel ->getMember(#memberLabel);

struct Enum;

struct EnumMember{

    ID m_EnumID = -1, m_MemberID = -1;
    Enum* m_Enum = nullptr;

    EnumMember& operator=(const std::string& str);
    EnumMember& operator=(const char* cstr);

    bool operator==(const EnumMember& other) const noexcept{

        return m_EnumID == other.m_EnumID && m_MemberID == other.m_MemberID;
    }
};

namespace std {
    template<>
    struct hash<EnumMember> {
        size_t operator()(const EnumMember& enumMember) const noexcept {
            return static_cast<size_t>(enumMember.m_MemberID);
        }
    };
}

struct Enum {

    static ID EnumIDCounter;
    static std::unordered_map<ID, Enum> EnumInstances;

    ID EnumID = -1;
    ID IDCounter = 0;

    std::unordered_map<std::string, ID> StringToIDAssignment = {};
    std::unordered_map<ID, std::string> IDToStringAssignment = {};

    Enum() = delete;
    Enum(ID id) : EnumID(id) {}

    static Enum* spawnEnum(){

        return &EnumInstances.try_emplace(EnumIDCounter, EnumIDCounter++).first->second;
    }

    ID getMemberID(const std::string& str) {

        if (!StringToIDAssignment.contains(str)) {
            
            const ID id = IDCounter++;
            
            StringToIDAssignment.try_emplace(str, id);
            IDToStringAssignment.try_emplace(id, str);
            
            return id;
        }

        return StringToIDAssignment.at(str);
    }

    EnumMember getMember(const std::string& str) {

        return EnumMember{ .m_EnumID = EnumID, .m_MemberID = getMemberID(str), .m_Enum = this };
    }

    std::string& getMemberLabel(const ID& id) {
        
        if (!IDToStringAssignment.contains(id)) {
            return nullstring;
        }
        return IDToStringAssignment.at(id);
    }

    bool contains(const EnumMember& member){

        if(member.m_EnumID != EnumID){ return false; }
        if(member.m_MemberID > EnumIDCounter){ return false; }

        return true;
    }
};

ID Enum::EnumIDCounter = 0;
std::unordered_map<ID, Enum> Enum::EnumInstances = {};