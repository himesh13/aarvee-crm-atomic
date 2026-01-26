import { CreateBase, Form, useNotify, useRedirect } from "ra-core";
import { Card, CardContent } from "@/components/ui/card";

import type { Lead } from "../types";
import { LeadInputs } from "./LeadInputs";
import { FormToolbar } from "../layout/FormToolbar";

export const LeadCreate = () => {
  const notify = useNotify();
  const redirect = useRedirect();

  const generateLeadNumber = () => {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    return `LEAD-${timestamp}-${random}`;
  };

  return (
    <CreateBase
      redirect="list"
      transform={(data: Lead) => ({
        ...data,
        lead_number: generateLeadNumber(),
        lead_status: 'new',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })}
      mutationOptions={{
        onSuccess: () => {
          notify('Lead created successfully', { type: 'success' });
          redirect('list', 'leads');
        },
        onError: (error: Error) => {
          notify(`Error creating lead: ${error.message}`, { type: 'error' });
        },
      }}
    >
      <div className="mt-2 flex lg:mr-72">
        <div className="flex-1">
          <Form>
            <Card>
              <CardContent>
                <LeadInputs />
                <FormToolbar />
              </CardContent>
            </Card>
          </Form>
        </div>
      </div>
    </CreateBase>
  );
};
