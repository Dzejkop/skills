---
name: code-style
description: Directives for writing high quality, readable code - should always be used if writing production code - does not apply to throwaway or single use scripts
---

Write code that makes its behavior, invariants, and failure modes easy to understand. Optimize for the next reader, not for the fewest lines or the most abstractions.

## Applying this skill

Use these guidelines when writing or reviewing production code. They do not require polishing throwaway or single-use scripts.

- Read the surrounding code and repository instructions before making changes. Follow the project's language idioms, formatter, and established conventions rather than introducing a competing style.
- Apply judgment: these are design guidelines, not quotas for function length, comments, or abstractions.
- Keep changes proportional to the task. Do not turn a local improvement into an unrelated rewrite.
- For module interfaces, seams, and deeper architectural decisions, use the `codebase-design` skill alongside this one.

## Naming and readability

Use names that communicate the domain concept and distinguish it from nearby concepts. Prefer `retryDelay` to `value` and `pendingOrders` to `data`. Short names are fine where their meaning is immediate, such as a loop index.

- Use the same term for the same concept throughout a module. Do not alternate between `account`, `customer`, and `user` unless they mean different things.
- Make units and non-obvious semantics explicit: `timeoutMs`, `expiresAt`, or a duration type rather than an ambiguous number.
- Name booleans as predicates. Avoid double negatives and boolean arguments whose meaning is invisible at the call site; use named arguments, an enum, or distinct operations when they clarify intent.
- Prefer straightforward expressions and control flow over clever one-liners, dense chains, or incidental language tricks.
- Introduce a named constant when it explains a domain rule, unit, or shared policy. Do not give every literal a name merely to eliminate literals.

## Comments

Comments in code - with the exception of doc comments - should be kept to an **absolute minimum**. Comments in code are justified if they're explaining some difficult concept - or warn against making certain changes to the code in question.

If present - comments in code should only describe the current state of the code. They should never refer to any previous version of the code.

An exemption to the above rule is linking issues or pull requests in code comments - this is justifiable when leaving a todo comment like:

```rust
// TODO: A temporary workaround - remove once https://github.com/org/repo/pull/123 is merged
```

## Doc comments

The purpose of doc comments in code is to be read by humans. The golden standard of what doc comments should look like is Rust's standard library. Whenever in doubt - refer to it as an example.

Example of a good doc comment:

````rust
/// Creates a new asynchronous channel, returning the sender/receiver halves.
///
/// All data sent on the [`Sender`] will become available on the [`Receiver`] in
/// the same order as it was sent, and no [`send`] will block the calling thread
/// (this channel has an "infinite buffer", unlike [`sync_channel`], which will
/// block after its buffer limit is reached). [`recv`] will block until a message
/// is available while there is at least one [`Sender`] alive (including clones).
///
/// The [`Sender`] can be cloned to [`send`] to the same channel multiple times, but
/// only one [`Receiver`] is supported.
///
/// If the [`Receiver`] is disconnected while trying to [`send`] with the
/// [`Sender`], the [`send`] method will return a [`SendError`]. Similarly, if the
/// [`Sender`] is disconnected while trying to [`recv`], the [`recv`] method will
/// return a [`RecvError`].
///
/// [`send`]: Sender::send
/// [`recv`]: Receiver::recv
///
/// # Examples
///
/// ```
/// use std::sync::mpsc::channel;
/// use std::thread;
///
/// let (sender, receiver) = channel();
///
/// // Spawn off an expensive computation
/// thread::spawn(move || {
/// #   fn expensive_computation() {}
///     sender.send(expensive_computation()).unwrap();
/// });
///
/// // Do some useful work for a while
///
/// // Let's see what that answer was
/// println!("{:?}", receiver.recv().unwrap());
/// ```
#[must_use]
#[stable(feature = "rust1", since = "1.0.0")]
pub fn channel<T>() -> (Sender<T>, Receiver<T>) {
    let (tx, rx) = mpmc::channel();
    (Sender { inner: tx }, Receiver { inner: rx })
}
````

Note that the doc comment does not e.g. say `Creates a sender & receiver channel and returns both in a tuple` - it tells a story of how to use the code and what to expect out of it.

Document the contract, not a paraphrase of the signature. Include relevant preconditions, errors, panics or exceptions, side effects, ordering, and ownership or lifetime expectations. Examples should demonstrate realistic usage and important edge cases. Use the language's documentation conventions; not every private helper needs a doc comment. Update documentation when the contract changes.

## Nesting

Prefer guard clauses and early returns for invalid input, missing data, and terminal cases. Keep the main path visible rather than wrapping it in layers of conditionals.

Extract a nested block when it represents a coherent operation with a useful name, not merely to move indentation elsewhere. Do not flatten control flow at the cost of duplicating cleanup or hiding execution order. Use structured resource management so early returns release resources correctly.

