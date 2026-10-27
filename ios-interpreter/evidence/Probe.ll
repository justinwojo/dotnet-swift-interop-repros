; ModuleID = 'artifacts/Probe.ll'
source_filename = "artifacts/Probe.ll"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-ios16.0.0-simulator"

%swift.vwtable = type { ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i32, i32 }
%swift.type_descriptor = type opaque
%swift.type_metadata_record = type { i32 }
%swift.type = type { i64 }
%T12InteropProbe4FiveV = type <{ %Ts5Int64V, %Ts5Int64V, %Ts5Int64V, %Ts5Int64V, %Ts5Int64V }>
%Ts5Int64V = type <{ i64 }>
%swift.metadata_response = type { ptr, i64 }

@"$s12InteropProbe4FiveV1as5Int64VvpMV" = unnamed_addr constant <{ i32 }> <{ i32 25165824 }>, align 4
@"$s12InteropProbe4FiveV1bs5Int64VvpMV" = unnamed_addr constant <{ i32 }> <{ i32 25165832 }>, align 4
@"$s12InteropProbe4FiveV1cs5Int64VvpMV" = unnamed_addr constant <{ i32 }> <{ i32 25165840 }>, align 4
@"$s12InteropProbe4FiveV1ds5Int64VvpMV" = unnamed_addr constant <{ i32 }> <{ i32 25165848 }>, align 4
@"$s12InteropProbe4FiveV1es5Int64VvpMV" = unnamed_addr constant <{ i32 }> <{ i32 25165856 }>, align 4
@"$s12InteropProbe4FiveVWV" = internal constant %swift.vwtable { ptr @"$s12InteropProbe4FiveVwCP", ptr @__swift_noop_void_return, ptr @__swift_memcpy40_8, ptr @__swift_memcpy40_8, ptr @__swift_memcpy40_8, ptr @__swift_memcpy40_8, ptr @"$s12InteropProbe4FiveVwet", ptr @"$s12InteropProbe4FiveVwst", i64 40, i64 40, i32 131079, i32 0 }, align 8
@.str.12.InteropProbe = private constant [13 x i8] c"InteropProbe\00"
@"$s12InteropProbeMXM" = linkonce_odr hidden constant <{ i32, i32, i32 }> <{ i32 0, i32 0, i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.12.InteropProbe to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32 }>, ptr @"$s12InteropProbeMXM", i32 0, i32 2) to i64)) to i32) }>, section "__TEXT,__constg_swiftt", align 4
@.str.4.Five = private constant [5 x i8] c"Five\00"
@"$s12InteropProbe4FiveVMn" = constant <{ i32, i32, i32, i32, i32, i32, i32 }> <{ i32 81, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s12InteropProbeMXM" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s12InteropProbe4FiveVMn", i32 0, i32 1) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @.str.4.Five to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s12InteropProbe4FiveVMn", i32 0, i32 2) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s12InteropProbe4FiveVMa" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s12InteropProbe4FiveVMn", i32 0, i32 3) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s12InteropProbe4FiveVMF" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i32, i32, i32, i32, i32, i32, i32 }>, ptr @"$s12InteropProbe4FiveVMn", i32 0, i32 4) to i64)) to i32), i32 5, i32 2 }>, section "__TEXT,__constg_swiftt", align 4
@"$s12InteropProbe4FiveVMf" = internal constant <{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }> <{ ptr null, ptr @"$s12InteropProbe4FiveVWV", i64 512, ptr @"$s12InteropProbe4FiveVMn", i32 0, i32 8, i32 16, i32 24, i32 32, [4 x i8] zeroinitializer }>, align 8
@"symbolic _____ 12InteropProbe4FiveV" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 1, i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s12InteropProbe4FiveVMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ 12InteropProbe4FiveV", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@"$ss5Int64VMn" = external global %swift.type_descriptor, align 4
@"got.$ss5Int64VMn" = private unnamed_addr constant ptr @"$ss5Int64VMn"
@"symbolic _____ s5Int64V" = linkonce_odr hidden constant <{ i8, i32, i8 }> <{ i8 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"got.$ss5Int64VMn" to i64), i64 ptrtoint (ptr getelementptr inbounds (<{ i8, i32, i8 }>, ptr @"symbolic _____ s5Int64V", i32 0, i32 1) to i64)) to i32), i8 0 }>, section "__TEXT,__swift5_typeref, regular", no_sanitize_address, align 2
@0 = private constant [2 x i8] c"a\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@1 = private constant [2 x i8] c"b\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@2 = private constant [2 x i8] c"c\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@3 = private constant [2 x i8] c"d\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@4 = private constant [2 x i8] c"e\00", section "__TEXT,__swift5_reflstr, regular", no_sanitize_address
@"$s12InteropProbe4FiveVMF" = internal constant { i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 } { i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ 12InteropProbe4FiveV" to i64), i64 ptrtoint (ptr @"$s12InteropProbe4FiveVMF" to i64)) to i32), i32 0, i16 0, i16 12, i32 5, i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int64V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 6) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @0 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 7) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int64V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 9) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @1 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 10) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int64V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 12) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @2 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 13) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int64V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 15) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @3 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 16) to i64)) to i32), i32 2, i32 trunc (i64 sub (i64 ptrtoint (ptr @"symbolic _____ s5Int64V" to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 18) to i64)) to i32), i32 trunc (i64 sub (i64 ptrtoint (ptr @4 to i64), i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, i16, i16, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }, ptr @"$s12InteropProbe4FiveVMF", i32 0, i32 19) to i64)) to i32) }, section "__TEXT,__swift5_fieldmd, regular", no_sanitize_address, align 4
@"$s12InteropProbe4FiveVHn" = private constant %swift.type_metadata_record { i32 trunc (i64 sub (i64 ptrtoint (ptr @"$s12InteropProbe4FiveVMn" to i64), i64 ptrtoint (ptr @"$s12InteropProbe4FiveVHn" to i64)) to i32) }, section "__TEXT, __swift5_types, regular", no_sanitize_address, align 4
@__swift_reflection_version = linkonce_odr hidden constant i16 3
@llvm.used = appending global [35 x ptr] [ptr @"$s12InteropProbe14captureControlyySv_s5Int64VA2DtF", ptr @"$s12InteropProbe14combineControlyySv_Svs5Int64VADtF", ptr @"$s12InteropProbe14invokeCallbackys5Int64VSV_ADtF", ptr @"$s12InteropProbe4FiveV1as5Int64VvM", ptr @"$s12InteropProbe4FiveV1as5Int64Vvg", ptr @"$s12InteropProbe4FiveV1as5Int64VvpMV", ptr @"$s12InteropProbe4FiveV1as5Int64Vvs", ptr @"$s12InteropProbe4FiveV1bs5Int64VvM", ptr @"$s12InteropProbe4FiveV1bs5Int64Vvg", ptr @"$s12InteropProbe4FiveV1bs5Int64VvpMV", ptr @"$s12InteropProbe4FiveV1bs5Int64Vvs", ptr @"$s12InteropProbe4FiveV1cs5Int64VvM", ptr @"$s12InteropProbe4FiveV1cs5Int64Vvg", ptr @"$s12InteropProbe4FiveV1cs5Int64VvpMV", ptr @"$s12InteropProbe4FiveV1cs5Int64Vvs", ptr @"$s12InteropProbe4FiveV1ds5Int64VvM", ptr @"$s12InteropProbe4FiveV1ds5Int64Vvg", ptr @"$s12InteropProbe4FiveV1ds5Int64VvpMV", ptr @"$s12InteropProbe4FiveV1ds5Int64Vvs", ptr @"$s12InteropProbe4FiveV1es5Int64VvM", ptr @"$s12InteropProbe4FiveV1es5Int64Vvg", ptr @"$s12InteropProbe4FiveV1es5Int64VvpMV", ptr @"$s12InteropProbe4FiveV1es5Int64Vvs", ptr @"$s12InteropProbe4FiveV5totals5Int64VyF", ptr @"$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF", ptr @"$s12InteropProbe4FiveVHn", ptr @"$s12InteropProbe4FiveVMF", ptr @"$s12InteropProbe4FiveVMa", ptr @"$s12InteropProbe4FiveVMn", ptr @"$s12InteropProbe4FiveVN", ptr @"$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF", ptr @__swift_reflection_version, ptr @probe_capture_control, ptr @probe_combine_control, ptr @probe_invoke_callback], section "llvm.metadata"

@"$s12InteropProbe4FiveVN" = alias %swift.type, getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }>, ptr @"$s12InteropProbe4FiveVMf", i32 0, i32 2)

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV1as5Int64Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #0 {
entry:
  %1 = load i64, ptr %0, align 8
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe4FiveV1as5Int64Vvs"(i64 %0, ptr swiftself writeonly captures(none) dereferenceable(40) initializes((0, 8)) %1) #1 {
entry:
  store i64 %0, ptr %1, align 8
  ret void
}

