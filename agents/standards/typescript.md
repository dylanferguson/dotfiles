# TypeScript

Paths cite [langchainjs](https://github.com/langchain-ai/langchainjs), the
reference TypeScript codebase these rules were checked against.

## Compiler and lint

- Enable `strict`, `noImplicitReturns`, `noFallthroughCasesInSwitch`,
  `noUnusedLocals`, `noUnusedParameters`, and `isolatedModules`. In a
  monorepo, extend one shared base config (`internal/tsconfig/base.json`).
- Keep `strictPropertyInitialization` on. Do not copy langchainjs, which
  turns it off.
- Fail the build on explicit `any` and on `@ts-ignore` (`.oxlintrc.jsonc`:
  `typescript/no-explicit-any`, `typescript/ban-ts-comment`). Where `any`
  is unavoidable, disable the rule for that one line with a comment.
- Type foreign values, such as caught errors and parsed JSON, as `unknown`
  and narrow them with `typeof` and `in` checks
  (`libs/langchain-core/src/utils/async_caller.ts`).
- Give generic parameters a constraint and a real default. Do not default
  them to `any`.
- Use named exports only. Include the `.js` extension in relative imports
  for ESM.

## Configuration

- Do not read `process.env` outside one config module and tests. Enforce
  this with a lint rule (`node/no-process-env`).

## Errors

- Define one base error class for the package that sets `name` and
  captures the stack. Subclass it for each failure callers handle
  differently (`libs/langchain-core/src/errors/index.ts`).
- Keep error codes in a closed string union, and pass the original error as
  `cause`.
- Record whether an error is retryable on the error itself, where it is
  created, so callers do not guess from messages (`stampRetryable`).
- In a library that can load twice in one dependency tree, check error
  types with a branded `isInstance` guard instead of `instanceof`
  (`libs/langchain-core/src/utils/namespace.ts`).

## Cancellation

- Accept an `AbortSignal` on every public async operation. Reject with the
  signal's reason, never retry an aborted call, and remove listeners in
  `finally` (`libs/langchain-core/src/utils/signal.ts`).

## Packages

- In a monorepo, put shared interfaces in one core package, and make
  integrations list it as a `peerDependency` so consumers get a single
  copy.
- Declare every public entry point in the `exports` map. Anything not
  exported is private.

## Tests

- Name unit tests `*.test.ts` and keep them off the network. Name tests that
  call real services `*.int.test.ts`, and exclude them from the default run
  (`vitest.config.ts`).
- In unit tests, inject `fetch` or the SDK client through configuration,
  and assert on the request that would go over the wire
  (`libs/providers/langchain-openai/src/chat_models/tests/index.test.ts`).
- Set retries to zero in unit tests so failures surface at once.
- Test exported types with `expectTypeOf` in `*.test-d.ts` files, especially
  types that must stay compatible with a third-party SDK.
- When several classes implement one interface, run one shared conformance
  suite against each (`@langchain/standard-tests`).
- For published libraries, test the built package in each supported module
  system, bundler, and runtime, and at the lowest and highest supported
  dependency versions (`environment_tests/`, `dependency_range_tests/`).
