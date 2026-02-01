import { Draggable } from "@hello-pangea/dnd";
import { useRedirect } from "ra-core";
import { Card, CardContent } from "@/components/ui/card";
import { Phone, MapPin } from "lucide-react";

import type { Lead } from "../types";

export const LeadCard = ({ lead, index }: { lead: Lead; index: number }) => {
  if (!lead) return null;

  return (
    <Draggable draggableId={String(lead.id)} index={index}>
      {(provided, snapshot) => (
        <LeadCardContent provided={provided} snapshot={snapshot} lead={lead} />
      )}
    </Draggable>
  );
};

export const LeadCardContent = ({
  provided,
  snapshot,
  lead,
}: {
  provided?: any;
  snapshot?: any;
  lead: Lead;
}) => {
  const redirect = useRedirect();
  const handleClick = () => {
    redirect(`/leads/${lead.id}/show`, undefined, undefined, undefined, {
      _scrollToTop: false,
    });
  };

  return (
    <div
      className="cursor-pointer"
      {...provided?.draggableProps}
      {...provided?.dragHandleProps}
      ref={provided?.innerRef}
      onClick={handleClick}
    >
      <Card
        className={`py-4 transition-all duration-200 ${
          snapshot?.isDragging
            ? "opacity-90 transform rotate-1 shadow-lg"
            : "shadow-sm hover:shadow-md"
        }`}
      >
        <CardContent className="px-4">
          <div className="space-y-2">
            <div>
              <p className="text-xs text-muted-foreground">
                #{lead.lead_number}
              </p>
              <p className="text-sm font-medium mt-1">{lead.customer_name}</p>
            </div>
            <div className="flex items-center gap-1 text-xs text-muted-foreground">
              <Phone className="h-3 w-3" />
              <span>{lead.contact_number}</span>
            </div>
            {lead.product && (
              <p className="text-xs text-muted-foreground">
                Product: {lead.product}
              </p>
            )}
            {lead.loan_amount_required && (
              <p className="text-xs font-semibold">
                ₹{lead.loan_amount_required.toLocaleString("en-IN")}
              </p>
            )}
            {lead.location && (
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <MapPin className="h-3 w-3" />
                <span>{lead.location}</span>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
