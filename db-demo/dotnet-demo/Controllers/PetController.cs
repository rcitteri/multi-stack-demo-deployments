using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DotnetDbDemo.Data;
using DotnetDbDemo.Models;

namespace DotnetDbDemo.Controllers;

[ApiController]
[Route("api")]
public class PetController : ControllerBase
{
    private readonly AppDbContext _context;

    public PetController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("pets")]
    public async Task<ActionResult<IEnumerable<Pet>>> GetPets()
    {
        return await _context.Pets.ToListAsync();
    }
}
