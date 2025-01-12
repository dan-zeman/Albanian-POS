SHELL=/bin/bash

process:
	perl ./fix1.pl --sent_id_prefix trainshort train-short-new.conllu > dz-trainshort.conllu
	perl ./fix1.pl --sent_id_prefix trainlong train-withoutShort-new.conllu > dz-trainlong.conllu
	perl ./fix1.pl --sent_id_prefix dev albanian-all-devel-new.conllu > dz-dev.conllu
	perl ./fix1.pl --sent_id_prefix test albanian-all-test-new.conllu > dz-test.conllu
	cat dz-trainshort.conllu dz-trainlong.conllu dz-dev.conllu dz-test.conllu > all.conllu
	perl -S conllu-quick-fix-id-sequence.pl < all.conllu > fixed.conllu && mv fixed.conllu all.conllu
	perl -S conllu-quick-fix.pl < all.conllu > fixed.conllu && mv fixed.conllu all.conllu
	perl -S conllu-stats.pl < all.conllu > stats.xml

compare:
	mkdir uppsala
	mkdir turku
	cp all.conllu turku
	cp ../UD_Albanian-TSA/sq_tsa-ud-test.conllu uppsala
	conllu-stats.pl --oformat hubcompare uppsala turku > uppsala-turku-comparison.md
	rm -rf uppsala turku

