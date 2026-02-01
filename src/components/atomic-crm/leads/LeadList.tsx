import { 
  ListBase, 
  useListContext,
  RecordContextProvider,
  useGetIdentity,
} from "ra-core";
import { TextField } from "@/components/admin/text-field";
import { DateField } from "@/components/admin/date-field";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import { Link } from "react-router";

import type { Lead } from "../types";

export const LeadList = () => {
  const { identity } = useGetIdentity();

  return (
    <ListBase
      perPage={25}
      sort={{ field: "createdAt", order: "DESC" }}
    >
      <div className="flex flex-col gap-4 p-4">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-bold">Leads</h1>
          <Link to="/leads/create">
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Create Lead
            </Button>
          </Link>
        </div>
        <LeadListContent />
      </div>
    </ListBase>
  );
};

const LeadListContent = () => {
  const { data, isLoading } = useListContext<Lead>();

  if (isLoading) {
    return <div className="text-center py-8">Loading leads...</div>;
  }

  if (!data || data.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 text-center">
          <p className="text-muted-foreground mb-4">No leads found</p>
          <Link to="/leads/create">
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Create your first lead
            </Button>
          </Link>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="grid gap-4">
      {data.map((lead) => (
        <RecordContextProvider key={lead.id} value={lead}>
          <Card>
            <CardContent className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground">Lead Number</p>
                  <p className="font-semibold">
                    <TextField source="lead_number" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Customer Name</p>
                  <p className="font-semibold">
                    <TextField source="customer_name" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Contact Number</p>
                  <p className="font-semibold">
                    <TextField source="contact_number" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Product</p>
                  <p className="font-semibold">
                    <TextField source="product" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Loan Amount</p>
                  <p className="font-semibold">
                    <TextField source="loan_amount_required" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Status</p>
                  <p className="font-semibold capitalize">
                    <TextField source="lead_status" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Location</p>
                  <p className="font-semibold">
                    <TextField source="location" emptyText="-" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Referred By</p>
                  <p className="font-semibold">
                    <TextField source="lead_referred_by" emptyText="-" />
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Created</p>
                  <p className="font-semibold">
                    <DateField source="created_at" showTime />
                  </p>
                </div>
              </div>
              {lead.short_description && (
                <div className="mt-4">
                  <p className="text-sm text-muted-foreground">Description</p>
                  <p className="text-sm mt-1">{lead.short_description}</p>
                </div>
              )}
            </CardContent>
          </Card>
        </RecordContextProvider>
      ))}
    </div>
  );
};

export default LeadList;
