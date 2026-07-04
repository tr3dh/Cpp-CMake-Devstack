/**
 * @file    Animation.h
 * @brief   Declaration of AnimationRegistry and -component and related utilities
 * @author  Tim Rother
 * @copyright (c) 2026 Tim Rother – MIT License
 */
#pragma once

#include "Model.h"

namespace AnimationRegistry{

    struct Animation{

        int numOfAnimations = -1;
        ModelAnimation* animations = nullptr;

        size_t currentAnimation = -1;
        float currentFrame = -1.0;
        float playingSpeed = 60.0f;

        size_t idlePoseAnimation = 0, idlePoseFrame = 0;

        std::unordered_map<StringID, size_t> StringIDToAnimationAssignment = {};

        Animation(const std::string& path){

            animations = LoadModelAnimations(path.c_str(), &numOfAnimations);

            for(size_t i = 0; i < numOfAnimations; i++){

                StringIDToAnimationAssignment.try_emplace(animations[i].name, i);
            }
        }

        Animation(const char* path) : Animation(std::string(path)){}

        void play(size_t animIdx){

            if(animIdx >= numOfAnimations){ return; }

            currentFrame = 0.0f;
            currentAnimation = animIdx;
        }

        void play(StringID animLabel){

            assert(StringIDToAnimationAssignment.contains(animLabel) && "Unter Label ist keine Animation hinterlegt");

            currentFrame = 0.0f;
            currentAnimation = StringIDToAnimationAssignment[animLabel];
        }

        void update(const float& deltaTime){
            
            if(currentAnimation >= numOfAnimations){ return; }

            currentFrame += deltaTime * playingSpeed;
            if(currentFrame > animations[currentAnimation].keyframeCount){
                currentFrame = animations[currentAnimation].keyframeCount % (int)currentFrame;
            }
        }

        ModelAnimation& getCurrentAnimation(){

            assert(currentAnimation < numOfAnimations && "Invalider Animationsindex");
            return animations[currentAnimation];
        }

        size_t getCurrentFrame(){

            assert(currentFrame >= 0 && "Invalider Frame");
            return currentFrame;
        }

        ModelAnimation& getIdlePosAnimation(){

            assert(idlePoseAnimation < numOfAnimations && "Invalider Animationsindex");

            return animations[idlePoseAnimation];
        }

        size_t getIdlePoseFrame(){

            assert(idlePoseFrame >= 0 && "Invalider Frame");
            return idlePoseFrame;
        }
    };

    inline std::unordered_map<StringID, Animation> StringIDToAnimationAssignment = {};

    inline Animation* getAnimation(const std::string& path){

        // Sicherstellen, dass ID für 'str' vergeben worden ist
        StringID strID = path;

        if(!StringIDToAnimationAssignment.contains(strID)){

            StringIDToAnimationAssignment.try_emplace(strID, path);
        }

        return &StringIDToAnimationAssignment.at(strID);
    }

    inline Animation* getAnimation(const char* path){

        return getAnimation(std::string(path));
    }

    inline void unloadAnimations(){

        for(auto& [id, anim] : StringIDToAnimationAssignment){

            UnloadModelAnimations(anim.animations, anim.numOfAnimations);
        }
    }
};

struct ECSAnimationComponent{

    AnimationRegistry::Animation* m_Animation;

    ECSAnimationComponent(const std::string& path){

        m_Animation = AnimationRegistry::getAnimation(path);
    }

    ECSAnimationComponent(const char* path) : ECSAnimationComponent(std::string(path)){}

    template<typename T>
    void play(T anim){

        return m_Animation->play(anim);
    }

    void update(const float& deltaTime){
        
        return m_Animation->update(deltaTime);
    }
};