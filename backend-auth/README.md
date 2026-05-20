# ASP.NET Core JWT Role Auth Module

This folder is a drop-in backend implementation because this Flutter workspace
does not include the ASP.NET Core `.csproj`.

Install packages in the API project:

```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
```

Copy the files into matching folders in the Web API project, add the
`appsettings.Auth.json` settings to your real `appsettings.json`, then wire the
services from `Program.example.cs`.

Use a long production secret from your secret manager or environment variables.
Do not commit the real JWT secret.
