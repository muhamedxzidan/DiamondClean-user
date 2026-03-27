


# Strict Engineering Rules & Autonomous AI Guidelines (Flutter/Dart)

---

## I. Autonomous AI Workflow & Execution (Agentic Behavior)

1. The "Chain of Thought" Requirement
You must NEVER write code immediately. For any complex task, output a `<thinking>` block or a step-by-step `<plan>`. Outline the files you will touch, the state changes in Cubit, and the widget tree structure before generating any Dart code.

2. Read Before Write & Context Awareness
Before creating a new Model, Repository, or Screen, you MUST search the `lib/` folder to check if a similar component already exists. Do not duplicate logic. Always inspect `pubspec.yaml` and the specific feature's directory structure before implementing changes.

3. The "No-Ghost-Code" Rule
When modifying existing files, DO NOT output placeholder comments like `// ... existing code ...`. Provide the exact, fully functional code blocks or use targeted file edits. Never break existing logic just to add a new feature.

4. Senior Engineer Behavior & Zero Assumptions
Your responses must reflect senior engineering practices. Architecture violations must be challenged. If requirements are unclear, you must ask for clarification before proceeding.

5. Task Completion Checklist
Every completed task must conclude with:
- Summary of changes made.
- Edge cases handled.
- Necessary terminal commands (e.g., `dart run build_runner build -d`).
- Suggested Conventional Commit message.

---

## II. Architecture & Structure

6. Two-Layer Architecture
Use a simplified architecture with two layers:
- Data Layer (Models, Repositories)
- Presentation Layer (Cubit, Screens, Widgets)

7. Feature-Based Structure
Code must be organized by feature. Each feature must follow this exact structure and be self-contained:
feature_name/
├─ data/
│  ├─ models/
│  └─ repositories/
└─ presentation/
   ├─ cubit/
   ├─ screens/
   └─ widgets/

8. Core Layer Discipline
The `core/` folder contains shared infrastructure (constants, theme, network, errors, extensions, shared_widgets). NO feature-specific code is allowed inside `core/`.

9. Strict Data Flow
Application flow must ALWAYS follow:
UI → Cubit → Repository → API / Firebase / Local Storage.
Widgets must NEVER access repositories directly.

---

## III. Data Layer Rules (Strict API Integration)

10. Strict Type Safety & Serialization
Models represent API or database structures. They must NEVER use `dynamic` types. Always explicitly map JSON data safely. If a key might be missing from the API, provide a sensible default or handle the null value gracefully. 

11. Repository Responsibility
Repositories manage data access, call APIs, handle responses, convert to models, and return results to the Cubit. They must strictly isolate Cubits from networking logic. Do not use generic Maps for data passing; always strongly type the return values.

---

## IV. Presentation Layer Rules (UI & State)

12. Cubit Responsibility
Cubits manage state, feature logic, and interaction with repositories. Cubits must NOT contain any UI code or context-dependent logic.

13. UI/UX Prototyping & Composition Pattern
Screens must act as thin compositors.
- Screen widgets only compose child widgets with layout and spacing.
- Screen widgets must NOT contain inline UI logic, `BlocBuilder`/`BlocConsumer`, or `ListView` directly.
- Always start by breaking down the UI into smaller sub-widgets in your `<plan>` and extract every distinct UI section into its own widget file inside the `widgets/` folder immediately.

14. Widget Responsibility
Widgets must render UI, listen to Cubit state, and trigger Cubit actions. Widgets must NEVER contain business logic.

---

## V. Code Quality & Flutter Best Practices

15. Single Responsibility & File Sizing
Files must remain small and focused. 
- File > 200 lines → split.
- Widget > 100 lines → split.

16. Performance First
Use `const` constructors whenever possible. Use `StatelessWidget` by default unless local mutable state (like animations or text controllers) is strictly required.

17. Modern Dart Features
Use modern Dart features when they improve clarity: `sealed` classes, pattern matching, and records (primarily for Cubit states and Repository return types).

18. Official Naming Conventions
- `snake_case` → files and folders (e.g., `login_cubit.dart`)
- `PascalCase` → classes (e.g., `UserModel`)
- `camelCase` → variables and methods

---

## VI. Logic, Error Handling & Security

19. Explicit Error Handling
API calls must never fail silently. Use structured error handling (`try/catch` with a Result/Failure pattern).

20. Meaningful Error Messages
Avoid generic errors like "Something went wrong". Use specific messages (e.g., "Invalid email or password", "Network connection failed").

21. Root Cause & Minimal Surface
Always fix the root cause of bugs; avoid temporary patches. Modify the smallest possible number of files when fixing issues.

22. Security Discipline
Never hardcode API keys, tokens, or credentials. Use environment variables or secure storage.


