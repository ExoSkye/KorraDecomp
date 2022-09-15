include $(PSL1GHT)/base_rules

.SUFFIXES:

ifneq (,$(findstring MINGW,$(UNAME)))
        POSTFIX         :=      .exe
endif

ifneq (,$(findstring CYGWIN,$(UNAME)))
        POSTFIX         :=      .exe
endif

ifndef VERBOSE
  VERB := @
endif

SCETOOL			:=	scetool$(POSTFIX)

$(SCETOOL):
	$(VERB) echo Building SCETool
	$(VERB) @$(MAKE) -C Tools/scetool --no-print-directory

copy_extracted_data:
	$(VERB) echo Copying extracted PS3 data to SCETool directory
	$(VERB) mkdir -p Tools/scetool/data
	$(VERB) mkdir -p Tools/scetool/rifs
	$(VERB) cp PS3Data/keys Tools/scetool/data
	$(VERB) cp PS3Data/ldr_curves Tools/scetool/data
	$(VERB) cp PS3Data/vsh_curves Tools/scetool/data
	$(VERB) cp PS3Data/act.dat Tools/scetool/data
	$(VERB) cp PS3Data/idps	Tools/scetool/data
	$(VERB) cp PS3Data/*.rif Tools/scetool/rifs 

Work/EBOOT.elf: $(SCETOOL) copy_extracted_data
	$(VERB) echo Extracting EBOOT.BIN
	$(VERB) mkdir Work
	$(VERB) cd Tools/scetool/ && ./scetool -v -d ../../GameFiles/NPEB02082/USRDIR/EBOOT.BIN ../../Work/EBOOT.elf

clean:
	$(VERB) echo Cleaning
	$(VERB) @$(MAKE) -C Tools/scetool clean --no-print-directory
	$(VERB) rm -rf Work/*
