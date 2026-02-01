package com.aarvee.crm.controller;

import com.aarvee.crm.dto.PageResponse;
import com.aarvee.crm.entity.LeadExtension;
import com.aarvee.crm.service.LeadExtensionService;
import com.aarvee.crm.util.SortParamMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/lead_extensions")
@RequiredArgsConstructor
public class LeadExtensionController {
    
    private final LeadExtensionService service;
    
    @PostMapping
    public ResponseEntity<LeadExtension> create(@RequestBody LeadExtension leadExtension) {
        // Allow creating leads without contactId for Phase 1 standalone lead form
        LeadExtension created = service.create(leadExtension);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @GetMapping
    public ResponseEntity<?> getList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int perPage,
            @RequestParam(defaultValue = "createdAt") String sortField,
            @RequestParam(defaultValue = "desc") String sortOrder) {

        String mapped = SortParamMapper.map(sortField);
        if (mapped == null) {
            SortParamMapper.incrementInvalidCount();
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Invalid sort field");
            error.put("allowed", String.join(", ", SortParamMapper.ALLOWED_FIELDS()));
            return ResponseEntity.badRequest().body(error);
        }

        Page<LeadExtension> pageData = service.getList(page, perPage, mapped, sortOrder);
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
    public ResponseEntity<LeadExtension> update(@PathVariable Long id, @RequestBody LeadExtension leadExtension) {
        try {
            LeadExtension updated = service.update(id, leadExtension);
            return ResponseEntity.ok(updated);
        } catch (jakarta.persistence.EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Lead extension deleted successfully");
        return ResponseEntity.ok(response);
    }
}
