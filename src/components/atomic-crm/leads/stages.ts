import type { ConfigurationContextValue } from "../root/ConfigurationContext";
import type { Lead } from "../types";

export type LeadsByStage = Record<Lead["stage"], Lead[]>;

export const getLeadsByStage = (
  unorderedLeads: Lead[],
  leadStages: ConfigurationContextValue["leadStages"],
) => {
  if (!leadStages) return {};
  const leadsByStage: Record<Lead["stage"], Lead[]> = unorderedLeads.reduce(
    (acc, lead) => {
      // if lead has a stage that does not exist in configuration, assign it to the first stage
      const stage = leadStages.find((s) => s.value === lead.stage)
        ? lead.stage
        : leadStages[0].value;
      acc[stage].push(lead);
      return acc;
    },
    leadStages.reduce(
      (obj, stage) => ({ ...obj, [stage.value]: [] }),
      {} as Record<Lead["stage"], Lead[]>,
    ),
  );
  // order each column by index
  leadStages.forEach((stage) => {
    leadsByStage[stage.value] = leadsByStage[stage.value].sort(
      (recordA: Lead, recordB: Lead) => recordA.index - recordB.index,
    );
  });
  return leadsByStage;
};

export const findLeadLabel = (
  leadStages: ConfigurationContextValue["leadStages"],
  stage: string,
) => {
  const leadStage = leadStages.find((s) => s.value === stage);
  return leadStage ? leadStage.label : stage;
};
