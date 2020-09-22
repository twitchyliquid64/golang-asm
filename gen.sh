#!/bin/bash
# Downloads the Go sources, building the assembler into a standalone package.

OUT_DIR=$(pwd)
BASE_PKG_PATH='github.com/twitchyliquid64/golang-asm'

TMP_PATH=$(mktemp -d)
cleanup () {
  if [[ "${TMP_PATH}" != "" ]]; then
    rm -rf "${TMP_PATH}"
    TMP_PATH=""
  fi
}
trap 'cleanup $LINENO' ERR EXIT

cd $TMP_PATH
git clone --depth 1 https://github.com/golang/go

rm -rfv ${OUT_DIR}/{asm,dwarf,obj,objabi,src,sys,bio,goobj}

# Move obj.
cp -rv ${TMP_PATH}/go/src/cmd/internal/obj ${OUT_DIR}/obj
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/obj_\"${BASE_PKG_PATH}/obj_g" {} \;
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/dwarf_\"${BASE_PKG_PATH}/dwarf_g" {} \;
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/src_\"${BASE_PKG_PATH}/src_g" {} \;
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/sys_\"${BASE_PKG_PATH}/sys_g" {} \;
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/bio_\"${BASE_PKG_PATH}/bio_g" {} \;
find ${OUT_DIR}/obj -type f -exec sed -i "s_\"cmd/internal/goobj_\"${BASE_PKG_PATH}/goobj_g" {} \;
# Move objabi.
cp -rv ${TMP_PATH}/go/src/cmd/internal/objabi ${OUT_DIR}/objabi
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/obj_\"${BASE_PKG_PATH}/obj_g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/dwarf_\"${BASE_PKG_PATH}/dwarf_g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/src_\"${BASE_PKG_PATH}/src_g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/sys_\"${BASE_PKG_PATH}/sys_g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/bio_\"${BASE_PKG_PATH}/bio_g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s_\"cmd/internal/goobj_\"${BASE_PKG_PATH}/goobj_g" {} \;
# Move arch.
mkdir -pv ${OUT_DIR}/asm
cp -rv ${TMP_PATH}/go/src/cmd/asm/internal/arch ${OUT_DIR}/asm/arch
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/obj_\"${BASE_PKG_PATH}/obj_g" {} \;
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/dwarf_\"${BASE_PKG_PATH}/dwarf_g" {} \;
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/src_\"${BASE_PKG_PATH}/src_g" {} \;
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/sys_\"${BASE_PKG_PATH}/sys_g" {} \;
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/bio_\"${BASE_PKG_PATH}/bio_g" {} \;
find ${OUT_DIR}/asm/arch -type f -exec sed -i "s_\"cmd/internal/goobj_\"${BASE_PKG_PATH}/goobj_g" {} \;
# Move goobj.
cp -rv ${TMP_PATH}/go/src/cmd/internal/goobj ${OUT_DIR}/goobj
find ${OUT_DIR}/goobj -type f -exec sed -i "s_\"cmd/internal/obj_\"${BASE_PKG_PATH}/obj_g" {} \;
find ${OUT_DIR}/goobj -type f -exec sed -i "s_\"cmd/internal/bio_\"${BASE_PKG_PATH}/bio_g" {} \;
find ${OUT_DIR}/goobj -type f -exec sed -i "s_\"internal/unsafeheader_\"${BASE_PKG_PATH}/unsafeheader_g" {} \;

# Move bio.
cp -rv ${TMP_PATH}/go/src/cmd/internal/bio ${OUT_DIR}/bio
# Move unsafeheader.
cp -rv ${TMP_PATH}/go/src/internal/unsafeheader ${OUT_DIR}/unsafeheader
# Move dwarf.
cp -rv ${TMP_PATH}/go/src/cmd/internal/dwarf ${OUT_DIR}/dwarf
find ${OUT_DIR}/dwarf -type f -exec sed -i "s_\"cmd/internal/obj_\"${BASE_PKG_PATH}/obj_g" {} \;
# Move src.
cp -rv ${TMP_PATH}/go/src/cmd/internal/src ${OUT_DIR}/src
# Move sys.
cp -rv ${TMP_PATH}/go/src/cmd/internal/sys ${OUT_DIR}/sys


