using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AlMumtazun.Api.DTOs;
using AlMumtazun.Api.Options;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace AlMumtazun.Api.Services;

public sealed class JwtTokenService : IJwtTokenService
{
    private readonly JwtOptions _options;

    public JwtTokenService(IOptions<JwtOptions> options)
    {
        _options = options.Value;
    }

    public (string Token, DateTime ExpiresAt) CreateToken(AuthUserDto user)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(_options.ExpirationMinutes);
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.FullName),
            new Claim("fullName", user.FullName),
            new Claim("phoneNumber", user.PhoneNumber),
            new Claim(ClaimTypes.MobilePhone, user.PhoneNumber),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expiresAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