; Function Attrs: noinline nounwind
define swiftcc { ptr, ptr } @"$s12InteropProbe4FiveV1as5Int64VvM"(ptr noalias dereferenceable(32) %0, ptr swiftself captures(none) dereferenceable(40) %1) #2 {
coro.return:
  %2 = insertvalue { ptr, ptr } { ptr @"$s12InteropProbe4FiveV1as5Int64VvM.resume.0", ptr poison }, ptr %1, 1
  ret { ptr, ptr } %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal swiftcc void @"$s12InteropProbe4FiveV1as5Int64VvM.resume.0"(ptr noalias nonnull readnone align 8 captures(none) %0, i1 %1) #3 {
entryresume.0:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV1bs5Int64Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #0 {
entry:
  %.b = getelementptr inbounds nuw i8, ptr %0, i64 8
  %1 = load i64, ptr %.b, align 8
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe4FiveV1bs5Int64Vvs"(i64 %0, ptr swiftself writeonly captures(none) dereferenceable(40) initializes((8, 16)) %1) #1 {
entry:
  %.b = getelementptr inbounds nuw i8, ptr %1, i64 8
  store i64 %0, ptr %.b, align 8
  ret void
}

; Function Attrs: noinline nounwind
define swiftcc { ptr, ptr } @"$s12InteropProbe4FiveV1bs5Int64VvM"(ptr noalias dereferenceable(32) %0, ptr swiftself captures(none) dereferenceable(40) %1) #2 {
coro.return:
  %.b = getelementptr inbounds nuw i8, ptr %1, i64 8
  %2 = insertvalue { ptr, ptr } { ptr @"$s12InteropProbe4FiveV1bs5Int64VvM.resume.0", ptr poison }, ptr %.b, 1
  ret { ptr, ptr } %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal swiftcc void @"$s12InteropProbe4FiveV1bs5Int64VvM.resume.0"(ptr noalias nonnull readnone align 8 captures(none) %0, i1 %1) #3 {
