
all: song0.sid song0.prg


freq.oph: freq-table.pl
	./freq-table.pl > freq.oph

compiled.s0.oph: s0.oph s0.sqx
	./song-compiler.pl s0.oph s0.sqx > compiled.s0.oph

song0.bin: compiled.s0.oph sidplay.oph sqx.oph freq.oph
	ophis sidplay.oph compiled.s0.oph -o song0.bin

song0.sid: song0.bin
	( ./psid-header.pl 4000 4003 3 SONG0 sqaxomonophonen cc0 && cat song0.bin ) > song0.sid

song0.prg: compiled.s0.oph prg.oph sqx.oph freq.oph
	ophis prg.oph compiled.s0.oph -o song0.prg

dump: song0.bin
	hexdump -C song0.bin

clean:
	rm -f song0.bin song0.sid freq.oph song0.prg compiled.s0.oph
