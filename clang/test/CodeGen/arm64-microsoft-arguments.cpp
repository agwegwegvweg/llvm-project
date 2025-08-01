// RUN: %clang_cc1 -triple aarch64-windows -ffreestanding -emit-llvm -O0 \
// RUN: -x c++ -o - %s | FileCheck %s

// Pass and return for type size <= 8 bytes.
// CHECK: define {{.*}} i64 @{{.*}}f1{{.*}}()
// CHECK: call i64 {{.*}}func1{{.*}}(i64 %0)
struct S1 {
  int a[2];
};

S1 func1(S1 x);
S1 f1() {
  S1 x;
  return func1(x);
}

// Pass and return type size <= 16 bytes.
// CHECK: define {{.*}} [2 x i64] @{{.*}}f2{{.*}}()
// CHECK: call [2 x i64] {{.*}}func2{{.*}}([2 x i64] %0)
struct S2 {
  int a[4];
};

S2 func2(S2 x);
S2 f2() {
  S2 x;
  return func2(x);
}

// Pass and return for type size > 16 bytes.
// CHECK: define {{.*}} void @{{.*}}f3{{.*}}(ptr dead_on_unwind noalias writable sret(%struct.S3) align 4 %agg.result)
// CHECK: call void {{.*}}func3{{.*}}(ptr dead_on_unwind writable sret(%struct.S3) align 4 %agg.result, ptr dead_on_return noundef %agg.tmp)
struct S3 {
  int a[5];
};

S3 func3(S3 x);
S3 f3() {
  S3 x;
  return func3(x);
}

// Pass and return aggregate (of size < 16 bytes) with non-trivial destructor.
// Passed directly but returned indirectly.
// CHECK: define {{.*}} void {{.*}}f4{{.*}}(ptr dead_on_unwind inreg noalias writable sret(%struct.S4) align 4 %agg.result)
// CHECK: call void {{.*}}func4{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S4) align 4 %agg.result, [2 x i64] %0)
struct S4 {
  int a[3];
  ~S4();
};

S4 func4(S4 x);
S4 f4() {
  S4 x;
  return func4(x);
}

// Pass and return from instance method called from instance method.
// CHECK: define {{.*}} void @{{.*}}bar@Q1{{.*}}(ptr {{[^,]*}} %this, ptr dead_on_unwind inreg noalias writable sret(%class.P1) align 1 %agg.result)
// CHECK: call void {{.*}}foo@P1{{.*}}(ptr noundef{{[^,]*}} %ref.tmp, ptr dead_on_unwind inreg writable sret(%class.P1) align 1 %agg.result, i8 %0)

class P1 {
public:
  P1 foo(P1 x);
};

class Q1 {
public:
  P1 bar();
};

P1 Q1::bar() {
  P1 p1;
  return P1().foo(p1);
}

// Pass and return from instance method called from free function.
// CHECK: define {{.*}} void {{.*}}bar{{.*}}()
// CHECK: call void {{.*}}foo@P2{{.*}}(ptr noundef{{[^,]*}} %ref.tmp, ptr dead_on_unwind inreg writable sret(%class.P2) align 1 %retval, i8 %0)
class P2 {
public:
  P2 foo(P2 x);
};

P2 bar() {
  P2 p2;
  return P2().foo(p2);
}

// Pass and return an object with a user-provided constructor (passed directly,
// returned indirectly)
// CHECK: define {{.*}} void @{{.*}}f5{{.*}}(ptr dead_on_unwind inreg noalias writable sret(%struct.S5) align 4 %agg.result)
// CHECK: call void {{.*}}func5{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S5) align 4 %agg.result, i64 {{.*}})
struct S5 {
  S5();
  int x;
};

S5 func5(S5 x);
S5 f5() {
  S5 x;
  return func5(x);
}

// Pass and return an object with a non-trivial explicitly defaulted constructor
// (passed directly, returned directly)
// CHECK: define {{.*}} i8 @"?f6@@YA?AUS6@@XZ"()
// CHECK: call i8 {{.*}}func6{{.*}}(i64 {{.*}})
struct S6a {
  S6a();
};

struct S6 {
  S6() = default;
  S6a x;
};

S6 func6(S6 x);
S6 f6() {
  S6 x;
  return func6(x);
}

// Pass and return an object with a non-trivial implicitly defaulted constructor
// (passed directly, returned directly)
// CHECK: define {{.*}} i8 @"?f7@@YA?AUS7@@XZ"()
// CHECK: call i8 {{.*}}func7{{.*}}(i64 {{.*}})
struct S7 {
  S6a x;
};

S7 func7(S7 x);
S7 f7() {
  S7 x;
  return func7(x);
}

struct S8a {
  ~S8a();
};

// Pass and return an object with a non-trivial default destructor (passed
// directly, returne indirectly)
struct S8 {
  S8a x;
  int y;
};

// CHECK: define {{.*}} void {{.*}}?f8{{.*}}(ptr dead_on_unwind inreg noalias writable sret(%struct.S8) align 4 {{.*}})
// CHECK: call void {{.*}}func8{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S8) align 4 {{.*}}, i64 {{.*}})
S8 func8(S8 x);
S8 f8() {
  S8 x;
  return func8(x);
}


// Pass and return an object with a non-trivial copy-assignment operator and
// a trivial copy constructor (passed directly, returned indirectly)
// CHECK: define {{.*}} void @"?f9@@YA?AUS9@@XZ"(ptr dead_on_unwind inreg noalias writable sret(%struct.S9) align 4 {{.*}})
// CHECK: call void {{.*}}func9{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S9) align 4 {{.*}}, i64 {{.*}})
struct S9 {
  S9& operator=(const S9&);
  int x;
};

S9 func9(S9 x);
S9 f9() {
  S9 x;
  S9 y = x;
  x = y;
  return func9(x);
}

// Pass and return an object with a base class (passed directly, returned
// indirectly).
// CHECK: define dso_local void {{.*}}f10{{.*}}(ptr dead_on_unwind inreg noalias writable sret(%struct.S10) align 4 {{.*}})
// CHECK: call void {{.*}}func10{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S10) align 4 {{.*}}, [2 x i64] {{.*}})
struct S10 : public S1 {
  int x;
};

S10 func10(S10 x);
S10 f10() {
  S10 x;
  return func10(x);
}


// Pass and return a non aggregate object exceeding > 128 bits (passed
// indirectly, returned indirectly)
// CHECK: define dso_local void {{.*}}f11{{.*}}(ptr dead_on_unwind inreg noalias writable sret(%struct.S11) align 8 {{.*}})
// CHECK: call void {{.*}}func11{{.*}}(ptr dead_on_unwind inreg writable sret(%struct.S11) align 8 {{.*}}, ptr {{.*}})
struct S11 {
  virtual void f();
  int a[5];
};

S11 func11(S11 x);
S11 f11() {
  S11 x;
  return func11(x);
}

// GH86384
// Pass and return object with template constructor (pass directly,
// return indirectly).
// CHECK: define dso_local void @"?f12@@YA?AUS12@@XZ"(ptr dead_on_unwind inreg noalias writable sret(%struct.S12) align 4 {{.*}})
// CHECK: call void @"?func12@@YA?AUS12@@U1@@Z"(ptr dead_on_unwind inreg writable sret(%struct.S12) align 4 {{.*}}, i64 {{.*}})
struct S12 {
  template<typename T> S12(T*) {}
  int x;
};
S12 func12(S12 x);
S12 f12() {
  S12 x((int*)0);
  return func12(x);
}
