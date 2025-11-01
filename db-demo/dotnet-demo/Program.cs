using Microsoft.EntityFrameworkCore;
using DotnetDbDemo.Data;
using DotnetDbDemo.Models;

var builder = WebApplication.CreateBuilder(args);

// Configure port from environment variable or use default
var port = Environment.GetEnvironmentVariable("PORT") ?? "8081";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Add services to the container
builder.Services.AddControllers();

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

// Configure database
var connectionString = GetDatabaseConnectionString(builder.Configuration);
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Add health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    DatabaseInitializer.Initialize(context);
}

// Configure the HTTP request pipeline
app.UseStaticFiles();
app.UseRouting();

app.MapControllers();
app.MapHealthChecks("/health");

// Serve index.html for root
app.MapFallbackToFile("index.html");

app.Run();

static string GetDatabaseConnectionString(IConfiguration configuration)
{
    // Check for Cloud Foundry VCAP_SERVICES
    var vcapServices = Environment.GetEnvironmentVariable("VCAP_SERVICES");
    if (!string.IsNullOrEmpty(vcapServices))
    {
        try
        {
            var services = System.Text.Json.JsonDocument.Parse(vcapServices);
            var postgres = services.RootElement.GetProperty("postgres")[0];
            var credentials = postgres.GetProperty("credentials");

            var host = credentials.GetProperty("host").GetString();
            var port = credentials.GetProperty("port").GetInt32();
            var database = credentials.GetProperty("database").GetString();
            var username = credentials.GetProperty("username").GetString();
            var password = credentials.GetProperty("password").GetString();

            Console.WriteLine("Using database from VCAP_SERVICES");
            return $"Host={host};Port={port};Database={database};Username={username};Password={password};SSL Mode=Require;Trust Server Certificate=true";
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error parsing VCAP_SERVICES: {ex.Message}");
        }
    }

    // Check environment variable first (for Docker Compose), then fall back to configuration
    var connString = Environment.GetEnvironmentVariable("DATABASE_URL")
        ?? configuration.GetConnectionString("DefaultConnection")
        ?? "Host=localhost;Port=5432;Database=demodb;Username=demouser;Password=demopass";

    Console.WriteLine("Using database from configuration/environment");
    return connString;
}
