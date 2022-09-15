include $(PSL1GHT)/base_rules

export PATH     	:=  $(PS3DEV)/bin:$(PS3DEV)/ppu/bin:$(PATH)

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

ifndef PLAIN
  COLOR_RED		:= \033[K\033[0;31m
  COLOR_GREEN		:= \033[K\033[0;32m
  COLOR_RESET		:= \033[0m
else
  COLOR_RED		:=
  COLOR_GREEN		:=
  COLOR_RESET		:=
endif

PKG			:= pkg.py
SFO			:= sfo.py
APPID			:= KORRA1000
CONTENTID		:= EP0002-$(APPID)_00-LEGENDOFKORRAPS3

$(SCETOOL):
	@printf "$(COLOR_GREEN)Building SCETool...$(COLOR_RESET)\n"
	$(VERB) @$(MAKE) -C Tools/scetool --no-print-directory

check_python3:
	$(VERB) pkg-config --exists python3

check_python2:
	$(VERB) pkg-config --exists python2

check_hashes:
	@printf "$(COLOR_GREEN)Checking game hashes...$(COLOR_RESET)\n"
	$(VERB) python3 Tools/check.py GameFiles/NPEB02082.sha512 GameFiles > /dev/null || (echo "$(COLOR_RED)Hash Mismatch.$(COLOR_RESET)"; exit 1)
	@printf "$(COLOR_GREEN)Hashes match$(COLOR_RESET)\n"

copy_extracted_data:
	@printf "$(COLOR_GREEN)Copying extracted PS3 data to SCETool directory...$(COLOR_RESET)\n"
	$(VERB) mkdir -p Tools/scetool/data
	$(VERB) mkdir -p Tools/scetool/rifs
	$(VERB) cp -v PS3Data/keys 		Tools/scetool/data
	$(VERB) cp -v PS3Data/ldr_curves 	Tools/scetool/data
	$(VERB) cp -v PS3Data/vsh_curves 	Tools/scetool/data
	$(VERB) cp -v PS3Data/act.dat 		Tools/scetool/data
	$(VERB) cp -v PS3Data/idps		Tools/scetool/data
	$(VERB) cp -v PS3Data/*.rif 		Tools/scetool/rifs 

Work/EBOOT.elf: $(SCETOOL) copy_extracted_data check_hashes
	@printf "$(COLOR_GREEN)Extracting EBOOT.BIN...$(COLOR_RESET)\n"
	$(VERB) mkdir -p Work
	$(VERB) cd Tools/scetool/ && ./scetool -v -d ../../GameFiles/NPEB02082/USRDIR/EBOOT.BIN ../../Work/EBOOT.elf

Work/EBOOT.BIN: Work/EBOOT.elf $(SCETOOL)
	@printf "$(COLOR_GREEN)Encrypting EBOOT.elf to EBOOT.BIN...$(COLOR_RESET)\n"
	$(VERB) cd Tools/scetool/ && ./scetool \
			--verbose \
                    	--sce-type=SELF \
			--skip-sections=FALSE \
                       	--self-add-shdrs=TRUE \
                       	--compress-data=TRUE \
                       	--key-revision=0A \
                       	--self-app-version=0001000000000000 \
                       	--self-auth-id=1010000001000003 \
                       	--self-vendor-id=01000002 \
                       	--self-ctrl-flags=0000000000000000000000000000000000000000000000000000000000000000 \
                       	--self-cap-flags=00000000000000000000000000000000000000000000003B0000000100040000 \
                       	--self-type=NPDRM \
                       	--self-fw-version=0003005500000000 \
                       	--np-license-type=FREE \
                       	--np-app-type=SPRX \
                       	--np-content-id=$(CONTENTID) \
                       	--np-real-fname=EBOOT.BIN \
                       	--encrypt ../../Work/EBOOT.elf ../../Work/EBOOT.BIN

fixed_pkgcrypt: check_python2
	@printf "$(COLOR_GREEN)Building patched pkgcrypt.so for pkg.py$(COLOR_RESET)\n"
	$(VERB) @$(MAKE) install -C Tools/PKGCrypt --no-print-directory

pkg: Work/EBOOT.BIN check_hashes fixed_pkgcrypt
	@printf "$(COLOR_GREEN)Packaging...$(COLOR_RESET)\n"
	$(VERB) mkdir -p target
	$(VERB) cp GameFiles/NPEB02082/* target -r
	$(VERB) cp Work/EBOOT.BIN target/USRDIR/EBOOT.BIN 
	#$(VERB) sfo.py --title "Legend Of Korra" --appid $(APPID) -f $(PS3DEV)/bin/sfo.xml target/PARAM.SFO 
	$(VERB) $(PKG) --contentid $(CONTENTID) target/ korra.pkg

clean:
	@printf "$(COLOR_GREEN)Cleaning...$(COLOR_RESET)\n"
	$(VERB) @$(MAKE) -C Tools/scetool clean --no-print-directory
	$(VERB) rm -rf Work/*
