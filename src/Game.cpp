#include "Game.h"
#include "raylib.h"
#include <steam/steam_api.h>

#include <iostream>
#include <assert.h>

#include "Animation.h"
#include "raymath.h"

// TODO : Wrapper Klassen wie ECSAnimationComponent entfernen

// Quaternion QuaternionFromAxisAngle(Vector3 axis, float angle)               // Get rotation quaternion for an angle and axis NOTE: Angle must be provided in radians
// void QuaternionToAxisAngle(Quaternion q, Vector3 *outAxis, float *outAngle)

struct ECSTransformComponent{

    Transform m_Transform = {
        .translation = Vector3Zero(),
        .rotation = QuaternionIdentity(),
        .scale = Vector3{1,1,1},
    };

    ECSTransformComponent() = default;

    void fromEuler(float pitch, float yaw, float roll){

        m_Transform.rotation = QuaternionFromEuler(pitch, yaw, roll);
    }

    void fromAxisAngle(const Vector3& axis, float angle){

        m_Transform.rotation = QuaternionFromAxisAngle(axis, angle);
    }

    std::pair<Vector3, float> asAxisAngle(){

        Vector3 axis;
        float angle;

        QuaternionToAxisAngle(m_Transform.rotation, &axis, &angle);

        return std::make_pair(axis, angle);
    }
};

entt::registry g_EntityRegistry;

void renderEntities(){

    //
    auto modelView = g_EntityRegistry.view<ECSTransformComponent, ECSModelComponent>(entt::exclude<ECSAnimationComponent>);
    auto animationView = g_EntityRegistry.view<ECSTransformComponent, ECSModelComponent, ECSAnimationComponent>();

    //
    for(auto [entity, transform, model] : modelView.each()) {
        
        auto [axis, angle] = transform.asAxisAngle();
        DrawModelEx(*model.m_Model, transform.m_Transform.translation, axis, angle * RAD2DEG, transform.m_Transform.scale, WHITE);
    }

    //
    std::unordered_map<Model*, std::pair<ModelAnimation*, size_t>> savedPoses;

    //
    for(auto [entity, transform, model, animation] : animationView.each()) {

        if(!savedPoses.contains(model.m_Model)){

            savedPoses.try_emplace(model.m_Model, &animation.m_Animation->getIdlePosAnimation(), animation.m_Animation->getIdlePoseFrame());
        }

        UpdateModelAnimation(*model.m_Model, animation.m_Animation->getCurrentAnimation(), animation.m_Animation->getCurrentFrame());
        
        auto [axis, angle] = transform.asAxisAngle();
        DrawModelEx(*model.m_Model, transform.m_Transform.translation, axis, angle * RAD2DEG, transform.m_Transform.scale, WHITE);
    }

    //
    for(auto& [model, pose] : savedPoses){

        UpdateModelAnimation(*model, *pose.first, pose.second);
    }
}

void updateEntities(const float& deltaTime){

    //
    auto modelView = g_EntityRegistry.view<ECSTransformComponent, ECSModelComponent>(entt::exclude<ECSAnimationComponent>);
    auto animationView = g_EntityRegistry.view<ECSTransformComponent, ECSModelComponent, ECSAnimationComponent>();

    //
    for(auto [entity, transform, model, animation] : animationView.each()) {
        animation.update(deltaTime);
    }
}

int runGame(int argc, char* argv[]){

    // Initialises the SteamAPI, wich is automatically detecting the Game Window and handling it
    bool g_steamAPI_Activated = SteamAPI_Init();

    SetConfigFlags(FLAG_WINDOW_HIGHDPI | FLAG_MSAA_4X_HINT | FLAG_WINDOW_HIDDEN | FLAG_WINDOW_TOPMOST | FLAG_WINDOW_RESIZABLE);
    InitWindow(1200, 800, "raylib [models] example - loading gltf");

    SetTargetFPS(100);

    //
    entt::entity entity = g_EntityRegistry.create();
    g_EntityRegistry.emplace<ECSModelComponent>(entity, "../../Recc/assets/Stag.gltf");
    g_EntityRegistry.emplace<ECSAnimationComponent>(entity, "../../Recc/assets/Stag.gltf").play("Idle");
    auto& transform = g_EntityRegistry.emplace<ECSTransformComponent>(entity);
    transform.fromEuler(0, 45, 0);

    //
    entity = g_EntityRegistry.create();
    g_EntityRegistry.emplace<ECSModelComponent>(entity, "../../Recc/assets/Stag.gltf");
    auto& transformb = g_EntityRegistry.emplace<ECSTransformComponent>(entity);
    transformb.m_Transform.translation = Vector3{2,2,0};

    // Define the camera to look into our 3d world
    Camera camera = { 0 };
    camera.position = { 6.0f, 6.0f, 6.0f };         // Camera position
    camera.target = { 0.0f, 2.0f, 0.0f };           // Camera looking at point
    camera.up = { 0.0f, 1.0f, 0.0f };               // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                            // Camera field-of-view Y
    camera.projection = CAMERA_PERSPECTIVE;         // Camera projection type

    if(IsWindowState(FLAG_WINDOW_HIDDEN)){ ClearWindowState(FLAG_WINDOW_HIDDEN); }

    // Main game loop
    while (!WindowShouldClose())                    // Detect window close button or ESC key
    {
        //
        static float deltaTime = 0.0f;
        deltaTime = GetFrameTime();

        //
        updateEntities(deltaTime);

        // Update
        // UpdateCamera(&camera, CAMERA_ORBITAL);

        // Draw
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // DrawModel(model, Vector3{0,0,0}, 1.0f, WHITE);
                renderEntities();

                DrawGrid(10, 1.0f);

            EndMode3D();

        DrawText(TextFormat("FPS: %f", 1/deltaTime), 10, 40, 20, MAROON);

        EndDrawing();
    }

    // Shutdown SteamAPI if succesfully Initialized
    if(g_steamAPI_Activated){ SteamAPI_Shutdown(); }

    // Unload Animations
    AnimationRegistry::unloadAnimations();

    // Unload Models
    ModelRegistry::unloadModels();

    CloseWindow();

    return 0;
}