entryresume.0:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV1cs5Int64Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #0 {
entry:
  %.c = getelementptr inbounds nuw i8, ptr %0, i64 16
  %1 = load i64, ptr %.c, align 8
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe4FiveV1cs5Int64Vvs"(i64 %0, ptr swiftself writeonly captures(none) dereferenceable(40) initializes((16, 24)) %1) #1 {
entry:
  %.c = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i64 %0, ptr %.c, align 8
  ret void
}

; Function Attrs: noinline nounwind
define swiftcc { ptr, ptr } @"$s12InteropProbe4FiveV1cs5Int64VvM"(ptr noalias dereferenceable(32) %0, ptr swiftself captures(none) dereferenceable(40) %1) #2 {
coro.return:
  %.c = getelementptr inbounds nuw i8, ptr %1, i64 16
  %2 = insertvalue { ptr, ptr } { ptr @"$s12InteropProbe4FiveV1cs5Int64VvM.resume.0", ptr poison }, ptr %.c, 1
  ret { ptr, ptr } %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal swiftcc void @"$s12InteropProbe4FiveV1cs5Int64VvM.resume.0"(ptr noalias nonnull readnone align 8 captures(none) %0, i1 %1) #3 {
entryresume.0:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV1ds5Int64Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #0 {
entry:
  %.d = getelementptr inbounds nuw i8, ptr %0, i64 24
  %1 = load i64, ptr %.d, align 8
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe4FiveV1ds5Int64Vvs"(i64 %0, ptr swiftself writeonly captures(none) dereferenceable(40) initializes((24, 32)) %1) #1 {
entry:
  %.d = getelementptr inbounds nuw i8, ptr %1, i64 24
  store i64 %0, ptr %.d, align 8
  ret void
}

