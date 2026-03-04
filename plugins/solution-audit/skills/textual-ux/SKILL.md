---
name: Textual UX
description: This skill should be used when the user asks to "audit text UX", "check error messages", "review microcopy", "assess user-facing text", "check tone consistency", "find jargon leakage", "audit messaging quality", or needs to evaluate the quality and consistency of all user-facing text in a solution.
version: 0.1.0
---

# Textual UX Audit

Audit the quality of all user-facing text — the voice and communication style of the solution. Every message, prompt, error, and label is a micro-interaction that shapes user perception and productivity.

## Core Concept

Textual UX measures how well a solution communicates with its users through text. Good textual UX means clear errors, consistent tone, appropriate verbosity, and zero internal jargon leakage. Text is often the only interface between a tool and its user.

## Audit Procedure

### 1. Inventory User-Facing Text

Scan the codebase to catalog all text that reaches users:

- **Error messages**: Exception handlers, validation errors, assertion messages
- **Log output**: Info, warning, and error log lines
- **Help text**: Command descriptions, flag help, usage strings
- **Prompts**: Interactive prompts, confirmations, input requests
- **Progress messages**: Status updates, completion messages
- **Success/failure messages**: Operation result communication

Use Grep to find common output patterns:
- `console.log`, `console.error`, `print`, `logging.`, `log.`
- `raise`, `throw`, `Error(`, `panic`
- String literals in CLI handler files
- Template strings in output formatting code

### 2. Assess Error Message Quality

For each error message found, evaluate:

- **What happened**: Does the message explain the problem clearly?
- **Why it happened**: Is context provided (e.g., which file, which input)?
- **How to fix it**: Does the message suggest a recovery action?
- **Tone**: Is it neutral and helpful (not blaming the user)?

Flag error messages that:
- Show raw exception names or stack traces
- Say "something went wrong" with no detail
- Blame the user ("invalid input" vs "expected a number, got 'abc'")
- Use internal code references meaningless to users
- Duplicate the same unhelpful message for different errors

Quality template for good errors:
```
Error: [What happened] — [Why]
  [Context: file, input, value]
  Hint: [How to fix]
```

### 3. Check Tone Consistency

Evaluate the overall voice across all text:

- **Formality level**: Consistent across all touchpoints (all casual or all formal)
- **Person**: Consistent use of "you"/"your" or impersonal style
- **Active voice**: Prefer "File saved" over "The file was saved"
- **Tense**: Present tense for current state, past for completed actions
- **Personality**: Consistent personality (professional, friendly, minimal)

Flag tone shifts:
- Casual prompts but formal error messages
- Inconsistent use of contractions (can't vs cannot)
- Mixed person (sometimes "you", sometimes "the user")
- Sudden personality changes between commands

### 4. Detect Terminology Leakage

Find internal jargon exposed to end users:

- **Code identifiers in messages**: Variable names, function names, class names
- **Internal concepts**: Architecture terms, module names, internal state names
- **Abbreviations**: Unexpanded abbreviations meaningful only to developers
- **Technical jargon**: Database terms, protocol names, encoding names
- **Debug information**: Memory addresses, object IDs, internal paths

Flag any text where a non-developer user would not understand a term without reading the source code.

### 5. Evaluate Verbosity Calibration

Assess whether text output is appropriately verbose:

- **Too verbose**: Overwhelming output for simple operations
- **Too terse**: Critical information missing from output
- **Context-appropriate**: More detail on errors, less on success
- **Progressive detail**: Verbosity increases with -v flags, not by default
- **Signal-to-noise**: Every line of output serves a purpose

Check for:
- Success messages that are longer than error messages
- Redundant information repeated in output
- Missing output for important state changes
- Debug information in default output

### 6. Check Message Differentiation

Verify that different message types are distinguishable:

- **Errors vs warnings**: Users can tell the difference immediately
- **Info vs debug**: Informational messages don't look like errors
- **Prefixes/labels**: Consistent markers ([ERROR], [WARN], [INFO])
- **Color coding**: If used, consistent and meaningful (red=error, yellow=warn)
- **Formatting**: Different types formatted differently

### 7. Assess Pluralization and Grammar

Check for common textual bugs:

- **Plural handling**: "1 files found" vs "1 file found"
- **Zero handling**: "Found 0 results" with appropriate message vs empty output
- **Article usage**: "a error" vs "an error"
- **Sentence structure**: Complete sentences in important messages
- **Punctuation**: Consistent use of periods, colons, dashes

### 8. Evaluate Confirmation Messages

For destructive or important operations:

- **Clear stakes**: User understands what will happen
- **Reversibility**: Stated whether the action can be undone
- **Safe default**: Default answer is the safe option (No for destructive)
- **Input format**: Clear what to type (y/N, yes/no, confirm)

## Finding Classification

| Severity | Criteria | Example |
|----------|----------|---------|
| Critical | Text actively confuses or misleads users | Error message suggests wrong fix, jargon-only errors |
| Warning | Text has quality or consistency issues | Tone inconsistency, missing error context |
| Info | Minor text improvements possible | Grammar fix, better word choice |

## Output Format

For each finding, report:
```
[SEVERITY] Category: Brief description
  File: source-file:line
  Text: "the actual user-facing text"
  Issue: What is wrong with it
  Suggestion: Improved version
```

## Scoring

Start at 100, subtract per finding:
- Critical: -15 points
- Warning: -7 points
- Info: -2 points

Score reflects how well the solution communicates with its users.
