package com.example.dbdemo.controller;

import com.example.dbdemo.model.Pet;
import com.example.dbdemo.repository.PetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class PetController {

    @Autowired
    private PetRepository petRepository;

    @GetMapping("/api/pets")
    public List<Pet> getAllPets() {
        return petRepository.findAll();
    }
}