; Function Attrs: noinline nounwind
define swiftcc { ptr, ptr } @"$s12InteropProbe4FiveV1ds5Int64VvM"(ptr noalias dereferenceable(32) %0, ptr swiftself captures(none) dereferenceable(40) %1) #2 {
coro.return:
  %.d = getelementptr inbounds nuw i8, ptr %1, i64 24
  %2 = insertvalue { ptr, ptr } { ptr @"$s12InteropProbe4FiveV1ds5Int64VvM.resume.0", ptr poison }, ptr %.d, 1
  ret { ptr, ptr } %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal swiftcc void @"$s12InteropProbe4FiveV1ds5Int64VvM.resume.0"(ptr noalias nonnull readnone align 8 captures(none) %0, i1 %1) #3 {
entryresume.0:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV1es5Int64Vvg"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #0 {
entry:
  %.e = getelementptr inbounds nuw i8, ptr %0, i64 32
  %1 = load i64, ptr %.e, align 8
  ret i64 %1
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe4FiveV1es5Int64Vvs"(i64 %0, ptr swiftself writeonly captures(none) dereferenceable(40) initializes((32, 40)) %1) #1 {
entry:
  %.e = getelementptr inbounds nuw i8, ptr %1, i64 32
  store i64 %0, ptr %.e, align 8
  ret void
}

; Function Attrs: noinline nounwind
define swiftcc { ptr, ptr } @"$s12InteropProbe4FiveV1es5Int64VvM"(ptr noalias dereferenceable(32) %0, ptr swiftself captures(none) dereferenceable(40) %1) #2 {
coro.return:
  %.e = getelementptr inbounds nuw i8, ptr %1, i64 32
  %2 = insertvalue { ptr, ptr } { ptr @"$s12InteropProbe4FiveV1es5Int64VvM.resume.0", ptr poison }, ptr %.e, 1
  ret { ptr, ptr } %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal swiftcc void @"$s12InteropProbe4FiveV1es5Int64VvM.resume.0"(ptr noalias nonnull readnone align 8 captures(none) %0, i1 %1) #3 {
