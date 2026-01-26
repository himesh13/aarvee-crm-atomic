package com.aarvee.crm.repository;

import com.aarvee.crm.entity.PropertyDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PropertyDetailRepository extends JpaRepository<PropertyDetail, Long> {
}
