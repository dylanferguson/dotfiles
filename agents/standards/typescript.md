# TypeScript

These rules follow the [TSConfig reference](https://www.typescriptlang.org/tsconfig/), the [typescript-eslint recommended](https://typescript-eslint.io/users/configs/#recommended) rules, the [Google TypeScript style guide](https://google.github.io/styleguide/tsguide.html), and Dan Vanderkam's *Effective TypeScript*. Paths point to examples in [langchainjs](https://github.com/langchain-ai/langchainjs).

## Compiler and lint

- Enable `strict`, `noImplicitReturns`, `noFallthroughCasesInSwitch`, `noUnusedLocals`, `noUnusedParameters`, and `isolatedModules`. Do not turn off any flag that `strict` enables. In a monorepo, extend one shared base config (`internal/tsconfig/base.json`).
- Fail the build on explicit `any` and on `@ts-ignore` (typescript-eslint `no-explicit-any` and `ban-ts-comment`). Where `any` is unavoidable, disable the rule for that one line with a comment.
- Type foreign values, such as caught errors and parsed JSON, as `unknown`, and narrow them before use (*Effective TypeScript*; `libs/langchain-core/src/utils/async_caller.ts`).
- Give generic parameters a constraint, and a real default if they need one. Do not default them to `any`.
- Use named exports only (Google TypeScript style guide).

## Configuration

- Do not read `process.env` outside one config module and tests. Enforce this with a lint rule, such as `n/no-process-env`.

## Errors

- Define one base error class for the package that sets `name`. Subclass it for each failure callers handle differently (`libs/langchain-core/src/errors/index.ts`).
- Keep error codes in a closed string union, and pass the original error as `cause`.

## Cancellation

- Accept an `AbortSignal` on public async operations that do I/O or take time. Reject with the signal's reason, never retry an aborted call, and remove listeners in `finally` (`libs/langchain-core/src/utils/signal.ts`).

## Tests

- Keep tests that call real third-party services out of the default run, and mark them so they are easy to run on demand (`*.int.test.ts` in langchainjs).
- Inject `fetch` or the SDK client through configuration, and assert on the request that would go over the wire (`libs/providers/langchain-openai/src/chat_models/tests/index.test.ts`).

## When it applies

Follow these only when the trigger matches.

### Code that retries remote calls

- Record whether an error is retryable on the error itself, where it is created, so callers do not guess from messages (`stampRetryable`).
- Set retries to zero in unit tests so failures surface at once.

### Published libraries

- Declare every public entry point in the `exports` map. Anything not exported is private.
- With `module` set to `NodeNext`, include the `.js` extension in relative imports, as Node ESM requires.
- Test exported types with `expectTypeOf` in `*.test-d.ts` files, especially types that must stay compatible with a third-party SDK.
- Test the built package in each supported module system, bundler, and runtime, and at the lowest and highest supported dependency versions (`environment_tests/`, `dependency_range_tests/`).
- If the library can load twice in one dependency tree, check error types with a branded `isInstance` guard instead of `instanceof` (`libs/langchain-core/src/utils/namespace.ts`).

### Monorepos with plugins or integrations

- Put shared interfaces in one core package, and make integrations list it as a `peerDependency` so consumers get a single copy.

### Interfaces that others implement

- Run one shared conformance suite against each implementation (`@langchain/standard-tests`).
