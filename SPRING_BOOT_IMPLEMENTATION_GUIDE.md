# Spring Boot Backend Implementation Guide

This guide provides step-by-step instructions for implementing a Spring Boot backend for Atomic CRM.

## Table of Contents

1. [Backend Setup](#backend-setup)
2. [Database Schema](#database-schema)
3. [REST API Implementation](#rest-api-implementation)
4. [Authentication](#authentication)
5. [File Storage](#file-storage)
6. [Frontend Integration](#frontend-integration)
7. [Testing](#testing)

## Backend Setup

### 1. Create Spring Boot Project

```bash
# Using Spring Initializr (https://start.spring.io/)
# Or using Spring CLI:
spring init --dependencies=web,data-jpa,security,postgresql,lombok \
  --type=maven-project \
  --java-version=17 \
  --group-id=com.aarvee \
  --artifact-id=crm-backend \
  crm-backend
```

### 2. Project Structure

```
crm-backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/aarvee/crm/
│   │   │       ├── CrmApplication.java
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.java
│   │   │       │   ├── CorsConfig.java
│   │   │       │   └── JwtConfig.java
│   │   │       ├── controller/
│   │   │       │   ├── ContactController.java
│   │   │       │   ├── CompanyController.java
│   │   │       │   ├── DealController.java
│   │   │       │   ├── TaskController.java
│   │   │       │   ├── NoteController.java
│   │   │       │   └── AuthController.java
│   │   │       ├── dto/
│   │   │       │   ├── ContactDTO.java
│   │   │       │   ├── PageResponse.java
│   │   │       │   └── ...
│   │   │       ├── entity/
│   │   │       │   ├── Contact.java
│   │   │       │   ├── Company.java
│   │   │       │   └── ...
│   │   │       ├── repository/
│   │   │       │   ├── ContactRepository.java
│   │   │       │   └── ...
│   │   │       ├── service/
│   │   │       │   ├── ContactService.java
│   │   │       │   └── ...
│   │   │       ├── security/
│   │   │       │   ├── JwtTokenProvider.java
│   │   │       │   └── UserDetailsServiceImpl.java
│   │   │       └── exception/
│   │   │           └── GlobalExceptionHandler.java
│   │   └── resources/
│   │       ├── application.yml
│   │       └── db/migration/
│   │           └── V1__init_schema.sql
│   └── test/
└── pom.xml
```

### 3. Dependencies (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    
    <groupId>com.aarvee</groupId>
    <artifactId>crm-backend</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        
        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Utilities -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- File Storage (AWS S3) -->
        <dependency>
            <groupId>com.amazonaws</groupId>
            <artifactId>aws-java-sdk-s3</artifactId>
            <version>1.12.565</version>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

### 4. Application Configuration (application.yml)

```yaml
spring:
  application:
    name: aarvee-crm
  
  datasource:
    url: jdbc:postgresql://localhost:5432/aarvee_crm
    username: postgres
    password: ${DB_PASSWORD:postgres}
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
  
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration
  
  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 10MB

server:
  port: 8080
  servlet:
    context-path: /api

jwt:
  secret: ${JWT_SECRET:your-secret-key-change-in-production}
  expiration: 86400000  # 24 hours in milliseconds

aws:
  s3:
    bucket-name: ${AWS_S3_BUCKET:aarvee-crm-files}
    region: ${AWS_REGION:us-east-1}
    access-key: ${AWS_ACCESS_KEY}
    secret-key: ${AWS_SECRET_KEY}

cors:
  allowed-origins: ${CORS_ORIGINS:http://localhost:5173}
```

## Database Schema

### Base Entities

#### Contact Entity

```java
package com.aarvee.crm.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Type;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "contacts")
@Data
public class Contact {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "first_name")
    private String firstName;
    
    @Column(name = "last_name")
    private String lastName;
    
    private String gender;
    private String title;
    private String email;
    
    @Column(name = "phone_jsonb", columnDefinition = "jsonb")
    private String phoneJsonb;  // Store as JSON string
    
    private String background;
    
    @Column(name = "avatar", columnDefinition = "jsonb")
    private String avatar;  // Store as JSON string
    
    @Column(name = "first_seen")
    private LocalDateTime firstSeen;
    
    @Column(name = "last_seen")
    private LocalDateTime lastSeen;
    
    @Column(name = "has_newsletter")
    private Boolean hasNewsletter;
    
    private String status;
    
    @Column(name = "linkedin_url")
    private String linkedinUrl;
    
    @ManyToOne
    @JoinColumn(name = "company_id")
    private Company company;
    
    @ManyToOne
    @JoinColumn(name = "sales_id")
    private User sales;
    
    @ElementCollection
    @CollectionTable(name = "contact_tags", joinColumns = @JoinColumn(name = "contact_id"))
    @Column(name = "tag_id")
    private List<Long> tags;
    
    // Custom fields for lead management
    @Column(name = "lead_number")
    private String leadNumber;
    
    private String product;
    
    @Column(name = "loan_amount_required")
    private Long loanAmountRequired;
    
    private String location;
    
    @Column(name = "lead_referred_by")
    private String leadReferredBy;
    
    @Column(name = "lead_status")
    private String leadStatus;  // New, In talk, Logged in, etc.
    
    @Column(name = "business_details", columnDefinition = "jsonb")
    private String businessDetails;  // Store complex business details as JSON
    
    @Column(name = "property_details", columnDefinition = "jsonb")
    private String propertyDetails;  // Store property details as JSON
    
    @Column(name = "auto_loan_details", columnDefinition = "jsonb")
    private String autoLoanDetails;
    
    @Column(name = "machinery_loan_details", columnDefinition = "jsonb")
    private String machineryLoanDetails;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (leadNumber == null) {
            leadNumber = generateLeadNumber();
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    private String generateLeadNumber() {
        // Format: LEAD-YYYYMMDD-XXXXX
        return "LEAD-" + LocalDateTime.now().format(
            java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd")
        ) + "-" + String.format("%05d", id != null ? id : 0);
    }
}
```

#### Company Entity

```java
package com.aarvee.crm.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "companies")
@Data
public class Company {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(columnDefinition = "jsonb")
    private String logo;
    
    private String sector;
    private Integer size;
    
    @Column(name = "linkedin_url")
    private String linkedinUrl;
    
    private String website;
    
    @Column(name = "phone_number")
    private String phoneNumber;
    
    private String address;
    private String zipcode;
    private String city;
    
    @Column(name = "state_abbr")
    private String stateAbbr;
    
    private String country;
    private String description;
    private String revenue;
    
    @Column(name = "tax_identifier")
    private String taxIdentifier;
    
    @ManyToOne
    @JoinColumn(name = "sales_id")
    private User sales;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

#### User Entity (Sales)

```java
package com.aarvee.crm.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.Collections;

@Entity
@Table(name = "sales")
@Data
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "first_name")
    private String firstName;
    
    @Column(name = "last_name")
    private String lastName;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private Boolean administrator = false;
    private Boolean disabled = false;
    
    @Column(columnDefinition = "jsonb")
    private String avatar;
    
    @Column(name = "user_id")
    private String userId;  // UUID from auth system
    
    // UserDetails implementation
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return administrator 
            ? Collections.singletonList(new SimpleGrantedAuthority("ROLE_ADMIN"))
            : Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"));
    }
    
    @Override
    public String getUsername() {
        return email;
    }
    
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
    
    @Override
    public boolean isAccountNonLocked() {
        return !disabled;
    }
    
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
    
    @Override
    public boolean isEnabled() {
        return !disabled;
    }
}
```

## REST API Implementation

### Contact Controller

```java
package com.aarvee.crm.controller;

import com.aarvee.crm.dto.*;
import com.aarvee.crm.service.ContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/contacts")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class ContactController {
    
    private final ContactService contactService;
    
    @GetMapping
    public ResponseEntity<PageResponse<ContactDTO>> getContacts(
            @RequestParam(required = false) String filter,
            @RequestParam(required = false) String sort,
            Pageable pageable) {
        Page<ContactDTO> contacts = contactService.getContacts(filter, sort, pageable);
        
        return ResponseEntity.ok(PageResponse.<ContactDTO>builder()
            .data(contacts.getContent())
            .total(contacts.getTotalElements())
            .page(contacts.getNumber())
            .pageSize(contacts.getSize())
            .build());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ContactDTO> getContact(@PathVariable Long id) {
        return ResponseEntity.ok(contactService.getContact(id));
    }
    
    @PostMapping
    public ResponseEntity<ContactDTO> createContact(@RequestBody ContactDTO contactDTO) {
        return ResponseEntity.ok(contactService.createContact(contactDTO));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ContactDTO> updateContact(
            @PathVariable Long id, 
            @RequestBody ContactDTO contactDTO) {
        return ResponseEntity.ok(contactService.updateContact(id, contactDTO));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteContact(@PathVariable Long id) {
        contactService.deleteContact(id);
        return ResponseEntity.noContent().build();
    }
}
```

### Contact Service

```java
package com.aarvee.crm.service;

import com.aarvee.crm.dto.ContactDTO;
import com.aarvee.crm.entity.Contact;
import com.aarvee.crm.repository.ContactRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ContactService {
    
    private final ContactRepository contactRepository;
    
    public Page<ContactDTO> getContacts(String filter, String sort, Pageable pageable) {
        Specification<Contact> spec = buildSpecification(filter);
        return contactRepository.findAll(spec, pageable)
            .map(this::toDTO);
    }
    
    public ContactDTO getContact(Long id) {
        Contact contact = contactRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Contact not found"));
        return toDTO(contact);
    }
    
    public ContactDTO createContact(ContactDTO dto) {
        Contact contact = toEntity(dto);
        contact = contactRepository.save(contact);
        return toDTO(contact);
    }
    
    public ContactDTO updateContact(Long id, ContactDTO dto) {
        Contact contact = contactRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Contact not found"));
        updateEntityFromDTO(contact, dto);
        contact = contactRepository.save(contact);
        return toDTO(contact);
    }
    
    public void deleteContact(Long id) {
        contactRepository.deleteById(id);
    }
    
    private ContactDTO toDTO(Contact contact) {
        // Map entity to DTO
        ContactDTO dto = new ContactDTO();
        dto.setId(contact.getId());
        dto.setFirstName(contact.getFirstName());
        dto.setLastName(contact.getLastName());
        // ... map other fields
        return dto;
    }
    
    private Contact toEntity(ContactDTO dto) {
        Contact contact = new Contact();
        updateEntityFromDTO(contact, dto);
        return contact;
    }
    
    private void updateEntityFromDTO(Contact contact, ContactDTO dto) {
        contact.setFirstName(dto.getFirstName());
        contact.setLastName(dto.getLastName());
        // ... update other fields
    }
    
    private Specification<Contact> buildSpecification(String filter) {
        // Parse filter string and build JPA Specification
        // Example: first_name@eq=John -> firstName equals "John"
        return (root, query, cb) -> {
            // Implementation depends on your filter format
            return cb.conjunction();
        };
    }
}
```

### Page Response DTO

```java
package com.aarvee.crm.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class PageResponse<T> {
    private List<T> data;
    private long total;
    private int page;
    private int pageSize;
}
```

## Authentication

### Security Configuration

```java
package com.aarvee.crm.config;

import com.aarvee.crm.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, 
                UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
```

### JWT Token Provider

```java
package com.aarvee.crm.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private long jwtExpirationMs;
    
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }
    
    public String generateToken(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);
        
        return Jwts.builder()
                .setSubject(userDetails.getUsername())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }
    
    public String getUsernameFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        
        return claims.getSubject();
    }
    
    public boolean validateToken(String authToken) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(authToken);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

### Auth Controller

```java
package com.aarvee.crm.controller;

import com.aarvee.crm.dto.LoginRequest;
import com.aarvee.crm.dto.LoginResponse;
import com.aarvee.crm.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getEmail(),
                request.getPassword()
            )
        );
        
        String token = tokenProvider.generateToken(authentication);
        
        return ResponseEntity.ok(LoginResponse.builder()
            .token(token)
            .type("Bearer")
            .build());
    }
}
```

## File Storage

### File Storage Service (S3 Example)

```java
package com.aarvee.crm.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileStorageService {
    
    private final AmazonS3 amazonS3;
    
    @Value("${aws.s3.bucket-name}")
    private String bucketName;
    
    public String uploadFile(MultipartFile file) throws IOException {
        String fileName = generateFileName(file.getOriginalFilename());
        
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        
        amazonS3.putObject(new PutObjectRequest(
            bucketName,
            fileName,
            file.getInputStream(),
            metadata
        ));
        
        return amazonS3.getUrl(bucketName, fileName).toString();
    }
    
    public void deleteFile(String fileUrl) {
        String fileName = extractFileNameFromUrl(fileUrl);
        amazonS3.deleteObject(bucketName, fileName);
    }
    
    private String generateFileName(String originalFilename) {
        String extension = originalFilename.substring(
            originalFilename.lastIndexOf(".")
        );
        return UUID.randomUUID().toString() + extension;
    }
    
    private String extractFileNameFromUrl(String url) {
        return url.substring(url.lastIndexOf("/") + 1);
    }
}
```

## Frontend Integration

### Create Spring Boot Data Provider

Create file: `src/components/atomic-crm/providers/springboot/dataProvider.ts`

```typescript
import {
  DataProvider,
  GetListParams,
  GetOneParams,
  CreateParams,
  UpdateParams,
  DeleteParams,
  GetManyParams,
  GetManyReferenceParams,
} from "ra-core";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

const getAuthToken = () => {
  return localStorage.getItem("authToken");
};

const fetchJson = async (url: string, options: RequestInit = {}) => {
  const token = getAuthToken();
  const headers = {
    "Content-Type": "application/json",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const response = await fetch(url, { ...options, headers });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
};

export const springBootDataProvider: DataProvider = {
  getList: async (resource: string, params: GetListParams) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;
    const filter = params.filter;

    // Build query string
    const query = new URLSearchParams({
      page: String(page - 1), // Spring uses 0-based pagination
      size: String(perPage),
      sort: `${field},${order.toLowerCase()}`,
    });

    // Add filters
    Object.keys(filter).forEach((key) => {
      if (filter[key] !== undefined && filter[key] !== "") {
        query.append(key, filter[key]);
      }
    });

    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);

    return {
      data: json.data,
      total: json.total,
    };
  },

  getOne: async (resource: string, params: GetOneParams) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const json = await fetchJson(url);
    return { data: json };
  },

  getMany: async (resource: string, params: GetManyParams) => {
    const query = new URLSearchParams();
    params.ids.forEach((id) => query.append("ids", String(id)));

    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);
    return { data: json.data };
  },

  getManyReference: async (resource: string, params: GetManyReferenceParams) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;

    const query = new URLSearchParams({
      page: String(page - 1),
      size: String(perPage),
      sort: `${field},${order.toLowerCase()}`,
      [params.target]: String(params.id),
    });

    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);

    return {
      data: json.data,
      total: json.total,
    };
  },

  create: async (resource: string, params: CreateParams) => {
    const url = `${API_BASE_URL}/${resource}`;
    const json = await fetchJson(url, {
      method: "POST",
      body: JSON.stringify(params.data),
    });
    return { data: json };
  },

  update: async (resource: string, params: UpdateParams) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const json = await fetchJson(url, {
      method: "PUT",
      body: JSON.stringify(params.data),
    });
    return { data: json };
  },

  updateMany: async (resource: string, params: any) => {
    const results = await Promise.all(
      params.ids.map((id: any) =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, {
          method: "PUT",
          body: JSON.stringify(params.data),
        })
      )
    );
    return { data: results.map((json) => json.id) };
  },

  delete: async (resource: string, params: DeleteParams) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    await fetchJson(url, { method: "DELETE" });
    return { data: params.previousData as any };
  },

  deleteMany: async (resource: string, params: any) => {
    await Promise.all(
      params.ids.map((id: any) =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, {
          method: "DELETE",
        })
      )
    );
    return { data: params.ids };
  },
};
```

### Create Spring Boot Auth Provider

Create file: `src/components/atomic-crm/providers/springboot/authProvider.ts`

```typescript
import { AuthProvider } from "ra-core";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

export const springBootAuthProvider: AuthProvider = {
  login: async ({ username, password }) => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email: username, password }),
    });

    if (!response.ok) {
      throw new Error("Invalid credentials");
    }

    const { token } = await response.json();
    localStorage.setItem("authToken", token);
  },

  logout: async () => {
    localStorage.removeItem("authToken");
    localStorage.removeItem("userIdentity");
  },

  checkAuth: async () => {
    const token = localStorage.getItem("authToken");
    if (!token) {
      throw new Error("Not authenticated");
    }
  },

  checkError: async (error) => {
    const status = error.status;
    if (status === 401 || status === 403) {
      localStorage.removeItem("authToken");
      throw new Error("Unauthorized");
    }
  },

  getIdentity: async () => {
    const cached = localStorage.getItem("userIdentity");
    if (cached) {
      return JSON.parse(cached);
    }

    const token = localStorage.getItem("authToken");
    if (!token) {
      throw new Error("Not authenticated");
    }

    const response = await fetch(`${API_BASE_URL}/auth/me`, {
      headers: { Authorization: `Bearer ${token}` },
    });

    const identity = await response.json();
    localStorage.setItem("userIdentity", JSON.stringify(identity));
    return identity;
  },

  getPermissions: async () => {
    const identity = await springBootAuthProvider.getIdentity!();
    return identity.administrator ? ["admin"] : ["user"];
  },
};
```

### Create index file

Create file: `src/components/atomic-crm/providers/springboot/index.ts`

```typescript
export { springBootDataProvider as dataProvider } from "./dataProvider";
export { springBootAuthProvider as authProvider } from "./authProvider";
```

### Update App.tsx

```typescript
import { CRM } from "@/components/atomic-crm/root/CRM";
import { dataProvider, authProvider } from "@/components/atomic-crm/providers/springboot";

const App = () => (
  <CRM 
    dataProvider={dataProvider}
    authProvider={authProvider}
  />
);

export default App;
```

### Update Environment Variables

Create `.env.local`:

```env
VITE_API_BASE_URL=http://localhost:8080/api
```

## Testing

### Backend Testing

```java
package com.aarvee.crm.controller;

import com.aarvee.crm.dto.ContactDTO;
import com.aarvee.crm.service.ContactService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ContactControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private ContactService contactService;
    
    @Test
    @WithMockUser
    void testGetContacts() throws Exception {
        mockMvc.perform(get("/contacts"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }
    
    @Test
    @WithMockUser
    void testCreateContact() throws Exception {
        ContactDTO dto = new ContactDTO();
        dto.setFirstName("John");
        dto.setLastName("Doe");
        
        when(contactService.createContact(any())).thenReturn(dto);
        
        mockMvc.perform(post("/contacts")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"firstName\":\"John\",\"lastName\":\"Doe\"}"))
                .andExpect(status().isOk());
    }
}
```

## Deployment

### Docker Configuration

Create `Dockerfile`:

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: aarvee_crm
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/aarvee_crm
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: postgres
      JWT_SECRET: your-secret-key
    depends_on:
      - postgres

volumes:
  postgres_data:
```

### Build and Run

```bash
# Build the application
mvn clean package

# Run with Docker Compose
docker-compose up -d

# Or run directly
java -jar target/crm-backend-1.0.0.jar
```

## Next Steps

1. **Test the integration**: Start both frontend and backend and test basic operations
2. **Implement custom fields**: Add the fields specific to your requirements (Level 1, 2, 3)
3. **Add file upload**: Implement file upload for attachments
4. **Implement reminders**: Add birthday and loan topup reminders
5. **Add export functionality**: Implement PDF/Word export
6. **Deploy to production**: Set up CI/CD and deploy to your hosting environment

## Support

For issues or questions:
- Check the [Atomic CRM documentation](https://github.com/marmelab/atomic-crm)
- Review the [Spring Boot documentation](https://spring.io/projects/spring-boot)
- Open an issue in your repository
