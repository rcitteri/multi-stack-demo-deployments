package com.example.dbdemo.service;

import com.example.dbdemo.model.Pet;
import com.example.dbdemo.repository.PetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    @Autowired
    private PetRepository petRepository;

    @Override
    public void run(String... args) {
        // Only initialize if database is empty
        if (petRepository.count() == 0) {
            System.out.println("Initializing database with sample pet data...");

            petRepository.save(new Pet("Golden Retriever", "Male", "Max", 5, "Friendly and energetic"));
            petRepository.save(new Pet("Persian Cat", "Female", "Luna", 3, "Calm and loves to cuddle"));
            petRepository.save(new Pet("German Shepherd", "Male", "Rocky", 7, "Loyal and protective"));
            petRepository.save(new Pet("Siamese Cat", "Female", "Bella", 2, "Playful and vocal"));
            petRepository.save(new Pet("Labrador", "Male", "Charlie", 4, "Gentle and loves water"));
            petRepository.save(new Pet("Maine Coon", "Female", "Daisy", 6, "Large and affectionate"));
            petRepository.save(new Pet("Border Collie", "Female", "Molly", 3, "Intelligent and active"));
            petRepository.save(new Pet("Bengal Cat", "Male", "Oliver", 4, "Wild appearance, playful nature"));

            System.out.println("Database initialized with 8 pets");
        } else {
            System.out.println("Database already contains data, skipping initialization");
        }
    }
}
