
default:
	tclsh ptlex/ptlex2.tcl
wc-samples:
	tclsh ptlex/ptlex2.tcl --lang tcl samples/wc.ftl
	tclsh samples/wc.tcl samples/wc.ftl
	tclsh ptlex/ptlex2.tcl --lang python samples/wc.fpy
	python2 samples/wc.py samples/wc.ftl
