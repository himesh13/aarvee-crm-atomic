import { Droppable } from "@hello-pangea/dnd";

import { useConfigurationContext } from "../root/ConfigurationContext";
import type { Lead } from "../types";
import { findLeadLabel } from "./stages";
import { LeadCard } from "./LeadCard";

export const LeadColumn = ({
  stage,
  leads,
}: {
  stage: string;
  leads: Lead[];
}) => {
  const totalAmount = leads.reduce(
    (sum, lead) => sum + (lead.loan_amount_required || 0),
    0,
  );

  const { leadStages } = useConfigurationContext();
  return (
    <div className="flex-1 pb-8">
      <div className="flex flex-col items-center">
        <h3 className="text-base font-medium">
          {findLeadLabel(leadStages, stage)}
        </h3>
        <p className="text-sm text-muted-foreground">
          {leads.length} lead{leads.length !== 1 ? "s" : ""}
          {totalAmount > 0 &&
            ` • ₹${totalAmount.toLocaleString("en-IN", {
              notation: "compact",
              maximumFractionDigits: 2,
            })}`}
        </p>
      </div>
      <Droppable droppableId={stage}>
        {(droppableProvided, snapshot) => (
          <div
            ref={droppableProvided.innerRef}
            {...droppableProvided.droppableProps}
            className={`flex flex-col rounded-2xl mt-2 gap-2 min-h-[100px] ${
              snapshot.isDraggingOver ? "bg-muted" : ""
            }`}
          >
            {leads.map((lead, index) => (
              <LeadCard key={lead.id} lead={lead} index={index} />
            ))}
            {droppableProvided.placeholder}
          </div>
        )}
      </Droppable>
    </div>
  );
};
