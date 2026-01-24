import { Router } from 'express';
import { LeadController } from '../controllers/leadController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const leadController = new LeadController();

// All routes require authentication
router.use(authenticateToken);

// Lead Extension routes
router.post('/lead_extensions', (req, res) => leadController.create(req, res));
router.get('/lead_extensions', (req, res) => leadController.getList(req, res));
router.get('/lead_extensions/:id', (req, res) => leadController.getOne(req, res));
router.put('/lead_extensions/:id', (req, res) => leadController.update(req, res));
router.delete('/lead_extensions/:id', (req, res) => leadController.delete(req, res));

export default router;
