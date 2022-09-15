#include $(PSL1GHT)/base_rules

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

SCETOOL				:=	scetool$(POSTFIX)

ifndef PLAIN
  COLOR_RED			:= \033[K\033[0;31m
  COLOR_GREEN		:= \033[K\033[0;32m
  COLOR_RESET		:= \033[0m
else
  COLOR_RED			:=
  COLOR_GREEN		:=
  COLOR_RESET		:=
endif

$(SCETOOL):
	@printf "$(COLOR_GREEN)Building SCETool...$(COLOR_RESET)\n"
	$(VERB) @$(MAKE) -C Tools/scetool --no-print-directory

check_python3:
	$(VERB) pkg-config --exists python3

check_hashes:
	@printf "$(COLOR_GREEN)Checking game hashes\033[1;32m\033[0;32m...\033[0m\n"
	$(VERB) python3 Tools/check.py GameFiles/NPEB02082.sha512 GameFiles > /dev/null || (echo "$(COLOR_RED)Hash Mismatch.$(COLOR_RESET)"; exit 1)
	@printf "$(COLOR_GREEN)Hashes match$(COLOR_RESET)\n"

copy_extracted_data:
	@printf "$(COLOR_GREEN)Copying extracted PS3 data to SCETool directory...$(COLOR_RESET)\n"
	$(VERB) mkdir -p Tools/scetool/data
	$(VERB) mkdir -p Tools/scetool/rifs
	$(VERB) cp -v PS3Data/keys Tools/scetool/data
	$(VERB) cp -v PS3Data/ldr_curves Tools/scetool/data
	$(VERB) cp -v PS3Data/vsh_curves Tools/scetool/data
	$(VERB) cp -v PS3Data/act.dat Tools/scetool/data
	$(VERB) cp -v PS3Data/idps	Tools/scetool/data
	$(VERB) cp -v PS3Data/*.rif Tools/scetool/rifs 

Work/EBOOT.elf: $(SCETOOL) copy_extracted_data check_hashes
	@printf "$(COLOR_GREEN)Extracting EBOOT.BIN...$(COLOR_RESET)\n"
	$(VERB) mkdir -p Work
	$(VERB) cd Tools/scetool/ && ./scetool -v -d ../../GameFiles/NPEB02082/USRDIR/EBOOT.BIN ../../Work/EBOOT.elf

Work/EBOOT.BIN: Work/EBOOT.elf $(SCETOOL)
	@printf "$(COLOR_GREEN)Encrypting EBOOT.elf to EBOOT.BIN...$(COLOR_RESET)\n"
	$(VERB) cd Tools/scetool/ && ./scetool \
			--verbose \
                    	--sce-type=SELF" \                       
			--skip-sections=FALSE"\
                       	--self-add-shdrs=TRUE"\
                       	--compress-data=TRUE"\
                       	--key-revision=0A"\
                       	--self-app-version=0001000000000000"\
                       	--self-auth-id=1010000001000003"\
                       	--self-vendor-id=01000002"\
                       	--self-ctrl-flags=0000000000000000000000000000000000000000000000000000000000000000"\
                       	--self-cap-flags=00000000000000000000000000000000000000000000003B0000000100040000"\
                       	--self-type=NPDRM"\
                       	--self-fw-version=0003005500000000"\
                       	--np-license-type=FREE"\
                       	--np-app-type=SPRX"\
                       	--np-content-id={contentID}"\
                       	--np-real-fname=EBOOT.BIN"\
                       	--encrypt TODO

pkg: Work/EBOOT.BIN check_hashes
	@printf "$(COLOR_GREEN)Packaging...$(COLOR_RESET)\n"
	$(VERB) mkdir pkg
	$(VERB) cp GameFiles/NPEB02082/* pkg -r
	$(VERB) cp Work/EBOOT.BIN pkg/USRDIR/EBOOT.BIN 
	# TODO: Add actual 

clean:
	@printf "$(COLOR_GREEN)Cleaning...$(COLOR_RESET)\n"
	$(VERB) @$(MAKE) -C Tools/scetool clean --no-print-directory
	$(VERB) rm -rf Work/*
