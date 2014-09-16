
all: s0.sid s0.prg s1.sid s1.prg


freq.oph: freq-table.pl
	./freq-table.pl > freq.oph


s0.inc: s0.oph s0.sqx
	./song-compiler.pl s0.oph s0.sqx > s0.inc

s0.bin: s0.inc s0.oph sidplay.oph sqx.oph freq.oph
	ophis sidplay.oph s0.oph s0.inc -o s0.bin

s0.sid: s0.bin
	( ./psid-header.pl 4000 4003 3 SONG0 sqaxomonophonen cc0 && cat s0.bin ) > s0.sid

s0.prg: s0.oph s0.inc prg.oph sqx.oph freq.oph
	ophis prg.oph s0.oph s0.inc -o s0.prg



s1.inc: s1.oph s1.sqx
	./song-compiler.pl s1.oph s1.sqx > s1.inc

s1.bin: s1.inc s1.oph sidplay.oph sqx.oph freq.oph
	ophis sidplay.oph s1.oph s1.inc -o s1.bin

s1.sid: s1.bin
	( ./psid-header.pl 4000 4003 1 arpa sqaxomonophonen cc0\ 2014 && cat s1.bin ) > s1.sid

s1.prg: s1.oph s1.inc prg.oph sqx.oph freq.oph
	ophis prg.oph s1.oph s1.inc -o s1.prg



dump: s0.bin
	hexdump -C s0.bin

clean:
	rm -f freq.oph s0.bin s0.sid s0.prg s0.inc s1.bin s1.sid s1.prg s1.inc
