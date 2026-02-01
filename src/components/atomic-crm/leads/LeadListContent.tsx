import { DragDropContext, type OnDragEndResponder } from "@hello-pangea/dnd";
import isEqual from "lodash/isEqual";
import { useDataProvider, useListContext, type DataProvider } from "ra-core";
import { useEffect, useState } from "react";

import { useConfigurationContext } from "../root/ConfigurationContext";
import type { Lead } from "../types";
import { LeadColumn } from "./LeadColumn";
import type { LeadsByStage } from "./stages";
import { getLeadsByStage } from "./stages";

export const LeadListContent = () => {
  const { leadStages } = useConfigurationContext();
  const { data: unorderedLeads, isPending, refetch } = useListContext<Lead>();
  const dataProvider = useDataProvider();

  const [leadsByStage, setLeadsByStage] = useState<LeadsByStage>(
    getLeadsByStage([], leadStages),
  );

  useEffect(() => {
    if (unorderedLeads) {
      const newLeadsByStage = getLeadsByStage(unorderedLeads, leadStages);
      if (!isEqual(newLeadsByStage, leadsByStage)) {
        setLeadsByStage(newLeadsByStage);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [unorderedLeads]);

  if (isPending) return null;

  const onDragEnd: OnDragEndResponder = (result) => {
    const { destination, source } = result;

    if (!destination) {
      return;
    }

    if (
      destination.droppableId === source.droppableId &&
      destination.index === source.index
    ) {
      return;
    }

    const sourceStage = source.droppableId;
    const destinationStage = destination.droppableId;
    const sourceLead = leadsByStage[sourceStage][source.index]!;
    const destinationLead = leadsByStage[destinationStage][
      destination.index
    ] ?? {
      stage: destinationStage,
      index: undefined, // undefined if dropped after the last item
    };

    // compute local state change synchronously
    setLeadsByStage(
      updateLeadStageLocal(
        sourceLead,
        { stage: sourceStage, index: source.index },
        { stage: destinationStage, index: destination.index },
        leadsByStage,
      ),
    );

    // persist the changes
    updateLeadStage(sourceLead, destinationLead, dataProvider).then(() => {
      refetch();
    });
  };

  return (
    <DragDropContext onDragEnd={onDragEnd}>
      <div className="flex gap-4 overflow-x-auto">
        {leadStages.map((stage) => (
          <LeadColumn
            stage={stage.value}
            leads={leadsByStage[stage.value]}
            key={stage.value}
          />
        ))}
      </div>
    </DragDropContext>
  );
};

const updateLeadStageLocal = (
  sourceLead: Lead,
  source: { stage: string; index: number },
  destination: {
    stage: string;
    index?: number; // undefined if dropped after the last item
  },
  leadsByStage: LeadsByStage,
) => {
  if (source.stage === destination.stage) {
    // moving lead inside the same column
    const column = leadsByStage[source.stage];
    column.splice(source.index, 1);
    column.splice(destination.index ?? column.length + 1, 0, sourceLead);
    return {
      ...leadsByStage,
      [destination.stage]: column,
    };
  } else {
    // moving lead across columns
    const sourceColumn = leadsByStage[source.stage];
    const destinationColumn = leadsByStage[destination.stage];
    sourceColumn.splice(source.index, 1);
    destinationColumn.splice(
      destination.index ?? destinationColumn.length + 1,
      0,
      sourceLead,
    );
    return {
      ...leadsByStage,
      [source.stage]: sourceColumn,
      [destination.stage]: destinationColumn,
    };
  }
};

const updateLeadStage = async (
  source: Lead,
  destination: {
    stage: string;
    index?: number; // undefined if dropped after the last item
  },
  dataProvider: DataProvider,
) => {
  if (source.stage === destination.stage) {
    // moving lead inside the same column
    // Fetch all the leads in this stage (because the list may be filtered, but we need to update even non-filtered leads)
    const { data: columnLeads } = await dataProvider.getList("leads", {
      sort: { field: "index", order: "ASC" },
      pagination: { page: 1, perPage: 100 },
      filter: { stage: source.stage },
    });
    const destinationIndex = destination.index ?? columnLeads.length + 1;

    if (source.index > destinationIndex) {
      // lead moved up, eg
      // dest   src
      //  <------
      // [4, 7, 23, 5]
      await Promise.all([
        // for all leads between destinationIndex and source.index, increase the index
        ...columnLeads
          .filter(
            (lead) =>
              lead.index >= destinationIndex && lead.index < source.index,
          )
          .map((lead) =>
            dataProvider.update("leads", {
              id: lead.id,
              data: { index: lead.index + 1 },
              previousData: lead,
            }),
          ),
        // for the lead that was moved, update its index
        dataProvider.update("leads", {
          id: source.id,
          data: { index: destinationIndex },
          previousData: source,
        }),
      ]);
    } else {
      // lead moved down, e.g
      // src   dest
      //  ------>
      // [4, 7, 23, 5]
      await Promise.all([
        // for all leads between source.index and destinationIndex, decrease the index
        ...columnLeads
          .filter(
            (lead) =>
              lead.index <= destinationIndex && lead.index > source.index,
          )
          .map((lead) =>
            dataProvider.update("leads", {
              id: lead.id,
              data: { index: lead.index - 1 },
              previousData: lead,
            }),
          ),
        // for the lead that was moved, update its index
        dataProvider.update("leads", {
          id: source.id,
          data: { index: destinationIndex },
          previousData: source,
        }),
      ]);
    }
  } else {
    // moving lead across columns
    // Fetch all the leads in both stages (because the list may be filtered, but we need to update even non-filtered leads)
    const [{ data: sourceLeads }, { data: destinationLeads }] =
      await Promise.all([
        dataProvider.getList("leads", {
          sort: { field: "index", order: "ASC" },
          pagination: { page: 1, perPage: 100 },
          filter: { stage: source.stage },
        }),
        dataProvider.getList("leads", {
          sort: { field: "index", order: "ASC" },
          pagination: { page: 1, perPage: 100 },
          filter: { stage: destination.stage },
        }),
      ]);
    const destinationIndex = destination.index ?? destinationLeads.length + 1;

    await Promise.all([
      // decrease index on the leads after the source index in the source columns
      ...sourceLeads
        .filter((lead) => lead.index > source.index)
        .map((lead) =>
          dataProvider.update("leads", {
            id: lead.id,
            data: { index: lead.index - 1 },
            previousData: lead,
          }),
        ),
      // increase index on the leads after the destination index in the destination columns
      ...destinationLeads
        .filter((lead) => lead.index >= destinationIndex)
        .map((lead) =>
          dataProvider.update("leads", {
            id: lead.id,
            data: { index: lead.index + 1 },
            previousData: lead,
          }),
        ),
      // change the dragged lead to take the destination index and column
      dataProvider.update("leads", {
        id: source.id,
        data: {
          index: destinationIndex,
          stage: destination.stage,
        },
        previousData: source,
      }),
    ]);
  }
};
