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
import { LeadListContent } from "./LeadListContent";

export const LeadList = () => {
  const { identity } = useGetIdentity();

  return (
    <ListBase
      perPage={100}
      sort={{ field: "index", order: "ASC" }}
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

export default LeadList;
