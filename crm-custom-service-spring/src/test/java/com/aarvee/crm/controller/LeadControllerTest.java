package com.aarvee.crm.controller;

import com.aarvee.crm.entity.LeadExtension;
import com.aarvee.crm.service.LeadExtensionService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = LeadController.class)
class LeadControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LeadExtensionService service;

    @Test
    void getList_withValidSortField_returns200() throws Exception {
        Page<LeadExtension> emptyPage = new PageImpl<>(Collections.emptyList());
        Mockito.when(service.getList(Mockito.anyInt(), Mockito.anyInt(), Mockito.eq("createdAt"), Mockito.anyString()))
            .thenReturn(emptyPage);

        mockMvc.perform(get("/api/leads?page=1&perPage=10&sortField=createdAt&sortOrder=desc")
            .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk());
    }

    @Test
    void getList_withInvalidSortField_returns400() throws Exception {
        mockMvc.perform(get("/api/leads?page=1&perPage=10&sortField=__badfield__&sortOrder=desc")
            .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isBadRequest());
    }
}
