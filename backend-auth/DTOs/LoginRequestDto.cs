using System.ComponentModel.DataAnnotations;

namespace AlMumtazun.Api.DTOs;

public sealed class LoginRequestDto
{
    [Required, Phone]
    public string PhoneNumber { get; init; } = string.Empty;

    [Required, MinLength(6)]
    public string Password { get; init; } = string.Empty;
}
