using DotnetDbDemo.Models;

namespace DotnetDbDemo.Data;

public static class DatabaseInitializer
{
    public static void Initialize(AppDbContext context)
    {
        // Ensure database is created
        context.Database.EnsureCreated();

        // Check if database already has data
        if (context.Pets.Any())
        {
            Console.WriteLine("Database already contains data, skipping initialization");
            return;
        }

        Console.WriteLine("Initializing database with sample pet data...");

        var pets = new Pet[]
        {
            new Pet { Race = "Golden Retriever", Gender = "Male", Name = "Max", Age = 5, Description = "Friendly and energetic" },
            new Pet { Race = "Persian Cat", Gender = "Female", Name = "Luna", Age = 3, Description = "Calm and loves to cuddle" },
            new Pet { Race = "German Shepherd", Gender = "Male", Name = "Rocky", Age = 7, Description = "Loyal and protective" },
            new Pet { Race = "Siamese Cat", Gender = "Female", Name = "Bella", Age = 2, Description = "Playful and vocal" },
            new Pet { Race = "Labrador", Gender = "Male", Name = "Charlie", Age = 4, Description = "Gentle and loves water" },
            new Pet { Race = "Maine Coon", Gender = "Female", Name = "Daisy", Age = 6, Description = "Large and affectionate" },
            new Pet { Race = "Border Collie", Gender = "Female", Name = "Molly", Age = 3, Description = "Intelligent and active" },
            new Pet { Race = "Bengal Cat", Gender = "Male", Name = "Oliver", Age = 4, Description = "Wild appearance, playful nature" }
        };

        context.Pets.AddRange(pets);
        context.SaveChanges();

        Console.WriteLine("Database initialized with 8 pets");
    }
}
