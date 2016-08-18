To convert the exemplars stored in u8 subdirectory to TeX format just run

$ ./mktex.sh

The results are stored in tex subdirectory. For typesetting they should be
moved to tex subdirectory of the parent directory:

$ mv tex/* ../tex

The directory u8-notags contains intermediate stage files and can be safely
deleted if the conversion completed successfully:

$ rm -rf u8-notags
