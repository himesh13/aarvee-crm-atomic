package com.aarvee.crm.config;

import com.aarvee.crm.entity.LeadExtension;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.json.JsonTest;
import org.springframework.context.annotation.Import;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Test to verify Jackson configuration serializes entity fields to snake_case.
 */
@JsonTest
@Import(JacksonConfig.class)
class JacksonConfigTest {

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testLeadExtensionSerializesToSnakeCase() throws Exception {
        // Create a LeadExtension with camelCase field names
        LeadExtension lead = new LeadExtension();
        lead.setId(1L);
        lead.setLeadNumber("LEAD-12345");
        lead.setCustomerName("John Doe");
        lead.setContactNumber("555-1234");
        lead.setProduct("Home Loan");
        lead.setLoanAmountRequired(new BigDecimal("500000.00"));
        lead.setLocation("New York");
        lead.setLeadReferredBy("Friend");
        lead.setShortDescription("Test lead description");
        lead.setLeadStatus("new");

        // Serialize to JSON
        String json = objectMapper.writeValueAsString(lead);

        // Verify JSON contains snake_case field names
        assertThat(json).contains("\"customer_name\":\"John Doe\"");
        assertThat(json).contains("\"contact_number\":\"555-1234\"");
        assertThat(json).contains("\"lead_number\":\"LEAD-12345\"");
        assertThat(json).contains("\"loan_amount_required\":500000.00");
        assertThat(json).contains("\"lead_referred_by\":\"Friend\"");
        assertThat(json).contains("\"short_description\":\"Test lead description\"");
        assertThat(json).contains("\"lead_status\":\"new\"");

        // Verify JSON does NOT contain camelCase field names
        assertThat(json).doesNotContain("customerName");
        assertThat(json).doesNotContain("contactNumber");
        assertThat(json).doesNotContain("leadNumber");
        assertThat(json).doesNotContain("loanAmountRequired");
        assertThat(json).doesNotContain("leadReferredBy");
        assertThat(json).doesNotContain("shortDescription");
        assertThat(json).doesNotContain("leadStatus");
    }

    @Test
    void testLeadExtensionDeserializesFromSnakeCase() throws Exception {
        // JSON with snake_case field names
        String json = """
            {
                "id": 1,
                "lead_number": "LEAD-12345",
                "customer_name": "John Doe",
                "contact_number": "555-1234",
                "product": "Home Loan",
                "loan_amount_required": 500000.00,
                "location": "New York",
                "lead_referred_by": "Friend",
                "short_description": "Test lead description",
                "lead_status": "new"
            }
            """;

        // Deserialize from JSON
        LeadExtension lead = objectMapper.readValue(json, LeadExtension.class);

        // Verify all fields are correctly populated
        assertThat(lead.getId()).isEqualTo(1L);
        assertThat(lead.getLeadNumber()).isEqualTo("LEAD-12345");
        assertThat(lead.getCustomerName()).isEqualTo("John Doe");
        assertThat(lead.getContactNumber()).isEqualTo("555-1234");
        assertThat(lead.getProduct()).isEqualTo("Home Loan");
        assertThat(lead.getLoanAmountRequired()).isEqualByComparingTo(new BigDecimal("500000.00"));
        assertThat(lead.getLocation()).isEqualTo("New York");
        assertThat(lead.getLeadReferredBy()).isEqualTo("Friend");
        assertThat(lead.getShortDescription()).isEqualTo("Test lead description");
        assertThat(lead.getLeadStatus()).isEqualTo("new");
    }
}
