# Lead Display - Before and After Comparison

## Visual Comparison

### Before Fix ❌
```
┌─────────────────────────────────────────────────────┐
│ Lead List                                            │
├─────────────────────────────────────────────────────┤
│                                                      │
│ Lead #1                                             │
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Lead Number:    │ Customer Name:  │ Contact:    ││
│ │ (empty)         │ (empty)         │ (empty)     ││
│ └─────────────────┴─────────────────┴─────────────┘│
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Product:        │ Loan Amount:    │ Status:     ││
│ │ Home Loan ✓     │ (empty)         │ (empty)     ││
│ └─────────────────┴─────────────────┴─────────────┘│
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Location:       │ Referred By:    │ Created:    ││
│ │ New York ✓      │ (empty)         │ (empty)     ││
│ └─────────────────┴─────────────────┴─────────────┘│
│                                                      │
│ Only 2 out of 10 fields are visible!                │
└─────────────────────────────────────────────────────┘
```

**Why?**
Backend sent JSON like:
```json
{
  "id": 1,
  "leadNumber": "LEAD-A1B2C",           ← camelCase (Frontend expected lead_number)
  "customerName": "John Doe",            ← camelCase (Frontend expected customer_name)
  "contactNumber": "555-1234",           ← camelCase (Frontend expected contact_number)
  "product": "Home Loan",                ← Single word, worked! ✓
  "loanAmountRequired": 500000,          ← camelCase (Frontend expected loan_amount_required)
  "location": "New York",                ← Single word, worked! ✓
  "leadReferredBy": "Friend",            ← camelCase (Frontend expected lead_referred_by)
  "shortDescription": "Test lead",       ← camelCase (Frontend expected short_description)
  "leadStatus": "new",                   ← camelCase (Frontend expected lead_status)
  "createdAt": "2024-01-15T10:30:00Z",  ← camelCase (Frontend expected created_at)
  "updatedAt": "2024-01-15T10:30:00Z"   ← camelCase (Frontend expected updated_at)
}
```

Frontend tried to read:
```tsx
<TextField source="customer_name" />  // Looking for 'customer_name' in JSON
<TextField source="contact_number" /> // Looking for 'contact_number' in JSON
```

But JSON only had `customerName` and `contactNumber`, so fields appeared empty!

---

### After Fix ✅
```
┌─────────────────────────────────────────────────────┐
│ Lead List                                            │
├─────────────────────────────────────────────────────┤
│                                                      │
│ Lead #1                                             │
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Lead Number:    │ Customer Name:  │ Contact:    ││
│ │ LEAD-A1B2C ✓    │ John Doe ✓      │ 555-1234 ✓  ││
│ └─────────────────┴─────────────────┴─────────────┘│
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Product:        │ Loan Amount:    │ Status:     ││
│ │ Home Loan ✓     │ $500,000 ✓      │ New ✓       ││
│ └─────────────────┴─────────────────┴─────────────┘│
│ ┌─────────────────┬─────────────────┬─────────────┐│
│ │ Location:       │ Referred By:    │ Created:    ││
│ │ New York ✓      │ Friend ✓        │ 01/15/24 ✓  ││
│ └─────────────────┴─────────────────┴─────────────┘│
│ ┌───────────────────────────────────────────────── │
│ │ Description: Test lead                          ││
│ └───────────────────────────────────────────────── │
│                                                      │
│ All 10 fields are now visible! ✓                    │
└─────────────────────────────────────────────────────┘
```

**Why it works now:**
Backend sends JSON like:
```json
{
  "id": 1,
  "lead_number": "LEAD-A1B2C",           ← snake_case ✓
  "customer_name": "John Doe",            ← snake_case ✓
  "contact_number": "555-1234",           ← snake_case ✓
  "product": "Home Loan",                 ← Still works ✓
  "loan_amount_required": 500000,         ← snake_case ✓
  "location": "New York",                 ← Still works ✓
  "lead_referred_by": "Friend",           ← snake_case ✓
  "short_description": "Test lead",       ← snake_case ✓
  "lead_status": "new",                   ← snake_case ✓
  "created_at": "2024-01-15T10:30:00Z",  ← snake_case ✓
  "updated_at": "2024-01-15T10:30:00Z"   ← snake_case ✓
}
```

Frontend can now successfully read all fields:
```tsx
<TextField source="customer_name" />  // Found 'customer_name' in JSON ✓
<TextField source="contact_number" /> // Found 'contact_number' in JSON ✓
<TextField source="lead_number" />    // Found 'lead_number' in JSON ✓
// ... all other fields work now!
```

## Technical Details

### The Solution
Added one configuration file in Spring Boot:

```java
@Configuration
public class JacksonConfig {
    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jsonCustomizer() {
        return builder -> builder
            .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE);
    }
}
```

This tells Jackson (the JSON library):
- When converting Java objects to JSON: use snake_case
- When converting JSON to Java objects: accept snake_case

### Impact on Other Entities
The fix applies to ALL entities in the custom service:
- ✅ LeadExtension (leads)
- ✅ BusinessDetail (business_details)
- ✅ PropertyDetail (property_details)
- ✅ Reminder (reminders)

### Why This is the Right Solution
1. **Database uses snake_case**: PostgreSQL columns are `customer_name`, `contact_number`, etc.
2. **Frontend expects snake_case**: TypeScript types and components use snake_case
3. **Consistency**: Now the entire stack uses one convention
4. **Minimal change**: Only one config file, no changes to entity classes or frontend
5. **Standards**: snake_case is the standard for JSON APIs (per most style guides)

## Data Flow Comparison

### Before (Broken)
```
Database (snake_case)
    ↓
Java Entity (camelCase fields)
    ↓
Jackson (default) → JSON (camelCase)
    ↓
Frontend expects (snake_case) ← MISMATCH! ❌
```

### After (Fixed)
```
Database (snake_case)
    ↓
Java Entity (camelCase fields)
    ↓
Jackson (configured) → JSON (snake_case)
    ↓
Frontend expects (snake_case) ← MATCH! ✓
```

## Verification Checklist

When testing, verify these fields are visible:
- [ ] Lead Number (e.g., "LEAD-A1B2C")
- [ ] Customer Name (e.g., "John Doe")
- [ ] Contact Number (e.g., "555-1234")
- [ ] Product (e.g., "Home Loan")
- [ ] Loan Amount (e.g., "500000")
- [ ] Status (e.g., "new")
- [ ] Location (e.g., "New York")
- [ ] Referred By (e.g., "Friend")
- [ ] Description (if provided)
- [ ] Created timestamp

All should now display correctly! ✓