## Smaller functions vs complexity

A smaller function is not automatically simpler. Judge an extraction by how much a reader must understand to use it, not by how many lines it removes.

Extract a function when it:

- Gives a coherent operation a name that explains intent.
- Hides an implementation detail or an invariant that callers should not manage.
- Captures shared behavior that must change consistently across callers.
- Separates decision-making from I/O so each can be understood and tested independently.

Keep code together when splitting it would force the reader to jump between helpers to follow one straightforward operation. A longer function with a clear sequence can be easier to understand than several small functions passing intermediate state around.

Avoid helpers that merely rename an expression without clarifying it, forward the same parameters without hiding anything, or require callers to know their internal sequence. Many parameters can signal a misplaced responsibility; do not hide the problem in an arbitrary context object.

## Abstractions and duplication

Abstractions are tools for making code understandable, not just for removing duplication or supporting interchangeable implementations. A named trait, interface, or type can make a concept and its contract explicit instead of forcing readers to infer them from usage. That can be valuable even with a single implementation.

Judge an abstraction by what it helps the reader understand. Does it name a meaningful role, expose a contract, or hide details that would otherwise distract from the task? Or does it merely add another layer to navigate? Neither introducing nor avoiding abstractions is a goal in itself.

When deduplicating, abstract a shared concept, not just similar-looking code. Two blocks may look alike while implementing rules that should evolve independently. Some duplication is cheaper than coupling unrelated behavior.

Distinguish clarifying a concept that exists today from preparing for hypothetical future flexibility. Do not introduce factories, plugin systems, generic frameworks, or configuration switches solely for imagined future needs. When an abstraction needs many flags or caller-specific branches, reconsider whether it represents one concept.

## The Boy Scout Rule

Leave the code better than you found it, within the scope of the task.

Improvement often means deletion, not addition. Remove unused code, obsolete workarounds, unnecessary abstractions, misleading or redundant comments, and tests that provide no meaningful protection. Bad code does not need to be preserved merely because it already exists. Verify that apparently unused code has no relevant callers or external contract; when removing a poor implementation, preserve or replace any behavior that is still required. Apply the same judgment to tests: remove noise, not meaningful regression coverage.

Fix nearby naming, stale documentation, or unnecessary complexity when the improvement is clear and low risk. Keep behavior-preserving cleanup distinguishable from behavior changes. Avoid unrelated formatting churn, dependency upgrades, and broad refactors; report larger problems separately rather than silently expanding the task.

## Make Illegal States Unrepresentable

In languages that support it, use types to encode valid combinations of data. Prefer enums or discriminated unions for mutually exclusive states, and refined types for values with constraints.

This response permits both a result and an error, or neither, and any version number:

```rust
struct RpcResponse {
    version: usize,
    result: Option<String>,
    error: Option<String>,
}
```

If only version 1 and exactly one outcome are valid, the internal model can express that directly:

```rust
enum Version {
    V1,
}

struct RpcResponse<T, E> {
    version: Version,
    outcome: Result<T, E>,
}
```

This is an internal domain model, not a serialization specification. Parse the wire representation into it, rejecting unsupported versions and responses with both or neither outcome. Serialization annotations alone do not guarantee that malformed input is rejected; test the actual parser's behavior.

Do not use unrelated optional fields or boolean flags to represent a state machine. Give each state only the data valid for that state. Keep invariant-bearing fields private when unrestricted mutation would break the guarantee.

## Parse Don't Validate

At system boundaries, convert untrusted or weakly typed input into a type that represents the guarantees required by the rest of the program. Reject invalid input there. Once parsing succeeds, downstream code should be able to rely on those guarantees without checking them again.

Avoid validation functions that return a boolean but leave the value's type unchanged:

```rust
fn is_valid_port(value: u16) -> bool {
    value != 0
}

fn connect(port: u16) -> Result<(), Error> {
    if !is_valid_port(port) {
        return Err(Error::InvalidPort);
    }

    // `port` is still a `u16`; every caller must remember the invariant.
    todo!()
}
```

Instead, parse the value into a type whose constructor enforces the invariant:

```rust
struct Port(NonZeroU16);

impl TryFrom<u16> for Port {
    type Error = InvalidPort;

    fn try_from(value: u16) -> Result<Self, Self::Error> {
        NonZeroU16::new(value).map(Self).ok_or(InvalidPort)
    }
}

fn connect(port: Port) -> Result<(), Error> {
    // A zero port cannot reach this function.
    todo!()
}
```

Keep constructors that establish invariants distinct from operations on already parsed values. Prefer APIs that accept the refined type rather than repeatedly accepting primitives and revalidating them. Do not expose unchecked construction when doing so would let callers bypass the invariant.

