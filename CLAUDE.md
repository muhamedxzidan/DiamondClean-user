# CLAUDE.md — Strict Engineering Rules & Autonomous AI Guidelines (Flutter/Dart)

---
> After reading this file, reply only with: "Rules loaded ✓" — no summary needed.

## I. Autonomous AI Workflow & Execution (Agentic Behavior)

**1. The "Chain of Thought" Requirement**
You must NEVER write code immediately. For any complex task, output a `<thinking>` block or a step-by-step `<plan>`. Outline the files you will touch, the state changes in Cubit, and the widget tree structure before generating any Dart code.

**2. Read Before Write & Context Awareness**
Before creating a new Model, Repository, Screen, or Widget, you MUST search the `lib/` folder to check if a similar component already exists. Do not duplicate logic. Always inspect `pubspec.yaml` and the specific feature's directory structure before implementing changes.

**3. The "No-Ghost-Code" Rule**
When modifying existing files, DO NOT output placeholder comments like `// ... existing code ...`. Provide the exact, fully functional code blocks or use targeted file edits. Never break existing logic just to add a new feature.

**4. Senior Engineer Behavior & Zero Assumptions**
Your responses must reflect senior engineering practices. Architecture violations must be challenged. If requirements are unclear, you must ask for clarification before proceeding.

**5. Task Completion Checklist**
Every completed task must conclude with:
- Summary of changes made.
- Edge cases handled.
- Necessary terminal commands (e.g., `dart run build_runner build -d`).
- Suggested Conventional Commit message.

---

## II. Architecture & Structure

**6. Two-Layer Architecture (Intentional — No Domain Layer)**
Use a simplified architecture with two layers only:
- **Data Layer** (Models, Repositories)
- **Presentation Layer** (Cubit, Screens, Widgets)

> Use Case logic lives inside the Cubit directly. Do NOT add a `domain/` folder. This is intentional — do not suggest or add a domain layer.

**7. Feature-Based Structure**
Code must be organized by feature. Each feature must follow this **exact** structure and be self-contained.
The `cubit/` folder is a **direct child of the feature folder** — NOT inside `presentation/`.

```
auth/                        ← feature folder
├─ cubit/                    ← state management (top-level inside feature)
│  ├─ auth_cubit.dart
│  └─ auth_state.dart
├─ data/                     ← data layer
│  ├─ models/
│  │  └─ user_model.dart
│  └─ repositories/
│     ├─ auth_repository_base.dart   ← abstract class (DIP)
│     └─ auth_repository.dart        ← implementation
└─ presentation/             ← UI layer
   ├─ screens/
   │  └─ login_screen.dart
   └─ widgets/
      ├─ login_form.dart
      └─ login_header.dart
```

> This structure applies to **every** feature without exception. Do NOT place `cubit/` inside `presentation/`.

**8. Core Layer Discipline**
The `core/` folder contains **shared infrastructure only**:
```
core/
├─ constants/       # AppColors, AppTextStyles, AppStrings, AppSizes
├─ theme/
├─ network/
├─ errors/
├─ extensions/
├─ responsive/      # ResponsiveLayout, screen size helpers
└─ shared_widgets/  # Reusable widgets used across features
```
NO feature-specific code is allowed inside `core/`.

**9. Strict Data Flow**
Application flow must ALWAYS follow:
```
UI → Cubit → Repository → Firebase / API / Local Storage
```
Widgets must NEVER access repositories directly.

---

## III. Core System Rules

**10. Constants & Theming (Class-Based — Always)**
All shared values must live in dedicated classes inside `core/constants/`. Never use raw hardcoded values anywhere in the codebase.

```dart
// ✅ Correct
AppColors.primary
AppTextStyles.heading1
AppStrings.loginTitle
AppSizes.paddingMedium

// ❌ Wrong
Color(0xFF1976D2)
TextStyle(fontSize: 18)
'Login'
EdgeInsets.all(16)
```

