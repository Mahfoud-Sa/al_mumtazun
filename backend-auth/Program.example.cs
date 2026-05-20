using System.Text;
using AlMumtazun.Api.Options;
using AlMumtazun.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services
    .AddOptions<JwtOptions>()
    .Bind(builder.Configuration.GetSection("Jwt"))
    .ValidateDataAnnotations()
    .ValidateOnStart();

var jwt = builder.Configuration.GetSection("Jwt").Get<JwtOptions>()
    ?? throw new InvalidOperationException("Jwt configuration is missing.");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        options.SaveToken = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Secret)),
            ValidateIssuer = true,
            ValidIssuer = jwt.Issuer,
            ValidateAudience = true,
            ValidAudience = jwt.Audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("DeveloperOnly", policy => policy.RequireRole("Developer"));
    options.AddPolicy("EmployeeOnly", policy => policy.RequireRole("Employee"));
    options.AddPolicy("AccountantOnly", policy => policy.RequireRole("Accountant"));
});

builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IPasswordHasher, BCryptPasswordHasher>();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
