package com.aarvee.crm.repository;

import com.aarvee.crm.entity.BusinessDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusinessDetailRepository extends JpaRepository<BusinessDetail, Long> {
}