Each constant type must have its own class:
- `AppColors` — all colors
- `AppTextStyles` — all text styles
- `AppStrings` — all UI strings
- `AppSizes` — all spacing, padding, radius values

**11. Responsive System (flutter_screenutil)**
Always use `flutter_screenutil` for sizing. Never use hardcoded pixel values.

```dart
// ✅ Correct
SizedBox(height: 16.h, width: double.infinity)
Text('Hello', style: TextStyle(fontSize: 14.sp))
Padding(padding: EdgeInsets.all(12.w))

// ❌ Wrong
SizedBox(height: 16)
TextStyle(fontSize: 14)
```

Use a `ResponsiveLayout` widget in `core/responsive/` when layout differs between **mobile and tablet**. All responsive-related variables, classes, and widgets must have **clear, self-explanatory names** that reflect their purpose and target screen:

```dart
ResponsiveLayout(
  mobileLayout: MobileHomeScreen(),
  tabletLayout: TabletHomeScreen(),
)
// e.g. tabletSidebarWidth, mobileCardPadding
```

**12. Navigation (Named Routes)**
Use Flutter's built-in named routes with `Navigator.pushNamed`. Define all route names as constants in `AppRoutes`.

```dart
// core/constants/app_routes.dart
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
}

// Usage
Navigator.pushNamed(context, AppRoutes.home);
Navigator.pushReplacementNamed(context, AppRoutes.login);
```
Never use hardcoded route strings outside `AppRoutes`.

---

## IV. Data Layer Rules

**13. Strict Type Safety & Serialization**
Models represent API or database structures. They must NEVER use `dynamic` types. Always explicitly map JSON data safely. If a key might be missing, provide a sensible default or handle null gracefully. Never pass raw `Map<String, dynamic>` between layers — always convert to a typed model.

```dart
class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
```

> Models use **manual serialization only** — no code generation (`freezed`, `json_serializable`).

**14. Repository Responsibility**
Repositories manage data access, call APIs/Firebase, handle responses, convert to models, and return strongly typed results to the Cubit. They must strictly isolate Cubits from networking logic. Do not use generic Maps for data passing.

---

## V. Presentation Layer Rules

**15. Cubit & State (flutter_bloc)**
Always use **Cubit** (not Bloc) unless the feature explicitly requires event-driven logic.

State must use **sealed classes** with this naming pattern: `FeatureInitial / FeatureLoading / FeatureSuccess / FeatureFailure`. Never use generic names like `LoadingState` or `ErrorState`.

```dart
sealed class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final UserModel user;
  LoginSuccess(this.user);
}
class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}
```

Cubits must NOT contain any UI code or `BuildContext`-dependent logic.

**16. Screen Responsibility (Thin Compositor)**
Screens must act as thin compositors only:
- Compose child widgets with layout and spacing.
- Must NOT contain inline UI logic, `BlocBuilder`, `BlocConsumer`, or `ListView` directly.
- Always break down the UI into sub-widgets first in the `<plan>` before writing any code.

```dart
// ✅ Correct — thin screen
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LoginHeader(),
          LoginForm(),
          LoginFooter(),
        ],
      ),
    );
  }
}
```

**17. Widget Decomposition (Always Split)**
Every distinct UI section must be extracted into its own file inside the feature's `widgets/` folder.
- Widget > 100 lines → **must split**.
- Any custom widget that can be reused or independently modified → **split immediately**.
- Prefer many small, focused widgets — easier and safer to edit later.
- `BlocBuilder` and `BlocConsumer` belong in widgets, not in screens.

**18. Widget Responsibility**
Widgets must render UI, listen to Cubit state, and trigger Cubit actions. Widgets must NEVER contain business logic.

**18a. setState is STRICTLY FORBIDDEN**
`setState` must NEVER be used anywhere in the codebase — no exceptions.
All state changes must go through Cubit. If you feel you need `setState`, use a Cubit instead.

```dart
// ✅ Correct — state via Cubit
context.read<LoginCubit>().onEmailChanged(value);

// ❌ FORBIDDEN — never use setState
setState(() { _isLoading = true; });
```

