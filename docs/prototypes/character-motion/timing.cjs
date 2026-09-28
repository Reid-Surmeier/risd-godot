// Four-second regression through the real browser capture path; same wall-clock oracle.
process.env.TIMING_SECONDS ||= '4';
require('./browser.cjs');
