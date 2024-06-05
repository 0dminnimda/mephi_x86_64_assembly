make com O=0
make test | tee -a timing_raw.txt
make com O=1
make test | tee -a timing_raw.txt
make com O=2
make test | tee -a timing_raw.txt
make com O=3
make test | tee -a timing_raw.txt
make com O=fast
make test | tee -a timing_raw.txt