Local UI-only state (e.g. animation controllers, focus nodes, TextEditingController) is the ONLY exception —
and only when it has absolutely zero business logic attached to it. Even then, prefer extracting it into a dedicated widget.

**18b. Strict UI / Logic Separation**
UI and business logic must be completely separated at all times — for future maintainability and scalability.

| Layer | Responsibility | Must NOT contain |
|---|---|---|
| Widget | Render UI, display state | Any logic, calculations, conditions |
| Cubit | Logic, state transitions | Any UI code, BuildContext, navigation |
| Repository | Data access, API calls | Any UI or state logic |

Rules:
- Widgets read state from Cubit and call Cubit methods — nothing more.
- All conditions, validations, and calculations live in the Cubit.
- All data transformations live in the Repository.
- This separation makes every layer independently testable and editable without touching others.

```dart
// ✅ Correct — widget is pure UI, zero logic
BlocBuilder<OrderCubit, OrderState>(
  buildWhen: (prev, curr) => curr is OrderSuccess || curr is OrderFailure,
  builder: (context, state) {
    if (state is OrderSuccess) return OrderListWidget(orders: state.orders);
    if (state is OrderFailure) return ErrorWidget(message: state.message);
    return const LoadingWidget();
  },
)

// ❌ Wrong — logic inside widget
builder: (context, state) {
  final filtered = state.orders.where((o) => o.status == "active").toList(); // logic in UI!
  return OrderListWidget(orders: filtered);
}
```

---

## VI. SOLID Principles & OOP

**19. Single Responsibility Principle (SRP)**
Every class must have one reason to change. One class = one job.
- `LoginCubit` → handles login state only, not registration.
- `AuthRepository` → handles auth data only, not user profile data.
- `LoginButton` widget → renders and triggers login only.

```dart
// ✅ Correct — each class has one job
class OrderRepository { Future<OrderModel> fetchOrder(String id) async {...} }
class InvoiceRepository { Future<void> sendInvoice(OrderModel order) async {...} }

// ❌ Wrong — two responsibilities in one class
class OrderRepository {
  Future<OrderModel> fetchOrder(String id) async {...}
  Future<void> sendInvoice(OrderModel order) async {...} // not order's job
}
```

**20. Open/Closed Principle (OCP)**
Classes must be open for extension, closed for modification. Add behavior by extending, not editing existing code.

```dart
// ✅ Correct — extend behavior via abstract class
abstract class PaymentMethod { Future<void> pay(double amount); }
class CashPayment extends PaymentMethod { @override Future<void> pay(double amount) async {...} }
class CardPayment extends PaymentMethod { @override Future<void> pay(double amount) async {...} }
// Adding a new method = new class, no changes to existing ones
```

**21. Liskov Substitution Principle (LSP)**
Subclasses must be usable wherever the parent is used without breaking behavior.

```dart
// ✅ Correct — subclass behaves as expected
abstract class BaseRepository { Future<List<dynamic>> fetchAll(); }
class OrderRepository extends BaseRepository {
  @override Future<List<OrderModel>> fetchAll() async { return [...]; }
}
```

**22. Interface Segregation Principle (ISP)**
Never force a class to implement methods it doesn't use. Split large abstract classes into focused ones.

```dart
// ✅ Correct — focused interfaces
abstract class Readable { Future<List<OrderModel>> fetchAll(); }
abstract class Writable { Future<void> save(OrderModel order); }

class OrderRepository implements Readable, Writable { ... }
class ReportRepository implements Readable { ... } // read-only, no save needed
```

**23. Dependency Inversion Principle (DIP)**
Cubits and high-level classes must depend on abstractions (abstract classes), not concrete implementations.

```dart
// ✅ Correct — Cubit depends on abstract, not concrete
abstract class AuthRepositoryBase { Future<UserModel> login(String email, String password); }
class AuthRepository implements AuthRepositoryBase { ... }

class LoginCubit extends Cubit<LoginState> {
  final AuthRepositoryBase repo; // depends on abstraction
  LoginCubit(this.repo) : super(LoginInitial());
}

// ❌ Wrong — depends on concrete class directly
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository repo; // tightly coupled
}
```

