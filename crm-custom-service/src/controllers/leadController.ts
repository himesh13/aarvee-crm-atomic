import { Request, Response } from 'express';
import prisma from '../config/database';
import logger from '../config/logger';

export class LeadController {
  /**
   * Generate a unique lead number
   */
  private async generateLeadNumber(): Promise<string> {
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const count = await prisma.leadExtension.count({
      where: {
        leadNumber: {
          startsWith: `LEAD-${today}`,
        },
      },
    });
    return `LEAD-${today}-${String(count + 1).padStart(5, '0')}`;
  }

  /**
   * Create a new lead extension
   */
  async create(req: Request, res: Response) {
    try {
      const {
        contactId,
        product,
        loanAmountRequired,
        location,
        leadReferredBy,
        shortDescription,
        leadAssignedTo,
        leadStatus,
        businessDetails,
        propertyDetails,
        autoLoanDetails,
        machineryLoanDetails,
      } = req.body;

      // Validate required fields
      if (!contactId) {
        return res.status(400).json({ error: 'contactId is required' });
      }

      // Generate lead number
      const leadNumber = await this.generateLeadNumber();

      const leadExtension = await prisma.leadExtension.create({
        data: {
          contactId: BigInt(contactId),
          leadNumber,
          product,
          loanAmountRequired: loanAmountRequired ? BigInt(loanAmountRequired) : null,
          location,
          leadReferredBy,
          shortDescription,
          leadAssignedTo: leadAssignedTo ? BigInt(leadAssignedTo) : null,
          leadStatus: leadStatus || 'new',
          businessDetails,
          propertyDetails,
          autoLoanDetails,
          machineryLoanDetails,
        },
      });

      // Convert BigInt to string for JSON serialization
      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      logger.info(`Created lead extension: ${leadNumber}`);
      res.status(201).json(response);
    } catch (error) {
      logger.error('Error creating lead extension:', error);
      res.status(500).json({ error: 'Failed to create lead extension' });
    }
  }

  /**
   * Get list of lead extensions with pagination and filtering
   */
  async getList(req: Request, res: Response) {
    try {
      const {
        page = '1',
        perPage = '10',
        sortField = 'createdAt',
        sortOrder = 'desc',
        filter = '{}',
      } = req.query;

      const pageNum = parseInt(page as string);
      const perPageNum = parseInt(perPage as string);
      const where = JSON.parse(filter as string);

      const [data, total] = await Promise.all([
        prisma.leadExtension.findMany({
          where,
          skip: (pageNum - 1) * perPageNum,
          take: perPageNum,
          orderBy: { [sortField as string]: sortOrder },
        }),
        prisma.leadExtension.count({ where }),
      ]);

      // Convert BigInt fields to strings
      const serializedData = data.map(item => ({
        ...item,
        id: item.id.toString(),
        contactId: item.contactId.toString(),
        loanAmountRequired: item.loanAmountRequired?.toString(),
        leadAssignedTo: item.leadAssignedTo?.toString(),
      }));

      res.json({ data: serializedData, total });
    } catch (error) {
      logger.error('Error fetching lead extensions:', error);
      res.status(500).json({ error: 'Failed to fetch lead extensions' });
    }
  }

  /**
   * Get a single lead extension by ID
   */
  async getOne(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const leadExtension = await prisma.leadExtension.findUnique({
        where: { id: BigInt(id) },
      });

      if (!leadExtension) {
        return res.status(404).json({ error: 'Lead extension not found' });
      }

      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      res.json(response);
    } catch (error) {
      logger.error('Error fetching lead extension:', error);
      res.status(500).json({ error: 'Failed to fetch lead extension' });
    }
  }

  /**
   * Update a lead extension
   */
  async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const updateData = { ...req.body };

      // Convert string IDs to BigInt
      if (updateData.contactId) {
        updateData.contactId = BigInt(updateData.contactId);
      }
      if (updateData.loanAmountRequired) {
        updateData.loanAmountRequired = BigInt(updateData.loanAmountRequired);
      }
      if (updateData.leadAssignedTo) {
        updateData.leadAssignedTo = BigInt(updateData.leadAssignedTo);
      }

      const leadExtension = await prisma.leadExtension.update({
        where: { id: BigInt(id) },
        data: updateData,
      });

      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      logger.info(`Updated lead extension: ${id}`);
      res.json(response);
    } catch (error) {
      logger.error('Error updating lead extension:', error);
      res.status(500).json({ error: 'Failed to update lead extension' });
    }
  }

  /**
   * Delete a lead extension
   */
  async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      await prisma.leadExtension.delete({
        where: { id: BigInt(id) },
      });

      logger.info(`Deleted lead extension: ${id}`);
      res.json({ message: 'Lead extension deleted successfully' });
    } catch (error) {
      logger.error('Error deleting lead extension:', error);
      res.status(500).json({ error: 'Failed to delete lead extension' });
    }
  }
}
