package com.aarvee.crm.service;

import com.aarvee.crm.entity.LeadExtension;
import com.aarvee.crm.repository.LeadExtensionRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeadExtensionService {
    
    private final LeadExtensionRepository repository;
    
    /**
     * Generate a unique lead number
     */
    private String generateLeadNumber() {
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String prefix = "LEAD-" + today;
        long count = repository.countByLeadNumberStartingWith(prefix);
        return String.format("%s-%05d", prefix, count + 1);
    }
    
    @Transactional
    public LeadExtension create(LeadExtension leadExtension) {
        if (leadExtension.getLeadNumber() == null || leadExtension.getLeadNumber().isEmpty()) {
            leadExtension.setLeadNumber(generateLeadNumber());
        }
        if (leadExtension.getLeadStatus() == null || leadExtension.getLeadStatus().isEmpty()) {
            leadExtension.setLeadStatus("new");
        }
        log.info("Creating lead extension: {}", leadExtension.getLeadNumber());
        return repository.save(leadExtension);
    }
    
    public Page<LeadExtension> getList(int page, int perPage, String sortField, String sortOrder) {
        Sort.Direction direction = "desc".equalsIgnoreCase(sortOrder) ? Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page - 1, perPage, Sort.by(direction, sortField));
        return repository.findAll(pageable);
    }
    
    public Optional<LeadExtension> getOne(Long id) {
        return repository.findById(id);
    }
    
    @Transactional
    public LeadExtension update(Long id, LeadExtension leadExtension) {
        LeadExtension existing = repository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Lead extension not found with id: " + id));
        
        // Update fields
        if (leadExtension.getProduct() != null) existing.setProduct(leadExtension.getProduct());
        if (leadExtension.getLoanAmountRequired() != null) existing.setLoanAmountRequired(leadExtension.getLoanAmountRequired());
        if (leadExtension.getLocation() != null) existing.setLocation(leadExtension.getLocation());
        if (leadExtension.getLeadReferredBy() != null) existing.setLeadReferredBy(leadExtension.getLeadReferredBy());
        if (leadExtension.getShortDescription() != null) existing.setShortDescription(leadExtension.getShortDescription());
        if (leadExtension.getLeadAssignedTo() != null) existing.setLeadAssignedTo(leadExtension.getLeadAssignedTo());
        if (leadExtension.getLeadStatus() != null) existing.setLeadStatus(leadExtension.getLeadStatus());
        if (leadExtension.getBusinessDetails() != null) existing.setBusinessDetails(leadExtension.getBusinessDetails());
        if (leadExtension.getPropertyDetails() != null) existing.setPropertyDetails(leadExtension.getPropertyDetails());
        if (leadExtension.getAutoLoanDetails() != null) existing.setAutoLoanDetails(leadExtension.getAutoLoanDetails());
        if (leadExtension.getMachineryLoanDetails() != null) existing.setMachineryLoanDetails(leadExtension.getMachineryLoanDetails());
        
        LeadExtension updated = repository.save(existing);
        log.info("Updated lead extension: {}", id);
        return updated;
    }
    
    @Transactional
    public void delete(Long id) {
        repository.deleteById(id);
        log.info("Deleted lead extension: {}", id);
    }
}