entryresume.0:
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite)
define swiftcc void @"$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF"(ptr noalias writeonly sret(%T12InteropProbe4FiveV) captures(none) initializes((0, 40)) %0, i64 %1, i64 %2, ptr swiftself captures(none) dereferenceable(40) %3) #4 {
entry:
  %4 = load i64, ptr %3, align 8
  %5 = add i64 %4, %1
  store i64 %5, ptr %3, align 8
  %.b = getelementptr inbounds nuw i8, ptr %3, i64 8
  %6 = load i64, ptr %.b, align 8
  %7 = add i64 %6, %2
  store i64 %7, ptr %.b, align 8
  %8 = add i64 %2, %1
  %.c = getelementptr inbounds nuw i8, ptr %3, i64 16
  %9 = load i64, ptr %.c, align 8
  %10 = add i64 %8, %9
  store i64 %10, ptr %.c, align 8
  %.d = getelementptr inbounds nuw i8, ptr %3, i64 24
  %11 = load i64, ptr %.d, align 8
  %12 = add i64 %11, %1
  store i64 %12, ptr %.d, align 8
  %.e = getelementptr inbounds nuw i8, ptr %3, i64 32
  %13 = load i64, ptr %.e, align 8
  %14 = add i64 %13, %2
  store i64 %14, ptr %.e, align 8
  store i64 %5, ptr %0, align 8
  %.b7 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %7, ptr %.b7, align 8
  %.c8 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %10, ptr %.c8, align 8
  %.d9 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %12, ptr %.d9, align 8
  %.e10 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %14, ptr %.e10, align 8
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define hidden swiftcc void @"$s12InteropProbe4FiveV1a1b1c1d1eACs5Int64V_A4JtcfC"(ptr noalias writeonly sret(%T12InteropProbe4FiveV) captures(none) initializes((0, 40)) %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5) local_unnamed_addr #1 {
entry:
  store i64 %1, ptr %0, align 8
  %.b = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %2, ptr %.b, align 8
  %.c = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %3, ptr %.c, align 8
  %.d = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %4, ptr %.d, align 8
  %.e = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %5, ptr %.e, align 8
  ret void
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: write)
define swiftcc void @"$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF"(ptr noalias writeonly sret(%T12InteropProbe4FiveV) captures(none) initializes((0, 40)) %0, i64 %1, i64 %2, i64 %3, ptr readnone swiftself captures(none) %4, ptr noalias readnone swifterror captures(none) dereferenceable(8) %5) #5 {
entry:
  store i64 %1, ptr %0, align 8
  %.b = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %2, ptr %.b, align 8
  %.c = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %3, ptr %.c, align 8
  %.d = getelementptr inbounds nuw i8, ptr %0, i64 24
  store <2 x i64> <i64 44, i64 55>, ptr %.d, align 8
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define void @probe_combine_control(ptr writeonly captures(none) initializes((0, 40)) %0, ptr nonnull captures(none) %1, i64 %2, i64 %3) #6 {
entry:
  %4 = alloca %T12InteropProbe4FiveV, align 8
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %4)
  call swiftcc void @"$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF"(ptr noalias nonnull sret(%T12InteropProbe4FiveV) captures(none) %4, i64 %2, i64 %3, ptr nonnull swiftself captures(none) dereferenceable(40) %1) #19
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %0, ptr noundef nonnull align 8 dereferenceable(40) %4, i64 40, i1 false)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %4)
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #7

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #8

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #7

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define swiftcc void @"$s12InteropProbe14combineControlyySv_Svs5Int64VADtF"(ptr writeonly captures(none) initializes((0, 40)) %0, ptr nonnull captures(none) %1, i64 %2, i64 %3) #6 {
entry:
  %4 = alloca %T12InteropProbe4FiveV, align 8
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %4)
  call swiftcc void @"$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF"(ptr noalias nonnull sret(%T12InteropProbe4FiveV) captures(none) %4, i64 %2, i64 %3, ptr nonnull swiftself captures(none) dereferenceable(40) %1)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %0, ptr noundef nonnull align 8 dereferenceable(40) %4, i64 40, i1 false)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %4)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none)
define void @probe_capture_control(ptr writeonly captures(none) initializes((0, 40)) %0, i64 %1, i64 %2, i64 %3) #9 {
  %5 = alloca %T12InteropProbe4FiveV, align 8
  %swifterror = alloca swifterror ptr, align 8
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %5)
  call swiftcc void @"$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF"(ptr noalias nonnull sret(%T12InteropProbe4FiveV) captures(none) %5, i64 %1, i64 %2, i64 %3, ptr swiftself poison, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %swifterror) #19
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %0, ptr noundef nonnull align 8 dereferenceable(40) %5, i64 40, i1 false)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %5)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none)
define swiftcc void @"$s12InteropProbe14captureControlyySv_s5Int64VA2DtF"(ptr writeonly captures(none) initializes((0, 40)) %0, i64 %1, i64 %2, i64 %3) #9 {
  %5 = alloca %T12InteropProbe4FiveV, align 8
  %swifterror = alloca swifterror ptr, align 8
  call void @llvm.lifetime.start.p0(i64 40, ptr nonnull %5)
  call swiftcc void @"$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF"(ptr noalias nonnull sret(%T12InteropProbe4FiveV) captures(none) %5, i64 %1, i64 %2, i64 %3, ptr swiftself poison, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %swifterror)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %0, ptr noundef nonnull align 8 dereferenceable(40) %5, i64 40, i1 false)
  call void @llvm.lifetime.end.p0(i64 40, ptr nonnull %5)
  ret void
}

