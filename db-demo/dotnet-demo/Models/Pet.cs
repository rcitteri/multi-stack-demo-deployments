namespace DotnetDbDemo.Models;

public class Pet
{
    public long Id { get; set; }
    public string Race { get; set; } = string.Empty;
    public string Gender { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int Age { get; set; }
    public string? Description { get; set; }
}
