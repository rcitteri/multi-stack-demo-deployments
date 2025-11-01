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
var (connectionString, dbType) = GetDatabaseConnectionString(builder.Configuration);
builder.Services.AddDbContext<AppDbContext>(options =>
{
    if (dbType == "mysql")
    {
        var serverVersion = new MySqlServerVersion(new Version(8, 0, 21));
        options.UseMySql(connectionString, serverVersion);
        Console.WriteLine("Using MySQL database provider");
    }
    else
    {
        options.UseNpgsql(connectionString);
        Console.WriteLine("Using PostgreSQL database provider");
    }
});

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

static (string connectionString, string dbType) GetDatabaseConnectionString(IConfiguration configuration)
{
    // Check for Cloud Foundry VCAP_SERVICES
    var vcapServices = Environment.GetEnvironmentVariable("VCAP_SERVICES");
    if (!string.IsNullOrEmpty(vcapServices))
    {
        try
        {
            var services = System.Text.Json.JsonDocument.Parse(vcapServices);

            // Check for MySQL first
            if (services.RootElement.TryGetProperty("mysql", out var mysqlServices))
            {
                var mysql = mysqlServices[0];
                var credentials = mysql.GetProperty("credentials");

                var host = credentials.GetProperty("host").GetString();
                var port = credentials.GetProperty("port").GetInt32();
                var database = credentials.GetProperty("database").GetString();
                var username = credentials.GetProperty("username").GetString();
                var password = credentials.GetProperty("password").GetString();

                Console.WriteLine("Using MySQL database from VCAP_SERVICES");
                var connString = $"Server={host};Port={port};Database={database};User={username};Password={password};SslMode=Required;";
                return (connString, "mysql");
            }
            // Check for PostgreSQL
            else if (services.RootElement.TryGetProperty("postgres", out var postgresServices))
            {
                var postgres = postgresServices[0];
                var credentials = postgres.GetProperty("credentials");

                var host = credentials.GetProperty("host").GetString();
                var port = credentials.GetProperty("port").GetInt32();
                var database = credentials.GetProperty("database").GetString();
                var username = credentials.GetProperty("username").GetString();
                var password = credentials.GetProperty("password").GetString();

                Console.WriteLine("Using PostgreSQL database from VCAP_SERVICES");
                var connString = $"Host={host};Port={port};Database={database};Username={username};Password={password};SSL Mode=Require;Trust Server Certificate=true";
                return (connString, "postgres");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error parsing VCAP_SERVICES: {ex.Message}");
        }
    }

    // Check environment variable first (for Docker Compose), then fall back to configuration
    // Default to PostgreSQL for local/Docker development
    var connString = Environment.GetEnvironmentVariable("DATABASE_URL")
        ?? configuration.GetConnectionString("DefaultConnection")
        ?? "Host=localhost;Port=5432;Database=demodb;Username=demouser;Password=demopass";

    // Detect database type from connection string
    var dbType = connString.Contains("Server=") || connString.Contains("server=") ? "mysql" : "postgres";

    Console.WriteLine($"Using {dbType} database from configuration/environment");
    return (connString, dbType);
}
