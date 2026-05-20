namespace AlMumtazun.Api.DTOs;

public sealed class LoginResponseDto
{
    public bool Success { get; init; }
    public string Message { get; init; } = string.Empty;
    public string Token { get; init; } = string.Empty;
    public DateTime ExpiresAt { get; init; }
    public AuthUserDto? User { get; init; }
}
