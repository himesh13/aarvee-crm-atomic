package com.aarvee.crm.repository;

import com.aarvee.crm.entity.LeadExtension;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LeadExtensionRepository extends JpaRepository<LeadExtension, Long> {
    List<LeadExtension> findByLeadNumberStartingWith(String prefix);
    long countByLeadNumberStartingWith(String prefix);
}
