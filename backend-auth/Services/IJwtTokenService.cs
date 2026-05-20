using AlMumtazun.Api.DTOs;

namespace AlMumtazun.Api.Services;

public interface IJwtTokenService
{
    (string Token, DateTime ExpiresAt) CreateToken(AuthUserDto user);
}