define i64 @probe_invoke_callback(ptr readonly captures(none) %0, i64 %1) #10 {
entry:
  %swifterror = alloca swifterror ptr, align 8
  store ptr null, ptr %swifterror, align 8
  %2 = call swiftcc i64 %0(i64 %1, ptr swiftself undef, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %swifterror) #19
  %3 = load ptr, ptr %swifterror, align 8
  %.not = icmp eq ptr %3, null
  br i1 %.not, label %5, label %4

4:                                                ; preds = %entry
  tail call void @swift_errorRelease(ptr nonnull %3) #11
  br label %5

5:                                                ; preds = %entry, %4
  %6 = phi i64 [ -1, %4 ], [ %2, %entry ]
  ret i64 %6
}

; Function Attrs: nounwind
declare void @swift_errorRelease(ptr) local_unnamed_addr #11

define swiftcc i64 @"$s12InteropProbe14invokeCallbackys5Int64VSV_ADtF"(ptr readonly captures(none) %0, i64 %1) #10 {
entry:
  %swifterror = alloca swifterror ptr, align 8
  store ptr null, ptr %swifterror, align 8
  %2 = call swiftcc i64 %0(i64 %1, ptr swiftself undef, ptr noalias nonnull swifterror captures(none) dereferenceable(8) %swifterror)
  %3 = load ptr, ptr %swifterror, align 8
  %.not = icmp eq ptr %3, null
  br i1 %.not, label %4, label %6

4:                                                ; preds = %entry, %6
  %5 = phi i64 [ -1, %6 ], [ %2, %entry ]
  ret i64 %5

6:                                                ; preds = %entry
  tail call void @swift_errorRelease(ptr nonnull %3) #11
  br label %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: read)
define swiftcc i64 @"$s12InteropProbe4FiveV5totals5Int64VyF"(ptr noalias readonly swiftself captures(none) dereferenceable(40) %0) #12 {
entry:
  %1 = load <4 x i64>, ptr %0, align 8
  %.e = getelementptr inbounds nuw i8, ptr %0, i64 32
  %.sroa.0.0.copyload = load i64, ptr %.e, align 8
  %2 = tail call i64 @llvm.vector.reduce.add.v4i64(<4 x i64> %1)
  %op.rdx = add i64 %2, %.sroa.0.0.copyload
  ret i64 %op.rdx
}

; Function Attrs: mustprogress nounwind willreturn
define internal nonnull ptr @"$s12InteropProbe4FiveVwCP"(ptr noalias writeonly captures(none) initializes((0, 8)) %dest, ptr noalias readonly captures(none) %src, ptr readnone captures(none) %Five) #13 {
entry:
  %0 = load ptr, ptr %src, align 8
  store ptr %0, ptr %dest, align 8
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %2 = tail call ptr @swift_retain(ptr returned %0) #20
  ret ptr %1
}

; Function Attrs: mustprogress nounwind willreturn
declare ptr @swift_retain(ptr returned) local_unnamed_addr #14

; Function Attrs: nounwind
define linkonce_odr hidden void @__swift_noop_void_return(ptr %0, ptr %1) #15 {
entry:
  ret void
}

; Function Attrs: nounwind
define linkonce_odr hidden ptr @__swift_memcpy40_8(ptr %0, ptr %1, ptr %2) #15 {
entry:
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(40) %0, ptr noundef nonnull align 8 dereferenceable(40) %1, i64 40, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define internal i32 @"$s12InteropProbe4FiveVwet"(ptr noalias readonly captures(none) %value, i32 %numEmptyCases, ptr readnone captures(none) %Five) #0 {
entry:
  %0 = icmp eq i32 %numEmptyCases, 0
  br i1 %0, label %9, label %1