**24. OOP Encapsulation**
Never expose internal state or logic publicly unless necessary. Use private fields and expose only what's needed.

```dart
// ✅ Correct
class OrderRepository {
  final _firestore = FirebaseFirestore.instance; // private
  Future<OrderModel> fetchOrder(String id) async { ... } // public API only
}
```

---

## VII. Cubit Performance Rules

**25. buildWhen — Targeted Rebuilds Only**
Always use `buildWhen` in `BlocBuilder` and `BlocConsumer` to prevent unnecessary widget rebuilds. Only rebuild when the relevant part of the state actually changes.

```dart
// ✅ Correct — rebuilds only when state type changes to avoid redundant renders
BlocBuilder<OrderCubit, OrderState>(
  // Only rebuild when transitioning to Success or Failure — not on every emit
  buildWhen: (previous, current) =>
      current is OrderSuccess || current is OrderFailure,
  builder: (context, state) {
    // This widget will NOT rebuild on OrderLoading if it was already loading
    if (state is OrderSuccess) return OrderList(orders: state.orders);
    if (state is OrderFailure) return ErrorWidget(message: state.message);
    return const SizedBox.shrink();
  },
)

// ❌ Wrong — rebuilds on every single state change, even irrelevant ones
BlocBuilder<OrderCubit, OrderState>(
  builder: (context, state) { ... },
)
```

Use `listenWhen` in `BlocConsumer` the same way — only listen to state changes that require a side effect (e.g., showing a SnackBar or navigating).

```dart
BlocConsumer<LoginCubit, LoginState>(
  // Only listen when login succeeds or fails — not during loading
  listenWhen: (previous, current) =>
      current is LoginSuccess || current is LoginFailure,
  listener: (context, state) {
    if (state is LoginSuccess) Navigator.pushNamed(context, AppRoutes.home);
    if (state is LoginFailure) ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message)));
  },
  // Only rebuild the button/form area when loading state changes
  buildWhen: (previous, current) =>
      current is LoginLoading || current is LoginInitial,
  builder: (context, state) {
    return LoginFormWidget(isLoading: state is LoginLoading);
  },
)
```

**26. Debounced Search (Performance-First)**
Any search feature MUST use debouncing. Never call the repository on every keystroke — wait until the user stops typing (300–500ms), then search. This saves resources and avoids flooding Firebase/API.

```dart
// In the Cubit:
import 'dart:async';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepositoryBase _repo;
  Timer? _debounceTimer; // tracks the pending search timer

  SearchCubit(this._repo) : super(SearchInitial());

  /// Called on every keystroke from the search field.
  /// Waits 400ms after the user stops typing before executing the search.
  /// Cancels any previous pending search to avoid redundant calls.
  void onSearchChanged(String query) {
    _debounceTimer?.cancel(); // cancel previous timer if user is still typing

    if (query.trim().isEmpty) {
      emit(SearchInitial()); // clear results immediately if query is empty
      return;
    }

    // Start a new timer — search fires only after 400ms of silence
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    emit(SearchLoading());
    try {
      final results = await _repo.search(query);
      emit(SearchSuccess(results: results));
    } catch (e) {
      emit(SearchFailure(message: 'Search failed. Please try again.'));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel(); // always clean up timer when Cubit is disposed
    return super.close();
  }
}
```

```dart
// In the Widget — TextField calls onSearchChanged on every keystroke:
TextField(
  onChanged: context.read<SearchCubit>().onSearchChanged,
  decoration: const InputDecoration(
    hintText: AppStrings.searchHint,
  ),
)
```

---

## VIII. Code Commenting & Traceability

**27. Mandatory Inline Comments**
Every non-trivial piece of logic MUST have a clear Arabic or English comment explaining:
- **What** this code does.
- **Why** this approach was chosen (if not obvious).
- **Important side effects** or constraints.