# Rewrite identifiers for generated (at build time) constants.
find ${OUT_DIR}/objabi -type f -exec sed -i "s/stackGuardMultiplierDefault/1/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOOS/\"linux\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOARCH/\"$(go env GOARCH)\"/g" {} \;

find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGO386/\"\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOARM/\"7\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOMIPS64/\"hardfloat\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOMIPS/\"hardfloat\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGOPPC64/\"power8\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGO_LDSO/\"\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/= version/= \"\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/defaultGO_EXTLINK_ENABLED/\"\"/g" {} \;
find ${OUT_DIR}/objabi -type f -exec sed -i "s/goexperiment/\"\"/g" {} \;


# Remove tests (they have package dependencies we could do without).
find ${OUT_DIR} -name "*_test.go" -type f -delete

# Write README.
cat > ${OUT_DIR}/README.md << "EOF"
# golang-asm

A mirror of the assembler from the Go compiler, with import paths re-written for the assembler to be functional as a standalone library.

License as per the Go project.

# Status

Works, but expect to dig into the assembler godoc's to work out what to set different parameters of `obj.Prog` to get it to generate specific instructions.

# Example

Demonstrates assembly of a NOP & an ADD instruction on x86-64.

```go

package main

import (
	"fmt"

	asm "github.com/twitchyliquid64/golang-asm"
	"github.com/twitchyliquid64/golang-asm/obj"
	"github.com/twitchyliquid64/golang-asm/obj/x86"
)

func noop(builder *asm.Builder) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.ANOPL
	prog.From.Type = obj.TYPE_REG
	prog.From.Reg = x86.REG_AX
	return prog
}

func addImmediateByte(builder *asm.Builder, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AADDB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = x86.REG_AL
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func movImmediateByte(builder *asm.Builder, reg int16, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func main() {
	b, _ := asm.NewBuilder("amd64", 64)
	b.AddInstruction(noop(b))
	b.AddInstruction(movImmediateByte(b, x86.REG_AL, 16))
	b.AddInstruction(addImmediateByte(b, 16))
	fmt.Printf("Bin: %x\n", b.Assemble())
}

```

# Working out the parameters of `obj.Prog`

This took me some time to work out, so I'll write a bit here.

## Use these references

 * `obj.Prog` - [godoc](https://godoc.org/github.com/golang/go/src/cmd/internal/obj#Prog)
  * Some instructions (like NOP, JMP) are abstract per-platform & can be found [here](https://godoc.org/github.com/golang/go/src/cmd/internal/obj#As)

 * (for amd64) `x86 pkg-constants` - [registers & instructions](https://godoc.org/github.com/golang/go/src/cmd/internal/obj/x86#pkg-constant)

## Instruction constants have a naming scheme

Instructions are defined as constants in the package for the relavant architecture, and have an 'A' prefix and a size suffix.

For example, the MOV instruction for 64 bits of data is `AMOVQ` (well, at least in amd64).

## Search the go source for usage of a given instruction

For example, if I wanted to work out how to emit the MOV instruction for 64bits, I would search the go source on github for `AMOVQ` or `x86.AMOVQ`. Normally, you see find a few examples where the compiler backend fills in a `obj.Prog` structure, and you follow it's lead.
EOF

# Write license file.
cat > ${OUT_DIR}/LICENSE << "EOF"
Copyright (c) 2009 The Go Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

   * Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following disclaimer
in the documentation and/or other materials provided with the
distribution.
   * Neither the name of Google Inc. nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOTto be standalone
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EOF
