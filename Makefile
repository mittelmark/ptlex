
default:
	tclsh ptlex/ptlex2.tcl
wc-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl samples/wc.ftl
	tclsh samples/wc.tcl samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang python samples/wc.fpy
	python3 samples/wc.py samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang ruby samples/wc.frb
	ruby samples/wc.rb samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang perl samples/wc.fpl
	perl samples/wc.pl samples/wc.ftl
wc-oo-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl -+  samples/wc_oo.ftl
	tclsh samples/wc_oo.tcl samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang python -+ samples/wc_oo.fpy
	python3 samples/wc_oo.py samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang perl -+ samples/wc_oo.fpl
	perl samples/wc_oo.pl samples/wc.ftl
	
rep-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl samples/replacer.ftl
	tclsh samples/replacer.tcl samples/replacer.ftl
	tclsh ptlex/ptlex2.tcl --lang python samples/replacer.fpy
	python3 samples/replacer.py samples/replacer.ftl
	tclsh ptlex/ptlex2.tcl --lang ruby samples/replacer.frb
	ruby samples/replacer.rb samples/replacer.ftl
	tclsh ptlex/ptlex2.tcl --lang perl samples/replacer.fpl
	perl samples/replacer.pl samples/replacer.ftl
rep-oo-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl -+  samples/replacer_oo.ftl
	tclsh samples/replacer_oo.tcl samples/replacer.ftl
	tclsh ptlex/ptlex2.tcl --lang python -+ samples/replacer_oo.fpy
	python3 samples/replacer_oo.py samples/replacer.ftl
wc-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl samples/wc.ftl
	tclsh samples/wc.tcl samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang python samples/wc.fpy
	python3 samples/wc.py samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang ruby samples/wc.frb
	ruby samples/wc.rb samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang perl samples/wc.fpl
	perl samples/wc.pl samples/wc.ftl
sbs-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl samples/sbs.ftl
	tclsh ptlex/ptlex2.tcl --lang python samples/sbs.fpy
	tclsh ptlex/ptlex2.tcl --lang ruby samples/sbs.frb
	tclsh ptlex/ptlex2.tcl --lang perl samples/sbs.fpl
app:
	cp ptlex/*.tcl ptlex.vfs/lib/app-ptlex/
	cp ptlex/*.tmpl ptlex.vfs/lib/app-ptlex/
	tpack ptlex.tapp
	
