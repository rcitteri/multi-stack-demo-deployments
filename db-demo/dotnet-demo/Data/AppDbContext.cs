using Microsoft.EntityFrameworkCore;
using DotnetDbDemo.Models;

namespace DotnetDbDemo.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Pet> Pets { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Pet>(entity =>
        {
            entity.ToTable("pets");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").ValueGeneratedOnAdd();
            entity.Property(e => e.Race).HasColumnName("race").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Gender).HasColumnName("gender").HasMaxLength(10).IsRequired();
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Age).HasColumnName("age").IsRequired();
            entity.Property(e => e.Description).HasColumnName("description");
        });
    }
}
