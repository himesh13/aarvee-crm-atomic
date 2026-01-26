import { required } from "ra-core";
import { Separator } from "@/components/ui/separator";
import { useIsMobile } from "@/hooks/use-mobile";
import { TextInput } from "@/components/admin/text-input";
import { ReferenceInput } from "@/components/admin/reference-input";
import { SelectInput } from "@/components/admin/select-input";
import { NumberInput } from "@/components/admin/number-input";

export const LeadInputs = () => {
  const isMobile = useIsMobile();

  return (
    <div className="flex flex-col gap-2 p-1">
      <div className={`flex gap-6 ${isMobile ? "flex-col" : "flex-row"}`}>
        <div className="flex flex-col gap-10 flex-1">
          <LeadBasicInfoInputs />
        </div>
        <Separator
          orientation={isMobile ? "horizontal" : "vertical"}
          className="flex-shrink-0"
        />
        <div className="flex flex-col gap-10 flex-1">
          <LeadDetailsInputs />
        </div>
      </div>
    </div>
  );
};

const LeadBasicInfoInputs = () => {
  return (
    <div className="flex flex-col gap-4">
      <h6 className="text-lg font-semibold">Customer Information</h6>
      <TextInput 
        source="customer_name" 
        label="Customer Name"
        validate={required()} 
        helperText={false} 
      />
      <TextInput 
        source="contact_number" 
        label="Contact Number"
        validate={required()} 
        helperText={false} 
      />
      <ReferenceInput 
        source="product" 
        reference="products"
        filter={{ active: true }}
        sort={{ field: "name", order: "ASC" }}
      >
        <SelectInput
          label="Product"
          optionText="name"
          optionValue="name"
          validate={required()}
          helperText={false}
        />
      </ReferenceInput>
      <NumberInput 
        source="loan_amount_required" 
        label="Loan Amount Required"
        helperText={false} 
      />
    </div>
  );
};

const LeadDetailsInputs = () => {
  return (
    <div className="flex flex-col gap-4">
      <h6 className="text-lg font-semibold">Additional Details</h6>
      <TextInput 
        source="location" 
        label="Location"
        helperText={false}
      />
      <TextInput 
        source="lead_referred_by" 
        label="Lead Referred By"
        helperText={false} 
      />
      <TextInput 
        source="short_description" 
        label="Short Description"
        multiline
        rows={5}
        helperText="Maximum 500 words"
      />
    </div>
  );
};
