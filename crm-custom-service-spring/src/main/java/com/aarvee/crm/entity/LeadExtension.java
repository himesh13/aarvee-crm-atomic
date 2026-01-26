package com.aarvee.crm.entity;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Entity
@Table(name = "lead_extensions", schema = "custom_features")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LeadExtension {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "contact_id", nullable = false)
    private Long contactId;
    
    @Column(name = "lead_number", unique = true, nullable = false, length = 50)
    private String leadNumber;
    
    @Column(name = "product", length = 255)
    private String product;
    
    @Column(name = "loan_amount_required")
    private Long loanAmountRequired;
    
    @Column(name = "location", length = 500)
    private String location;
    
    @Column(name = "lead_referred_by", length = 255)
    private String leadReferredBy;
    
    @Column(name = "short_description", columnDefinition = "TEXT")
    private String shortDescription;
    
    @Column(name = "lead_assigned_to")
    private Long leadAssignedTo;
    
    @Column(name = "lead_status", length = 50)
    private String leadStatus;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "business_details", columnDefinition = "jsonb")
    private JsonNode businessDetails;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "property_details", columnDefinition = "jsonb")
    private JsonNode propertyDetails;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "auto_loan_details", columnDefinition = "jsonb")
    private JsonNode autoLoanDetails;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "machinery_loan_details", columnDefinition = "jsonb")
    private JsonNode machineryLoanDetails;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
