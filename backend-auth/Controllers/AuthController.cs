using System.Security.Claims;
using AlMumtazun.Api.DTOs;
using AlMumtazun.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AlMumtazun.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AuthController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IPasswordHasher _passwordHasher;

    public AuthController(
        AppDbContext db,
        IJwtTokenService jwtTokenService,
        IPasswordHasher passwordHasher)
    {
        _db = db;
        _jwtTokenService = jwtTokenService;
        _passwordHasher = passwordHasher;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponseDto>> Login(LoginRequestDto request)
    {
        var phone = request.PhoneNumber.Trim();
        var user = await _db.Users.SingleOrDefaultAsync(x => x.PhoneNumber == phone);

        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new LoginResponseDto
            {
                Success = false,
                Message = "Invalid phone number or password"
            });
        }

        if (!user.IsActive)
        {
            return Forbid();
        }

        var dto = new AuthUserDto
        {
            Id = user.Id,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            Role = user.Role,
            RoleDisplayName = user.RoleDisplayName,
            IsActive = user.IsActive
        };

        var token = _jwtTokenService.CreateToken(dto);

        return Ok(new LoginResponseDto
        {
            Success = true,
            Message = "Login successful",
            Token = token.Token,
            ExpiresAt = token.ExpiresAt,
            User = dto
        });
    }

    [Authorize]
    [HttpGet("me")]
    public async Task<ActionResult<AuthUserDto>> GetCurrentUser()
    {
        var idValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(idValue, out var id)) return Unauthorized();

        var user = await _db.Users.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id);
        if (user is null || !user.IsActive) return Unauthorized();

        return Ok(new AuthUserDto
        {
            Id = user.Id,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            Role = user.Role,
            RoleDisplayName = user.RoleDisplayName,
            IsActive = user.IsActive
        });
    }

    [Authorize]
    [HttpPost("logout")]
    public IActionResult Logout()
    {
        return NoContent();
    }
}
