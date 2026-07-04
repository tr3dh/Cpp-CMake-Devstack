#include "StringIDEnum.h"

EnumMember& EnumMember::operator=(const std::string& str){

    m_MemberID = m_Enum->getMemberID(str);
    return *this;
}

EnumMember& EnumMember::operator=(const char* cstr){

    return this->operator=(std::string(cstr));
}