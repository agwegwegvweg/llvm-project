//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

_CLC_OVERLOAD _CLC_DECL __CLC_GENTYPE FUNCTION(__CLC_GENTYPE x,
                                               global __CLC_INTN *iptr);
_CLC_OVERLOAD _CLC_DECL __CLC_GENTYPE FUNCTION(__CLC_GENTYPE x,
                                               local __CLC_INTN *iptr);
_CLC_OVERLOAD _CLC_DECL __CLC_GENTYPE FUNCTION(__CLC_GENTYPE x,
                                               private __CLC_INTN *iptr);
#if _CLC_GENERIC_AS_SUPPORTED
_CLC_OVERLOAD _CLC_DECL __CLC_GENTYPE FUNCTION(__CLC_GENTYPE x,
                                               generic __CLC_INTN *iptr);
#endif
