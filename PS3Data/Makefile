Tools/scetool/data:
	$(VERB) mkdir -p Tools/scetool/data

Tools/scetool/rifs:
	$(VERB) mkdir -p Tools/scetool/rifs

Tools/scetool/data/%: PS3Data/% Tools/scetool/data
	$(VERB) cp -v $< $@

Tools/scetool/rifs/%.rif: PS3Data/%.rif Tools/scetool/rifs
	$(VERB) cp -v $< $@