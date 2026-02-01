export const mapSortField = (field?: string) => {
  if (!field || field.trim() === "") return "createdAt";
  const map: Record<string, string> = {
    created: "createdAt",
    created_at: "createdAt",
    createdAt: "createdAt",
    updated: "updatedAt",
    updated_at: "updatedAt",
    updatedAt: "updatedAt",
    lead_number: "leadNumber",
    leadNumber: "leadNumber",
    name: "customerName",
  };
  return (map as Record<string, string>)[field] ?? field;
};
