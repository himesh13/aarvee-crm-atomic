import type {
  Company,
  Contact,
  ContactNote,
  Deal,
  DealNote,
  Lead,
  Sale,
  Tag,
  Task,
} from "../../../types";

export interface Db {
  companies: Required<Company>[];
  contacts: Required<Contact>[];
  contact_notes: ContactNote[];
  deals: Deal[];
  deal_notes: DealNote[];
  leads: Lead[];
  sales: Sale[];
  tags: Tag[];
  tasks: Task[];
}
