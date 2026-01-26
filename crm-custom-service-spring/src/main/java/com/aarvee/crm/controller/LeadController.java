package com.aarvee.crm.controller;

import com.aarvee.crm.dto.PageResponse;
import com.aarvee.crm.entity.LeadExtension;
import com.aarvee.crm.service.LeadExtensionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * REST controller for managing leads through the /api/leads endpoint.
 * This is an alias for LeadExtension to provide a simpler interface for Phase 1.
 */
@RestController
@RequestMapping("/api/leads")
@RequiredArgsConstructor
public class LeadController {
    
    private final LeadExtensionService service;
    
    @PostMapping
    public ResponseEntity<LeadExtension> create(@RequestBody LeadExtension lead) {
        LeadExtension created = service.create(lead);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping
    public ResponseEntity<PageResponse<LeadExtension>> getList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int perPage,
            @RequestParam(defaultValue = "createdAt") String sortField,
            @RequestParam(defaultValue = "desc") String sortOrder) {
        
        Page<LeadExtension> pageData = service.getList(page, perPage, sortField, sortOrder);
        PageResponse<LeadExtension> response = new PageResponse<>(
            pageData.getContent(),
            pageData.getTotalElements()
        );
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<LeadExtension> getOne(@PathVariable Long id) {
        return service.getOne(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<LeadExtension> update(@PathVariable Long id, @RequestBody LeadExtension lead) {
        try {
            LeadExtension updated = service.update(id, lead);
            return ResponseEntity.ok(updated);
        } catch (jakarta.persistence.EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Lead deleted successfully");
        return ResponseEntity.ok(response);
    }
}
