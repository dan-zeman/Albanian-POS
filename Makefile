SHELL=/bin/bash

process:
	perl ./fix1.pl --sent_id_prefix trainshort train-short-new.conllu > dz-trainshort.conllu
	perl ./fix1.pl --sent_id_prefix trainlong train-withoutShort-new.conllu > dz-trainlong.conllu
	perl ./fix1.pl --sent_id_prefix dev albanian-all-devel-new.conllu > dz-dev.conllu
	perl ./fix1.pl --sent_id_prefix test albanian-all-test-new.conllu > dz-test.conllu
	cat dz-trainshort.conllu dz-trainlong.conllu dz-dev.conllu dz-test.conllu > all.conllu

