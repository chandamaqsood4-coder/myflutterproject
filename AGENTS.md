# AGENTS.md

Instructions for AI coding agents working on **DukanOS Desktop**.
Read this file fully before making any change.

## 1. Project

DukanOS Desktop is a **Windows POS application** built with Flutter. It is the
local, offline-first client for the DukanOS platform (web: app.dukanos.live).

- Framework: Flutter 3.47.7 (Windows desktop target only)
- State management: Riverpod (code generation, `AsyncNotifier`)
- Local database: Drift on SQLite (WAL mode)
- Remote API: DukanOS REST API (`/api/v1`, bearer-token auth)
- Priorities, in order: **data integrity, speed, robustness, then features**

## 2. Sources of truth

Never invent requirements or endpoints. Read these first:

1. `docs/PRD.md` : product requirements
2. `docs/api.md` : API contract
3. `docs/architecture.md` : architecture decisions (if present)

If the code, the docs, or this file disagree, **stop and ask**. Do not guess.
If a requirement is missing, add it under "Open questions" in `docs/PRD.md`
instead of assuming.

## 3. Core architecture rules (non-negotiable)

1. **The local database is the source of truth.** The UI reads and writes only
   through repositories backed by Drift. The UI and providers never call the
   API directly.
2. **Outbox pattern.** Every write is ONE database transaction that updates the
   business tables AND inserts a `sync_queue` row. A sale must never partially
   save.
3. **The sync engine is separate** from the UI. It pushes the queue and pulls
   changes by cursor, with exponential backoff and jitter.
4. **Idempotency.** Every queued operation carries an idempotency key so a retry
   never creates a duplicate record.
5. **Client-generated UUID v7 primary keys.** Keep a nullable `server_id` only if
   the API requires one.
6. **Money is stored as integer minor units.** Never use `double` for money,
   tax, discounts, or stock quantities that must be exact.
7. **Append-only financial records.** Invoices, returns, and payments are
   immutable. Corrections are made with new records (void or return), never by
   editing history.
8. **Stock syncs as deltas**, never absolute values.
9. **Soft deletes** (`deleted_at`) so deletions can sync.
10. All business logic (totals, tax, discounts, returns) lives in the
    **domain layer** as pure Dart and must be unit-tested.

## 4. Folder structure

Feature-first Clean Architecture. Dependencies point inward only:
`presentation -> domain <- data`.

```
lib/
  core/              # database, network, sync, errors, logging, config, utils
  features/
    <feature>/
      presentation/  # screens, widgets, Riverpod providers
      domain/        # entities, repository interfaces, use cases (pure Dart)
      data/          # DAOs, DTOs, mappers, repository implementations
  shared/            # design system, common widgets
test/                # mirrors lib/
docs/                # PRD, API, architecture
```

Planned features: `auth`, `pos`, `products`, `catalog`, `invoices`, `returns`,
`quotations`, `finance`, `reports`, `users`, `audit`, `settings`.

Domain entities must not import Flutter, Drift, or JSON annotations.

## 5. Identifier and numbering scheme

- Document numbers: `{TERMINAL}-{DOC}-{YYMM}-{SEQUENCE}`
  e.g. `T01-INV-2610-000123`
- Doc codes: `INV`, `RET`, `QUO`, `PUR`
- The sequence is per terminal and per document type, stored in a local
  `counters` table, and incremented **inside the same transaction** as the
  document insert.
- Barcodes are strings, never integers. Products can have multiple barcodes.
- Enums persist a stable string `code`, never the enum index.
- Use UTF-8 everywhere. Product and customer names may be Urdu or mixed script.

Confirm any change to these rules against `docs/PRD.md` before implementing.

## 6. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter run -d windows
flutter build windows --release
```

Before finishing any task, **all of these must pass**: `flutter analyze`,
`dart format`, `flutter test`.

## 7. Coding standards

- Follow Effective Dart and the lints in `analysis_options.yaml`. Do not
  silence lints without a written reason.
- Riverpod: use `@riverpod` code generation. Use `ref.watch` in build methods and
  `ref.read` only in callbacks. Use `select` to limit rebuilds.
- Models are immutable (`freezed`). Prefer sealed classes for states and results.
- Use `Result` or typed exceptions for expected failures. No empty `catch`
  blocks. Log with context.
- No business logic in widgets. No `print`. Use the app logger.
- Public APIs get doc comments. Keep functions small and single-purpose.
- No hard-coded strings for user-facing text once localization is set up.

## 8. Performance requirements

- Search products through an **FTS5** table plus indexes on barcode and SKU.
  Target under 100 ms on target hardware.
- Use `ListView.builder` (with `itemExtent` where possible) for long lists.
- Run heavy work (report aggregation, bulk sync apply, imports) off the UI
  isolate.
- Keep the checkout path to a single transaction with no network calls.
- Verify performance in `--profile` mode, not debug.

## 9. Robustness requirements

- Drift **migrations are versioned**. Every schema change needs a migration and a
  migration test. Never edit a released schema version in place.
- Enforce a single running instance of the app.
- Automatic local backup and a restore path.
- Auth tokens go in `flutter_secure_storage`. Never log tokens, passwords, or
  customer data.
- Cashier login must work offline. Handle token expiry without losing queued
  work.
- Failed sync items go to a visible "needs attention" state. Never drop them
  silently.

## 10. Testing

- Unit: domain logic (totals, tax, discounts, returns, numbering).
- Repository and DAO tests against in-memory Drift.
- Sync tests with a fake API: offline, timeout, duplicate send, partial failure,
  conflict.
- Provider tests with `ProviderContainer` overrides.
- Integration test for the full offline checkout flow.

Every bug fix includes a regression test. New features include tests in the same
change.

## 11. Workflow for the agent

1. Read the relevant sections of `docs/PRD.md` and `docs/api.md`.
2. State a short plan and list the files you will touch. Ask if anything is
   unclear.
3. Make small, focused changes. One concern per change.
4. Run the commands in section 6. Fix failures before reporting completion.
5. Summarize what changed, what was tested, and any open questions.

## 12. Boundaries

**Never:**
- Edit generated files (`*.g.dart`, `*.freezed.dart`) by hand.
- Edit a released Drift schema version or delete migrations.
- Call the API from UI or provider code.
- Store money as `double` or modify posted financial records.
- Commit secrets, tokens, `.env` files, or real customer data.
- Add a dependency without stating why and checking that it supports Windows
  and is actively maintained.
- Run destructive commands (`rm -rf`, force-push, database wipes) without
  explicit approval.

**Ask first:**
- Any change to the sync protocol, numbering scheme, or database schema.
- Any deviation from the PRD or API contract.
- Adding or upgrading major dependencies.

## 13. Suggested build order

1. Foundations: structure, config, database schema and migrations, providers,
   logging, error handling
2. Auth and session (including offline cashier login)
3. Products and catalog with FTS search
4. POS checkout flow, fully offline
5. Sync engine (outbox, push, pull, retry, idempotency)
6. Invoices, returns, quotations
7. Finance, reports, audit
8. Hardware (receipt printer, barcode scanner, cash drawer), installer, backup,
   and update pipeline

## 14. Definition of done

A task is done only when: it matches the PRD, tests are added and passing,
`flutter analyze` and `dart format` are clean, migrations exist for schema
changes, and nothing in section 12 was violated.
