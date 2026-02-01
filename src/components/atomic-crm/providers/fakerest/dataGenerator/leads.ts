import {
  company as fakerCompany,
  datatype,
  date,
  lorem,
  name,
  phone,
  random,
  address,
} from "faker/locale/en_US";

import type { Lead } from "../../../types";
import type { Db } from "./types";

export const generateLeads = (db: Db): Lead[] => {
  const leads: Lead[] = [];
  const leadStages = [
    "new",
    "contacted",
    "qualified",
    "proposal-sent",
    "negotiation",
    "won",
    "lost",
  ];
  const products = [
    "Home Loan",
    "Personal Loan",
    "Business Loan",
    "Auto Loan",
    "Machinery Loan",
    "Education Loan",
  ];

  // Generate 30-50 leads
  const nbLeads = datatype.number({ min: 30, max: 50 });

  for (let i = 0; i < nbLeads; i++) {
    const firstName = name.firstName();
    const lastName = name.lastName();
    const stage = random.arrayElement(leadStages);
    
    // Generate stage-specific index
    const stageLeads = leads.filter(lead => lead.stage === stage);
    const index = stageLeads.length;

    leads.push({
      id: i + 1,
      lead_number: `LD-${String(i + 1).padStart(5, "0")}`,
      customer_name: `${firstName} ${lastName}`,
      contact_number: phone.phoneNumber(),
      product: random.arrayElement(products),
      loan_amount_required: datatype.number({ min: 100000, max: 10000000 }),
      location: address.city(),
      lead_referred_by: Math.random() > 0.7 ? name.findName() : undefined,
      short_description: Math.random() > 0.5 ? lorem.sentence() : undefined,
      lead_status: random.arrayElement([
        "pending",
        "processing",
        "approved",
        "rejected",
      ]),
      stage,
      index,
      created_at: date
        .between(
          new Date(Date.now() - 90 * 24 * 60 * 60 * 1000),
          new Date(),
        )
        .toISOString(),
      updated_at: new Date().toISOString(),
    });
  }

  return leads;
};
