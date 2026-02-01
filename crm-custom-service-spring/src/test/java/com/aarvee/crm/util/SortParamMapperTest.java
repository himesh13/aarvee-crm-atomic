package com.aarvee.crm.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class SortParamMapperTest {

    @Test
    void mapsCreatedAtVariants() {
        assertEquals("createdAt", SortParamMapper.map("created_at"));
        assertEquals("createdAt", SortParamMapper.map("created"));
        assertEquals("createdAt", SortParamMapper.map("createdAt"));
    }

    @Test
    void mapsLeadNumberVariants() {
        assertEquals("leadNumber", SortParamMapper.map("lead_number"));
        assertEquals("leadNumber", SortParamMapper.map("leadNumber"));
    }

    @Test
    void returnsNullForUnknown() {
        assertNull(SortParamMapper.map("__inject;DROP TABLE users;"));
        assertNull(SortParamMapper.map("someRandomField"));
    }

    @Test
    void defaultsToCreatedAtWhenNullOrBlank() {
        assertEquals("createdAt", SortParamMapper.map(null));
        assertEquals("createdAt", SortParamMapper.map(""));
        assertEquals("createdAt", SortParamMapper.map("  "));
    }
}