Parsing does not only apply to strings. Deserialization, configuration loading, database reads, command-line arguments, environment variables, and external API responses are all boundaries where broad representations should become domain types. Preserve parsing errors with enough context for the caller to identify and report the invalid input.

If a guarantee cannot be represented in the language's type system, contain the check in the smallest possible module and expose an API whose contract makes the invariant clear. Assertions may defend internal invariants, but they are not a substitute for parsing untrusted input.

A parsed value only proves what was checked. Authorization, resource availability, and other facts that can change must still be checked at the point of use. Static type assertions or casts do not validate external data at runtime.

## Errors and failure modes

Make expected failures part of the operation's contract. Distinguish absence from failure: an empty collection, `None`, or a default value must not disguise a failed read or an invalid configuration.

- Catch errors where you can recover, translate them into a meaningful caller-facing error, or add useful context. Otherwise let them propagate.
- Preserve the underlying cause when adding context. Identify the failed operation without exposing credentials or sensitive input.
- Do not silently swallow exceptions, return success after partial failure, or add speculative fallbacks that mask defects.
- Reserve assertions and panics for broken internal invariants, not routine invalid input or unavailable services.
- Make retries bounded and deliberate. Consider whether repeating the operation is safe, and respect cancellation and deadlines.
- Log failures at the layer responsible for reporting them rather than logging and rethrowing at every layer.

## Prefer functional code

Functional programming is a strong default for understandable code. Prefer immutable values, pure functions, explicit inputs and outputs, and types that model the domain. These make behavior easier to reason about locally: understanding a function should not require reconstructing the history of shared mutable state.

Ideally, a function is pure: it computes an output from explicit inputs without changing anything outside itself or depending on hidden mutable state. Prefer this wherever possible. Reading the current time has no side effect, but still introduces a hidden input; pass the time in when practical. When effects are necessary, keep them explicit, narrowly scoped, and separate from pure computation. Minimize the code that performs effects and maximize the code that computes values.

Learn from functional languages even when working in an imperative one. Model alternatives with sum types, use pattern matching to handle their cases, transform data rather than coordinating mutations, and keep side effects separate from decision-making. Aim for a functional core with an imperative shell: compute decisions in pure functions, and perform I/O around them.

This is a preference for clear semantics, not a requirement to use functional-looking syntax. Avoid dense combinator chains, unnecessary currying, or elaborate abstractions when ordinary control flow is easier to follow. Local mutation is reasonable when it simplifies an implementation without leaking state or making behavior harder to predict.

Keep ownership clear. Do not store derived state unless there is a concrete need and a clear mechanism for keeping it consistent.

Make filesystem, network, clock, and randomness dependencies visible through the module's interface; avoid hidden global state and surprise I/O in otherwise simple-looking operations. This does not require wrapping every dependency in a new interface.

Use the language's structured cleanup mechanisms for files, locks, connections, and tasks. Make the owner responsible for releasing resources on success, failure, and cancellation. Keep concurrent work bounded and its lifetime tied to an explicit owner.

## Tests

Test observable behavior and contracts rather than private helper structure. A behavior-preserving refactor should not require rewriting tests simply because functions moved.

- Cover the main path, relevant edge cases, and meaningful failures. For a bug fix, add a regression test that fails without the fix when practical.
- For parsers and invariant-bearing types, test rejected input as well as accepted input. Exercise the real deserializer, not only manually constructed domain values.
- Keep tests deterministic. Control time and randomness where needed, and synchronize on events rather than arbitrary sleeps.
- Mock external interactions when needed, but do not mock away the behavior the test claims to verify. Prefer assertions about results and effects over incidental call sequences.
- Keep setup focused so the scenario and expected outcome are visible. Use test names that describe behavior, not just the function under test.

Test code is maintenance work, not an asset merely because it exists. Removing or consolidating tests is valid when they do not protect meaningful behavior: for example, assertions that cannot fail, tests that only verify their own mocks, or redundant cases that add no distinct coverage. Ask what realistic defect each test would catch. Strengthen or replace a weak test when the underlying behavior still needs protection; delete it when it adds no useful protection. Do not remove a test merely because it fails or is inconvenient to maintain, and preserve meaningful regression coverage.

## Before finishing

Check the changed code against these questions:

- Can a reader follow the main path and understand the names without reconstructing hidden assumptions?
- Do types and interfaces preserve the required invariants, including at input boundaries?
- Does each new helper or abstraction reduce the knowledge required of its callers?
- Are failures, side effects, and resource ownership explicit?
- Are the changes scoped to the task, with relevant tests and documentation updated?

Run the applicable formatter, linter, type checker, and tests available in the repository. Report what was checked and any checks that could not be run. Do not claim verification that did not happen.
