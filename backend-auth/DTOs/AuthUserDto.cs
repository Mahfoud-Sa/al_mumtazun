namespace AlMumtazun.Api.DTOs;

public sealed class AuthUserDto
{
    public int Id { get; init; }
    public string FullName { get; init; } = string.Empty;
    public string PhoneNumber { get; init; } = string.Empty;
    public string Role { get; init; } = string.Empty;
    public string RoleDisplayName { get; init; } = string.Empty;
    public bool IsActive { get; init; }
}
