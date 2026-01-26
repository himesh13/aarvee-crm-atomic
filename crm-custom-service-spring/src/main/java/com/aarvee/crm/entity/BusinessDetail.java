package com.aarvee.crm.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "business_details", schema = "custom_features")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BusinessDetail {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "lead_extension_id", nullable = false)
    private Long leadExtensionId;
    
    @Column(name = "type_of_employment", length = 100)
    private String typeOfEmployment;
    
    @Column(name = "type_of_industry", length = 100)
    private String typeOfIndustry;
    
    @Column(name = "type_of_business", length = 100)
    private String typeOfBusiness;
    
    @Column(name = "constitution", length = 100)
    private String constitution;
    
    @Column(name = "years_in_business")
    private Integer yearsInBusiness;
    
    @Column(name = "monthly_net_salary")
    private Long monthlyNetSalary;
    
    @Column(name = "other_info", columnDefinition = "TEXT")
    private String otherInfo;
    
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
