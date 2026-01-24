import { Router } from 'express';
import leadRoutes from './leadRoutes';

const router = Router();

// Health check endpoint (no auth required)
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
router.use('/api', leadRoutes);

export default router;
