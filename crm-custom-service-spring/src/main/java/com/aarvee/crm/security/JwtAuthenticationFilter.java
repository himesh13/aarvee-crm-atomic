package com.aarvee.crm.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;

@Component
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private final JwksKeyProvider jwksKeyProvider;
    
    @Value("${supabase.auth.url:http://127.0.0.1:54321/auth/v1}")
    private String supabaseAuthUrl;
    
    public JwtAuthenticationFilter(JwksKeyProvider jwksKeyProvider) {
        this.jwksKeyProvider = jwksKeyProvider;
    }
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        String authHeader = request.getHeader("Authorization");
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            
            try {
                // Parse the JWT using the JWKS key provider
                Claims claims = Jwts.parser()
                    .keyLocator(jwksKeyProvider)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
                
                String userId = claims.getSubject();
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(userId, null, new ArrayList<>());
                SecurityContextHolder.getContext().setAuthentication(authentication);
                
            } catch (Exception e) {
                log.error("JWT token validation failed: {}", e.getMessage());
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