1:                                                ; preds = %entry
  %2 = getelementptr inbounds nuw i8, ptr %value, i64 40
  %3 = load i8, ptr %2, align 1
  %4 = icmp eq i8 %3, 0
  br i1 %4, label %9, label %5

5:                                                ; preds = %1
  %6 = load i320, ptr %value, align 1
  %7 = trunc i320 %6 to i32
  %8 = add i32 %7, 1
  br label %9

9:                                                ; preds = %entry, %1, %5
  %10 = phi i32 [ %8, %5 ], [ 0, %1 ], [ 0, %entry ]
  ret i32 %10
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write)
define internal void @"$s12InteropProbe4FiveVwst"(ptr noalias writeonly captures(none) %value, i32 %whichCase, i32 %numEmptyCases, ptr readnone captures(none) %Five) #1 {
entry:
  %0 = getelementptr inbounds nuw i8, ptr %value, i64 40
  %.not = icmp eq i32 %numEmptyCases, 0
  %1 = icmp eq i32 %whichCase, 0
  br i1 %1, label %2, label %3

2:                                                ; preds = %entry
  br i1 %.not, label %7, label %.sink.split

3:                                                ; preds = %entry
  %4 = add i32 %whichCase, -1
  %5 = zext i32 %4 to i64
  store i64 %5, ptr %value, align 8
  %6 = getelementptr inbounds nuw i8, ptr %value, i64 8
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(32) %6, i8 0, i64 32, i1 false)
  br i1 %.not, label %7, label %.sink.split

.sink.split:                                      ; preds = %3, %2
  %.sink = phi i8 [ 0, %2 ], [ 1, %3 ]
  store i8 %.sink, ptr %0, align 8
  br label %7

7:                                                ; preds = %.sink.split, %3, %2
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #16

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none)
define swiftcc %swift.metadata_response @"$s12InteropProbe4FiveVMa"(i64 %0) #17 {
entry:
  ret %swift.metadata_response { ptr getelementptr inbounds (<{ ptr, ptr, i64, ptr, i32, i32, i32, i32, i32, [4 x i8] }>, ptr @"$s12InteropProbe4FiveVMf", i32 0, i32 2), i64 0 }
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.vector.reduce.add.v4i64(<4 x i64>) #18

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #2 = { noinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #4 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #5 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: write) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #7 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #8 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #9 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #10 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #11 = { nounwind }
attributes #12 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: read) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #13 = { mustprogress nounwind willreturn "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #14 = { mustprogress nounwind willreturn }
attributes #15 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #16 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #17 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a" }
attributes #18 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #19 = { noinline }
attributes #20 = { nounwind willreturn }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11, !12}
!swift.module.flags = !{!13}
!llvm.linker.options = !{!14, !15, !16, !17, !18}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 27, i32 0]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 4, !"Objective-C Garbage Collection", i32 100927232}
!5 = !{i32 1, !"Objective-C Is Simulated", i32 32}
!6 = !{i32 1, !"Objective-C Class Properties", i32 64}
!7 = !{i32 1, !"Objective-C Enforce ClassRO Pointer Signing", i8 0}
!8 = !{i32 1, !"wchar_size", i32 4}
!9 = !{i32 8, !"PIC Level", i32 2}
!10 = !{i32 7, !"uwtable", i32 1}
!11 = !{i32 7, !"frame-pointer", i32 1}
!12 = !{i32 1, !"Swift Version", i32 7}
!13 = !{!"standard-library", i1 false}
!14 = !{!"-lswift_Concurrency"}
!15 = !{!"-lswiftCore"}
!16 = !{!"-lswift_StringProcessing"}
!17 = !{!"-lobjc"}
!18 = !{!"-lswiftCompatibilityPacks"}
