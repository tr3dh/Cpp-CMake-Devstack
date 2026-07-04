/**
 * @file    StringID.cpp
 * @brief   Declaration of StringID class and related utilities
 * @author  Tim Rother
 * @copyright (c) 2026 Tim Rother – MIT License
 */
#include "StringID.h"

std::string nullstring = "[NULLSTR]";

ID StringRegistry::IDCounter = 0;

std::unordered_map<std::string, ID> StringRegistry::StringToIDAssignment = {};
std::unordered_map<ID, std::string> StringRegistry::IDToStringAssignment = {};

ID StringRegistry::getID(const std::string& str){

    //
    if(!StringToIDAssignment.contains(str)){

        IDToStringAssignment.try_emplace(IDCounter, str);
        return StringToIDAssignment.try_emplace(str, IDCounter++).first->second;
    }

    return StringToIDAssignment.at(str);
}

std::string& StringRegistry::getString(const ID& id){

    if(!IDToStringAssignment.contains(id)){ return nullstring; }
    return IDToStringAssignment.at(id);
}

StringID& StringID::operator=(const std::string& str){

    m_ID = StringRegistry::getID(str);
    return *this;
}

StringID& StringID::operator=(const char* cstr){

    return this->operator=(std::string(cstr));
}

StringID::StringID() = default;

StringID::StringID(const std::string& str){

    m_ID = StringRegistry::getID(str);
}

StringID::StringID(const char* cstr) : StringID(std::string(cstr)){}

bool StringID::operator==(const StringID& other) const noexcept {
    
    return m_ID == other.m_ID;
}

std::strong_ordering StringID::operator<=>(const StringID&) const = default;

std::string* StringID::operator*() const{

    return &StringRegistry::getString(m_ID);
}

std::string* StringID::operator->() const{

    return this->operator*();
}

std::ostream& operator<<(std::ostream& os, const StringID& strID){

    // Abgleich mit numerischen Limits damit '-1' und nicht numerisches Maximum des ID Typens ausgegeben wird
    os << "StringIDs[ " << (strID.m_ID == std::numeric_limits<ID>::max() ? -1 : strID.m_ID) << " ] >> '" << *strID.operator->() << "'";
    return os;
}