const express = require('express');
const crypto = require('node:crypto');
const { authenticate } = require('../middleware/authenticate');
const { validationError, notFound } = require('../errors');

// Example catalog, pending verified profiles supplied by the product owner.
const graphemes = new Intl.Segmenter('es', { granularity: 'grapheme' });
const mentors = [
  { id: 'sofia', name: 'Sofía Valenzuela', role: 'Mentora', headline: 'Ex-VP Operaciones · Cornershop & Rappi', specialty: 'Impacto & Clima', sector: 'Impact Tech & Sustentabilidad', location: 'LatAm / Remoto', description: 'Especialista en logística urbana y crecimiento sostenible. Acompaño a equipos que quieren transformar una buena idea en un negocio con impacto.', achievement: '3 startups guiadas en 2024', responseTime: 'Responde en 24–48 h', kind: 'mentor', verified: false, demo: true },
  { id: 'carlos', name: 'Carlos Mendoza', role: 'Partner', headline: 'Partner en Magma Partners · Angel LatAm', specialty: 'B2B SaaS', sector: 'B2B & Fintech', location: 'LatAm / Remoto', description: 'Inversión en etapas tempranas para equipos que resuelven problemas reales en Latinoamérica. Conversemos sobre tu mercado, tu tracción y tus próximos pasos.', ticket: '$50,000 USD', achievement: 'Tickets Pre-Seed ($50K – $250K)', responseTime: 'Responde en 48 h', kind: 'investor', isSeed: true, verified: false, demo: true },
  { id: 'elena', name: 'Elena Rostova', role: 'Mentora', headline: 'Angel Investor & Ex-Founder', specialty: 'Impacto & Clima', sector: 'Impact Tech & Sustentabilidad', location: 'LatAm / Remoto', description: 'Apasionada por respaldar fundadores jóvenes en etapa temprana que atacan problemas de eficiencia verde y finanzas circulares con modelos escalables.', achievement: 'Estrategia y crecimiento sostenible', responseTime: 'Responde en 24–48 h', kind: 'mentor', verified: false, demo: true },
];

function createMentorsRouter({ db, tokens, users }) {
  db.exec(`CREATE TABLE IF NOT EXISTS mentor_requests (
    id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id),
    mentor_id TEXT NOT NULL, type TEXT NOT NULL, message TEXT NOT NULL,
    share_report INTEGER NOT NULL DEFAULT 0, report_json TEXT,
    created_at TEXT NOT NULL
  )`);
  const router = express.Router();
  router.use(authenticate({ tokens, users }));
  router.get('/', (req, res) => {
    const q = String(req.query.q || '').trim().toLocaleLowerCase('es');
    const category = String(req.query.category || 'Todos');
    res.json({ mentors: mentors.filter(m =>
      (category === 'Todos' || m.specialty === category || (category === 'Seed Stage' && m.isSeed) || (category === 'Ángel Inversionistas' && m.kind === 'investor')) &&
      [m.name, m.headline, m.sector, m.specialty].join(' ').toLocaleLowerCase('es').includes(q)) });
  });
  router.get('/:id', (req, res) => {
    const mentor = mentors.find(m => m.id === req.params.id);
    if (!mentor) throw notFound('Mentor no encontrado');
    res.json({ mentor });
  });
  router.post('/:id/requests', (req, res) => {
    if (!mentors.some(m => m.id === req.params.id)) throw notFound('Mentor no encontrado');
    const { type, message, shareReport, report } = req.body || {};
    if (!['feedback', 'mentoring', 'pitch'].includes(type)) throw validationError('Tipo de solicitud inválido');
    if (typeof message !== 'string' || !message.trim() || [...graphemes.segment(message.trim())].length > 240) throw validationError('Escribe un mensaje de 1 a 240 caracteres');
    if (typeof shareReport !== 'boolean') throw validationError('Indica si autorizas compartir el reporte');
    if (report != null && !shareReport) throw validationError('Compartir el reporte requiere autorización explícita');
    if (report != null && (typeof report !== 'object' || Array.isArray(report) || JSON.stringify(report).length > 5000)) throw validationError('Reporte inválido');
    const id = `req_${crypto.randomBytes(12).toString('hex')}`;
    const createdAt = new Date().toISOString();
    db.prepare(`INSERT INTO mentor_requests (id, user_id, mentor_id, type, message, share_report, report_json, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`).run(id, req.user.id, req.params.id, type, message.trim(), shareReport ? 1 : 0, shareReport && report ? JSON.stringify(report) : null, createdAt);
    res.status(201).json({ request: { id, status: 'recorded', createdAt } });
  });
  return router;
}
module.exports = { createMentorsRouter };
