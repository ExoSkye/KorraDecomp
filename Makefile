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
	@printf "\033[K\033[0;32mBuilding SCETool\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) @$(MAKE) -C Tools/scetool --no-print-directory

check_python3:
	$(VERB) pkg-config --exists python3

check_hashes:
	@printf "\033[K\033[0;32mChecking game hashes\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) python3 Tools/check.py GameFiles/NPEB02082.sha512 GameFiles > /dev/null || (echo "\033[K\033[0;31mHash Mismatch.\033[0m\n"; exit 1)
	@printf "\033[K\033[0;32mHashes match\033[0m\n"

copy_extracted_data:
	@printf "\033[K\033[0;32mCopying extracted PS3 data to SCETool directory\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) mkdir -p Tools/scetool/data
	$(VERB) mkdir -p Tools/scetool/rifs
	$(VERB) cp PS3Data/keys Tools/scetool/data
	$(VERB) cp PS3Data/ldr_curves Tools/scetool/data
	$(VERB) cp PS3Data/vsh_curves Tools/scetool/data
	$(VERB) cp PS3Data/act.dat Tools/scetool/data
	$(VERB) cp PS3Data/idps	Tools/scetool/data
	$(VERB) cp PS3Data/*.rif Tools/scetool/rifs 

Work/EBOOT.elf: $(SCETOOL) copy_extracted_data check_hashes
	@printf "\033[K\033[0;32mExtracting EBOOT.BIN\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) mkdir Work
	$(VERB) cd Tools/scetool/ && ./scetool -v -d ../../GameFiles/NPEB02082/USRDIR/EBOOT.BIN ../../Work/EBOOT.elf

clean:
	@printf "\033[K\033[0;32mCleaning\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) @$(MAKE) -C Tools/scetool clean --no-print-directory
	$(VERB) rm -rf Work/*
