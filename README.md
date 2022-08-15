# LaunchDarkly Sandbox

## Getting Started
You'll need the following pre-requisites:
* dotnet 6.0 (https://dotnet.microsoft.com/en-us/learn/dotnet/hello-world-tutorial/install)
* terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)
* LaunchDarkly Access Token (https://app.launchdarkly.com/settings/authorization/tokens/new)

## Deploying the LD Project
First, change directory into the `iac` directory, run `terraform init`, and then `terraform apply`. You'll be prompted to supply your LD SDK key.

Upon success, you should have a project "nerdamigo" with a single environment "production". That environment will have three flags and three segments.

As an output of this apply, a local file will be generated for the environment's SDK key. This file will be consumed by the web application. When you're done, you can execute `terraform destroy` to remove the project and related configuration, as well as the file containing the secrets.

## Running the Application
You can build this application using start with `dotnet run` inside the root directory.

Once started up, review the output to identify the listen port; you'll be able to invoke requests at that endpoint. For example, with the following startup output:

```
$ dotnet run
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: https://localhost:7150
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5030
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /home/matt/source/nerdamigo-ld-sandbox/
```

You would expect to invoke the API methods at a base URI of either `https://localhost:7150` or `http://localhost:5030`

There is a single endpoint, accessible at `/v1/user/{string uid}?[gender=string]`. The path value for `{uid}` is required, and the `gender` query string parameter is optional.

## Configured Flags
There are several flags that are inspected by this application; `feature-global`, `feature-gender-greeting`, and `feature-long-uid`. 

### feature-global
The global flag simply demonstrates how you might turn on or off a feature for all user. By default, the IaC turns this on. Try changing the default value while the app is running!

### feature-gender-greeting
Depending on the specified gender of a user, the greeting served is varied using Segments. These segments could be revised to test variations of messaging to subsets of populations.

### feature-long-uid
Here, we simply demonstrate how the logic that defines what constitutes a business rule might be exposed through the LaunchDarkly interface. By default, users with an id >= 8 characters long are provided a different description than the baseline.

## Common Errors:
* When starting, message "System.IO.FileNotFoundException: Could not find file '[path-to-project]/ld-environment-config.json'"  
Please ensure you run the terraform commands to deploy the application's project, environment, and flags.
* HTTP 404  
Ensure you are accessing the URI output by the application's startup logs, and at a supported endpoint