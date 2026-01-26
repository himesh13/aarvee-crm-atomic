package com.aarvee.crm.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "property_details", schema = "custom_features")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PropertyDetail {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "lead_extension_id", nullable = false)
    private Long leadExtensionId;
    
    @Column(name = "type_of_property", length = 100)
    private String typeOfProperty;
    
    @Column(name = "is_new_purchase")
    private Boolean isNewPurchase;
    
    @Column(name = "is_builder_purchase")
    private Boolean isBuilderPurchase;
    
    @Column(name = "is_ready_possession")
    private Boolean isReadyPossession;
    
    @Column(name = "classification_of_property", length = 100)
    private String classificationOfProperty;
    
    @Column(name = "property_value")
    private Long propertyValue;
    
    @Column(name = "sell_deed_value")
    private Long sellDeedValue;
    
    @Column(name = "area_of_property", precision = 10, scale = 2)
    private BigDecimal areaOfProperty;
    
    @Column(name = "area_unit", length = 20)
    private String areaUnit;
    
    @Column(name = "age_of_property")
    private Integer ageOfProperty;
    
    @Column(name = "property_address", columnDefinition = "TEXT")
    private String propertyAddress;
    
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
