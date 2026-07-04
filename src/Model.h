/**
 * @file    Model.h
 * @brief   Declaration of ModelRegistry and -component and related utilities
 * @author  Tim Rother
 * @copyright (c) 2026 Tim Rother – MIT License
 */
#pragma once

#include "utils/StringID.h"
#include "raylib.h"

namespace ModelRegistry{

    inline std::unordered_map<StringID, Model> StringIDToModelAssignment = {};

    inline Model* getModel(const std::string& path){

        // Sicherstellen, dass ID für 'str' vergeben worden ist
        StringID strID = path;

        if(!StringIDToModelAssignment.contains(strID)){

            StringIDToModelAssignment.try_emplace(strID, LoadModel(path.c_str()));
        }

        return &StringIDToModelAssignment.at(strID);
    }

    inline Model* getModel(const char* path){

        return getModel(std::string(path));
    }

    inline void unloadModels(){

        for(auto& [id, model] : StringIDToModelAssignment){

            UnloadModel(model);
        }
    }
};

struct ECSModelComponent{

    Model* m_Model;

    ECSModelComponent(const std::string& path){

        m_Model = ModelRegistry::getModel(path);
    }

    ECSModelComponent(const char* path) : ECSModelComponent(std::string(path)){}
};