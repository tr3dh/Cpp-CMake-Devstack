#include <string>
#include <Bitmask.h>

#include "raylib.h"
#include <steam/steam_api.h>

#include <SQLiteCpp/SQLiteCpp.h>
#include <SQLiteCpp/Backup.h>

/**
 * @page hinweise Allgemeine Hinweise
 *
 * Freier Text der einen allgemeinen Hinweis liefert.
 *
 * @note Das ist eine Randnotiz ohne Bezug zu einer Funktion.
 *
 * Unterseiten:
 * - @subpage hinweise_usage
 * - @subpage hinweise_known_issues
 */

/**
 * @page hinweise_usage Verwendung
 *
 * Hier steht wie man das Projekt verwendet.
 *
 * @note Darauf achten dass die Konfiguration vorher geladen wird.
 */

/**
 * @page hinweise_known_issues Bekannte Probleme
 *
 * Liste bekannter Probleme und Workarounds.
 *
 * @warning Dieser Abschnitt wird noch gepflegt.
 */

/**
 * @brief Eine Testklasse zur Demonstration der Doxygen-Dokumentation
 * @details Weitere Infos zur Testklasse
 */
class TestClass {
public:
    /**
     * @brief Konstruktor
     * @param name Name des Objekts
     */
    TestClass(const std::string& name) : m_name(name) {}

    /**
     * @brief Gibt den Namen zurück
     * @return Name des Objekts
     */
    std::string getName() const { return m_name; }

    /**
     * @brief Setzt den Namen
     * @param name Neuer Name
     */
    void setName(const std::string& name) { m_name = name; }

private:
    std::string m_name; ///< Name des Objekts
};

/**
 * @brief Ein Teststruct zur Demonstration der Doxygen-Dokumentation
 */
struct TestStruct {

    /// Eindeutige ID
    int id;          
    std::string tag; ///< Beschreibungs-Tag
    float value;     ///< Numerischer Wert
};

/**
 * @brief Testfunktion für die Doxygen-Dokumentation
 * 
 * Diese Funktion demonstriert die Doxygen-Dokumentation.
 * 
 * @param a Erster Wert
 * @param b Zweiter Wert
 * @return Summe von a und b
 */
int test(int a, int b) {
    return a + b;
}

//
int main(void)
{
    // Initialises the SteamAPI, wich is automatically detecting the Game Window and handling it
    bool g_steamAPI_Activated = SteamAPI_Init();

    // Initialization
    const int screenWidth = 800;
    const int screenHeight = 450;

    SetConfigFlags(FLAG_WINDOW_HIGHDPI | FLAG_MSAA_4X_HINT | FLAG_WINDOW_HIDDEN | FLAG_WINDOW_TOPMOST | FLAG_WINDOW_RESIZABLE);

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading gltf");

    // Define the camera to look into our 3d world
    Camera camera = { 0 };
    camera.position = { 6.0f, 6.0f, 6.0f };         // Camera position
    camera.target = { 0.0f, 2.0f, 0.0f };           // Camera looking at point
    camera.up = { 0.0f, 1.0f, 0.0f };               // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                            // Camera field-of-view Y
    camera.projection = CAMERA_PERSPECTIVE;         // Camera projection type

    // Load model
    Model model = LoadModel("../../Recc/assets/Stag.gltf");
    Vector3 position = { 0.0f, 0.0f, 0.0f };        // Set model world position

    // Load model animations
    int animCount = 0;
    ModelAnimation *anims = LoadModelAnimations("../../Recc/assets/Stag.gltf", &animCount);

    // Animation playing variables
    unsigned int animIndex = 0;                     // Current animation playing
    float animCurrentFrame = 0;                     // Current animation frame

    // SetTargetFPS(60);                               // Set our game to run at 60 frames-per-second

    // 
    if(IsWindowState(FLAG_WINDOW_HIDDEN)){ ClearWindowState(FLAG_WINDOW_HIDDEN); }

    // Main game loop
    while (!WindowShouldClose())                    // Detect window close button or ESC key
    {
        // Update
        UpdateCamera(&camera, CAMERA_ORBITAL);

        // Select current animation
        if (IsKeyPressed(KEY_RIGHT)) animIndex = (animIndex + 1)%animCount;
        else if (IsKeyPressed(KEY_LEFT)) animIndex = (animIndex + animCount - 1)%animCount;

        // Update model animation
        static float animSpeed = 60;
        animCurrentFrame += GetFrameTime() * animSpeed;

        while(animCurrentFrame > anims[animIndex].keyframeCount){ animCurrentFrame -= anims[animIndex].keyframeCount; }

        UpdateModelAnimation(model, anims[animIndex], animCurrentFrame);

        // Draw
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0f, WHITE);

                DrawGrid(10, 1.0f);

            EndMode3D();

            DrawText(TextFormat("Current animation: %s", anims[animIndex].name), 10, 40, 20, MAROON);
            DrawText("Use the LEFT/RIGHT keys to switch animation", 10, 10, 20, GRAY);

        EndDrawing();
    }

    // De-Initialization
    UnloadModelAnimations(anims, animCount);    // Unload model animations data
    UnloadModel(model);                         // Unload model

    CloseWindow();                              // Close window and OpenGL context

    // Shutdown SteamAPI if succesfully Initialized
    if(g_steamAPI_Activated){ SteamAPI_Shutdown(); }

    return 0;
}