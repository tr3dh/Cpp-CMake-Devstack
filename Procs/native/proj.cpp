#include <Urho3D/Engine/Application.h>
#include <Urho3D/Engine/EngineDefs.h>
#include <Urho3D/Core/Context.h>

#include <steam/steam_api.h>

using namespace Urho3D;

class HelloWorld : public Application
{
    URHO3D_OBJECT(HelloWorld, Application);

public:

    HelloWorld(Context* context) : Application(context) {}

    void Start() override
    {
        
    }
};

int main(int argc, char** argv)
{
    // SteamAPI_Init();

    // Urho3D::ParseArguments(argc, argv);
    // auto context = new Urho3D::Context();
    // auto app = new HelloWorld(context);
    // app->Run();

    // SteamAPI_Shutdown();

    return 0;
}