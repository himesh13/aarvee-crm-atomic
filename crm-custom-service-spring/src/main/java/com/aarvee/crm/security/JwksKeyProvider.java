package com.aarvee.crm.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Header;
import io.jsonwebtoken.Locator;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigInteger;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.Key;
import java.security.KeyFactory;
import java.security.spec.ECPublicKeySpec;
import java.security.spec.RSAPublicKeySpec;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Fetches and caches public keys from Supabase's JWKS endpoint for JWT validation.
 * Supports both RSA and EC (Elliptic Curve) keys.
 */
@Component
@Slf4j
public class JwksKeyProvider implements Locator<Key> {
    
    @Value("${supabase.auth.url:http://127.0.0.1:54321/auth/v1}")
    private String supabaseAuthUrl;
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final Map<String, Key> keyCache = new ConcurrentHashMap<>();
    private volatile long lastFetchTime = 0;
    private static final long CACHE_DURATION_MS = 3600000; // 1 hour
    
    @Override
    public Key locate(Header header) {
        String kid = header.get("kid", String.class);
        if (kid == null) {
            log.warn("No 'kid' (Key ID) found in JWT header");
            return null;
        }
        
        // Check cache first
        Key cachedKey = keyCache.get(kid);
        if (cachedKey != null && System.currentTimeMillis() - lastFetchTime < CACHE_DURATION_MS) {
            return cachedKey;
        }
        
        // Fetch from JWKS endpoint
        try {
            fetchAndCacheKeys();
            return keyCache.get(kid);
        } catch (Exception e) {
            log.error("Failed to fetch JWKS keys", e);
            return null;
        }
    }
    
    private synchronized void fetchAndCacheKeys() throws Exception {
        // Double-check to avoid redundant fetches
        if (System.currentTimeMillis() - lastFetchTime < CACHE_DURATION_MS) {
            return;
        }
        
        String jwksUrl = supabaseAuthUrl + "/.well-known/jwks.json";
        log.info("Fetching JWKS from: {}", jwksUrl);
        
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(jwksUrl))
            .GET()
            .build();
        
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        
        if (response.statusCode() != 200) {
            throw new RuntimeException("Failed to fetch JWKS: HTTP " + response.statusCode());
        }
        
        JsonNode jwks = objectMapper.readTree(response.body());
        JsonNode keys = jwks.get("keys");
        
        if (keys == null || !keys.isArray()) {
            throw new RuntimeException("Invalid JWKS response: no 'keys' array");
        }
        
        keyCache.clear();
        
        for (JsonNode keyNode : keys) {
            String kid = keyNode.get("kid").asText();
            String kty = keyNode.get("kty").asText(); // Key type: RSA or EC
            
            Key publicKey;
            if ("RSA".equals(kty)) {
                publicKey = parseRSAKey(keyNode);
            } else if ("EC".equals(kty)) {
                publicKey = parseECKey(keyNode);
            } else {
                log.warn("Unsupported key type: {}", kty);
                continue;
            }
            
            keyCache.put(kid, publicKey);
            log.info("Cached public key with kid: {} (type: {})", kid, kty);
        }
        
        lastFetchTime = System.currentTimeMillis();
    }
    
    private Key parseRSAKey(JsonNode keyNode) throws Exception {
        String n = keyNode.get("n").asText(); // Modulus
        String e = keyNode.get("e").asText(); // Exponent
        
        BigInteger modulus = new BigInteger(1, Base64.getUrlDecoder().decode(n));
        BigInteger exponent = new BigInteger(1, Base64.getUrlDecoder().decode(e));
        
        RSAPublicKeySpec spec = new RSAPublicKeySpec(modulus, exponent);
        KeyFactory factory = KeyFactory.getInstance("RSA");
        return factory.generatePublic(spec);
    }
    
    private Key parseECKey(JsonNode keyNode) throws Exception {
        String crv = keyNode.get("crv").asText(); // Curve name
        String x = keyNode.get("x").asText();     // X coordinate
        String y = keyNode.get("y").asText();     // Y coordinate
        
        // Map the curve name to Java's algorithm parameters
        String curveName;
        switch (crv) {
            case "P-256":
                curveName = "secp256r1";
                break;
            case "P-384":
                curveName = "secp384r1";
                break;
            case "P-521":
                curveName = "secp521r1";
                break;
            default:
                throw new IllegalArgumentException("Unsupported curve: " + crv);
        }
        
        byte[] xBytes = Base64.getUrlDecoder().decode(x);
        byte[] yBytes = Base64.getUrlDecoder().decode(y);
        
        BigInteger xCoord = new BigInteger(1, xBytes);
        BigInteger yCoord = new BigInteger(1, yBytes);
        
        // Get the curve parameters
        java.security.spec.ECParameterSpec ecParams = 
            java.security.AlgorithmParameters.getInstance("EC")
                .getParameterSpec(java.security.spec.ECParameterSpec.class);
        
        // Create the EC point
        java.security.spec.ECPoint point = new java.security.spec.ECPoint(xCoord, yCoord);
        
        // For simplicity, we'll use a common approach with Bouncy Castle or standard Java
        // Since we're on Java 17+, we can use the standard library
        ECPublicKeySpec spec = new ECPublicKeySpec(point, 
            getECParameterSpec(curveName));
        
        KeyFactory factory = KeyFactory.getInstance("EC");
        return factory.generatePublic(spec);
    }
    
    private java.security.spec.ECParameterSpec getECParameterSpec(String curveName) throws Exception {
        java.security.AlgorithmParameters parameters = java.security.AlgorithmParameters.getInstance("EC");
        parameters.init(new java.security.spec.ECGenParameterSpec(curveName));
        return parameters.getParameterSpec(java.security.spec.ECParameterSpec.class);
    }
}
