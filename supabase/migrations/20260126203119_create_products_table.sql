-- Create products table for dynamic product dropdown
CREATE TABLE IF NOT EXISTS public.products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index on active products for faster queries
CREATE INDEX idx_products_active ON public.products(active);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Create policies (all authenticated users can view, only admins can modify)
CREATE POLICY "Authenticated users can view products" ON public.products
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert products" ON public.products
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update products" ON public.products
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete products" ON public.products
  FOR DELETE USING (auth.role() = 'authenticated');

-- Create trigger for updated_at
CREATE TRIGGER update_products_updated_at 
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Insert some initial products
INSERT INTO public.products (name, description) VALUES
  ('Home Loan', 'Residential property financing'),
  ('Business Loan', 'Commercial and business financing'),
  ('Auto Loan', 'Vehicle financing'),
  ('Personal Loan', 'Personal financing'),
  ('Property Loan', 'Real estate investment financing')
ON CONFLICT (name) DO NOTHING;
