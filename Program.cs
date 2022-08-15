using LaunchDarkly.Sdk;
using LaunchDarkly.Sdk.Server;
using Newtonsoft.Json.Linq;
using System.IO;

dynamic envConfig = JObject.Parse(File.ReadAllText("ld-environment-config.json"));

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

Console.WriteLine(envConfig.project.environments[0].api_key);

using(var ldClient = new LdClient((string)envConfig.project.environments[0].api_key))
{
    app.MapGet("/v1/user/{uid}", (string uid, string? gender) => {
        var user = User.Builder(uid)
            .Name(uid)
            .Custom("id-length", uid.Length)
            .Custom("gender", gender ?? "not-provided")
            .Build();

        var featureBool = ldClient.BoolVariation("feature-bool", user, false);
        
        var genderGreeting = ldClient.StringVariation("feature-gender-greeting", user, "not-assigned");

        var uidDescription = ldClient.StringVariation("feature-long-uid", user, "short") switch {
            "long" => "wow, such a long UID",
            _ => "pretty typical UID"
        };

        var response = $"{genderGreeting} {uid}! Your uid qualifies as '{uidDescription}'";

        if(featureBool) {
            response = response.ToUpper();
        }

        return response;
    });
    

    app.Run();
}

