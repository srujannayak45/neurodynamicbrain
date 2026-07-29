---
id: B-154
tags: [code, reference, gotcha]
scope: any spreadsheet extraction (reconstructing visual tables without native Table objects)
hook: Reconstruct visual tables from spreadsheets w/o native table objects — semantic-header scoring + single-blank-spacer tolerance + merged-title rejection
---

# Heuristic table detection in spreadsheets (no native Table objects)

Engineering / business spreadsheets (BOQs, compliance matrices, pricing schedules) render tables
**visually** with no Excel Table object. Reconstructing them from cell signals — hard-won rules, all
**format-agnostic** (no hardcoded column/sheet names):

1. **Single blank rows are SPACERS, not table boundaries.** Dense sheets separate sub-sections with
   one blank row. Terminating a table on the first blank row shatters one logical table into many
   fragments. Fix: tolerate a run of ≤1 blank row inside a table; only terminate on **2+ consecutive
   blank rows** (or end of sheet). Empty rows have NO cell records, so walk the integer row range, not
   just populated rows, or true gaps are invisible.

2. **Use the SEMANTIC meaning of header cells to find the header row.** A genuine header row's labels
   classify to known column types (item_code/description/unit/quantity/rate/amount…); a bold
   sub-section title row or a data row classifies to `unknown`. Score a candidate row by the count of
   DISTINCT cells mapping to a known semantic type (confidence ≥0.5). A weak (semanticScore 0)
   candidate should defer to a stronger semantic header within a small look-ahead.

3. **Reject merged-title banners by distinctness.** A title merged across the row collapses to one
   repeated value (e.g. "PROJECT XYZ" ×8). Require header cells to be mostly DISTINCT (unique/filled
   ≥0.6) so a merged banner is never mistaken for a header.

4. **Fragmentation, not over-merge, was the root cause** of both "5 tables for one dataset" AND
   "header is a value not a column" — once fragmented, each fragment re-picks its first (data) row as a
   header. Fixing #1 makes the first true header claim the whole region.

5. **Anchor on the STRONGEST semantic header, default ONE table per sheet.** Score each candidate
   header by DISTINCT recognised column-meanings; the sheet's table anchors on the max-score row
   (topmost on tie) and spans to the end. Only a SECOND header that is (a) equally strong, (b) a
   different column signature, AND (c) separated by a blank-row gap starts a new table. Repeated
   page-headers (same signature, no gap) fold into the one table.

6. **Collapse merged header cells into ONE column** (a label repeated across adjacent cells = one
   merged header) → clean SQL: `item_description`, not `item_description_2/_3/_4`.

7. **pgType by semantic type, not raw sample**: item/drawing/doc codes → VARCHAR (they look numeric —
   "1.1","6a" — but are identifiers); description/spec/remarks → TEXT.

Also (PostgreSQL DDL generation from inferred schema): **dedupe column names** (two headers normalising
to the same name → `"x"` + `"x_2"`; also avoid the generator's implicit columns
id/workbook_id/sheet_name/source_row/metadata/extracted_at) and **quote all identifiers** so reserved
words (row, order, value) are legal. Validate by applying generated SQL to a live Postgres in a Docker
harness.

Streaming low-memory path: ExcelJS `WorkbookReader` throws `reading 'sheets'` on files ExcelJS itself
*writes* (zip orders worksheets before workbook.xml); real Excel files are fine. Stream cells to
NDJSON; bound memory to one sheet.
