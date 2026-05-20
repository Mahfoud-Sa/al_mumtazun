using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlMumtazun.Api.Examples;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class ProtectedController : ControllerBase
{
    [HttpGet("any-authenticated-user")]
    public IActionResult AnyAuthenticatedUser() => Ok();

    [HttpGet("developer")]
    [Authorize(Roles = "Developer")]
    public IActionResult DeveloperOnly() => Ok();

    [HttpGet("admin")]
    [Authorize(Roles = "Admin")]
    public IActionResult AdminOnly() => Ok();
}
