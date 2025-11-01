using DotnetDemo.Models;

var builder = WebApplication.CreateBuilder(args);

// Configure port from environment variable or use default
var port = Environment.GetEnvironmentVariable("PORT") ?? "8081";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddRazorPages();

// Configure application settings
builder.Services.AddSingleton<AppConfig>(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    return new AppConfig
    {
        Uuid = Guid.NewGuid().ToString(),
        Version = configuration["App:Version"] ?? "1.0.0",
        DeploymentColor = configuration["App:DeploymentColor"] ?? "blue"
    };
});

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseStaticFiles();
app.UseRouting();

app.MapControllers();
app.MapRazorPages();
app.MapHealthChecks("/health");

// Fallback route for root
app.MapFallbackToFile("index.html");

app.Run();
