package com.aarvee.crm.util;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicLong;

public final class SortParamMapper {

    private static final Map<String, String> MAPPINGS = new HashMap<>();
    private static final Set<String> ALLOWED = new HashSet<>(Arrays.asList(
        "id",
        "contactId",
        "leadNumber",
        "customerName",
        "contactNumber",
        "product",
        "loanAmountRequired",
        "location",
        "leadReferredBy",
        "leadAssignedTo",
        "leadStatus",
        "createdAt",
        "updatedAt"
    ));

    // Simple in-memory metric to count invalid sort requests
    private static final AtomicLong INVALID_SORT_COUNT = new AtomicLong(0);

    static {
        MAPPINGS.put("created", "createdAt");
        MAPPINGS.put("created_at", "createdAt");
        MAPPINGS.put("createdAt", "createdAt");

        MAPPINGS.put("updated", "updatedAt");
        MAPPINGS.put("updated_at", "updatedAt");
        MAPPINGS.put("updatedAt", "updatedAt");

        MAPPINGS.put("lead_number", "leadNumber");
        MAPPINGS.put("leadNumber", "leadNumber");

        // common UI tokens
        MAPPINGS.put("name", "customerName");
        MAPPINGS.put("nb_contacts", "nbContacts"); // if used elsewhere; keep defensive
    }

    private SortParamMapper() {
        // utility
    }

    public static String map(String clientField) {
        if (clientField == null || clientField.isBlank()) return "createdAt";

        String normalized = MAPPINGS.get(clientField);
        if (normalized != null) return normalized;

        // Try simple snake_case to camelCase conversion
        if (clientField.contains("_")) {
            StringBuilder sb = new StringBuilder();
            String[] parts = clientField.split("_");
            sb.append(parts[0]);
            for (int i = 1; i < parts.length; i++) {
                if (parts[i].length() > 0) {
                    sb.append(parts[i].substring(0, 1).toUpperCase()).append(parts[i].substring(1));
                }
            }
            String converted = sb.toString();
            if (ALLOWED.contains(converted)) return converted;
        }

        // If clientField already looks like a camelCase property, check allowed
        if (ALLOWED.contains(clientField)) return clientField;

        // Not allowed
        return null;
    }

    public static String[] ALLOWED_FIELDS() {
        String[] arr = ALLOWED.toArray(new String[0]);
        Arrays.sort(arr);
        return arr;
    }

    public static Set<String> allowedSet() {
        return Collections.unmodifiableSet(ALLOWED);
    }

    public static void incrementInvalidCount() {
        INVALID_SORT_COUNT.incrementAndGet();
    }

    public static long getInvalidSortCount() {
        return INVALID_SORT_COUNT.get();
    }
}
