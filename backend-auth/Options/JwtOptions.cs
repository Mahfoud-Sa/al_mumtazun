using System.ComponentModel.DataAnnotations;

namespace AlMumtazun.Api.Options;

public sealed class JwtOptions
{
    [Required, MinLength(32)]
    public string Secret { get; init; } = string.Empty;

    [Required]
    public string Issuer { get; init; } = string.Empty;

    [Required]
    public string Audience { get; init; } = string.Empty;

    [Range(5, 525600)]
    public int ExpirationMinutes { get; init; } = 60;
}