```dart
// ✅ Correct — logic is traceable and understandable
Timer? _debounceTimer;

void onSearchChanged(String query) {
  _debounceTimer?.cancel(); // cancel any pending search to avoid duplicate calls

  if (query.trim().isEmpty) {
    emit(SearchInitial()); // reset to initial state when search is cleared
    return;
  }

  // delay search by 400ms after user stops typing — saves API/Firebase calls
  _debounceTimer = Timer(const Duration(milliseconds: 400), () {
    _performSearch(query.trim());
  });
}

// ❌ Wrong — no explanation, impossible to maintain
_debounceTimer?.cancel();
_debounceTimer = Timer(const Duration(milliseconds: 400), () => _performSearch(query));
```

**28. Document Public APIs**
All public methods in Repositories and Cubits must have a doc comment (`///`) explaining what they do, their parameters, and what they return or emit.

```dart
/// Fetches all orders for the given [userId] from Firestore.
/// Emits [OrderLoading] → [OrderSuccess] or [OrderFailure].
/// Throws nothing — all errors are caught and emitted as [OrderFailure].
Future<void> loadOrders(String userId) async { ... }
```

---

## IX. Code Quality & Flutter Best Practices

**29. Simplicity Over Complexity**
Always prefer simple, clear, lightweight solutions. Avoid heavy packages or complex patterns when a straightforward alternative exists. If a package adds significant complexity for a minor benefit, propose a simpler alternative and explain the tradeoff.

**30. Performance First**
Use `const` constructors whenever possible. Use `StatelessWidget` by default unless local mutable state (animations, `TextEditingController`) is strictly required.

**31. Modern Dart Features**
Use modern Dart features when they improve clarity: `sealed` classes, pattern matching, and records — primarily for Cubit states and Repository return types.

**32. File Sizing**
- File > 200 lines → split.
- Widget > 100 lines → split.

**33. Official Naming Conventions**

| Type | Convention | Example |
|---|---|---|
| Files & folders | `snake_case` | `login_cubit.dart` |
| Classes | `PascalCase` | `UserModel` |
| Variables & methods | `camelCase` | `fetchUserData()` |
| Responsive variables | Descriptive + target | `tabletCardWidth`, `mobileHeaderHeight` |

---

## X. Firebase Rules

**34. Firebase Discipline**
- Always use `try/catch` with `FirebaseAuthException` for auth operations.
- Always handle Firestore errors explicitly — never let queries fail silently.
- Never expose Firebase config in code — use `firebase_options.dart` via FlutterFire CLI only.
- Use `flutter_secure_storage` for any sensitive local data.

---

## XI. Error Handling & Security

**35. Explicit Error Handling**
API and Firebase calls must never fail silently. Use structured `try/catch` with a Result/Failure pattern returned to the Cubit.

**36. Meaningful Error Messages**
Avoid generic errors like `"Something went wrong"`. Use specific messages:
- `"Invalid email or password"`
- `"Network connection failed"`
- `"You don't have permission to access this resource"`

**37. Root Cause & Minimal Surface**
Always fix the root cause of bugs — avoid temporary patches. Modify the **smallest possible number of files** when fixing issues.

**38. Security Discipline**
Never hardcode API keys, tokens, or credentials. Use environment variables or `flutter_secure_storage`.

---

## XIII. Core Packages Reference

| Purpose | Package |
|---|---|
| State management | `flutter_bloc` |
| Responsive sizing | `flutter_screenutil` |
| Firebase Auth | `firebase_auth` |
| Firestore | `cloud_firestore` |
| Firebase Storage | `firebase_storage` |
| Secure storage | `flutter_secure_storage` |
| Navigation | Flutter named routes (built-in) |
| Models | Manual `fromJson/toJson` |

---

## XIV. Target Platform

- **Primary target**: Android (`arm64-v8a`)
- **Distribution**: Manual APK (non-Play Store)
- Always consider APK size — avoid adding heavy packages without justification.
