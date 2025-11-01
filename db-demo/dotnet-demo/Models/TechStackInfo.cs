namespace DotnetDbDemo.Models;

public class TechStackInfo
{
    public string Uuid { get; set; } = string.Empty;
    public string Version { get; set; } = string.Empty;
    public string DeploymentColor { get; set; } = string.Empty;
    public TechStack TechStack { get; set; } = new();
}
