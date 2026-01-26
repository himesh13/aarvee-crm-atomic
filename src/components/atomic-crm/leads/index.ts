import * as React from "react";
import { ClipboardList } from "lucide-react";

const LeadList = React.lazy(() => import("./LeadList"));
const LeadCreate = React.lazy(() => import("./LeadCreate").then(m => ({ default: m.LeadCreate })));

export default {
  list: LeadList,
  create: LeadCreate,
  icon: ClipboardList,
  recordRepresentation: (record: any) => record.lead_number || record.customer_name,
};
