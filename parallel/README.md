# bat zip extractor
simple bat script to extract all zip files in a folder. it works in parallel processes, each process extracts a chunk of data.
## steps
- step 1: place the `parallel_bat_zip_extractor.bat` file in the folder that contains the zip archives.
- step 2: run the `parallel_bat_zip_extractor.bat` file. a lot of windows will open: master and workers, they will close automatically once the extraction is done.
- step 3: enjoy your extracted folders.
- additional step: each worker will process a chunk of 32 files, you can set the chunk size by modifying the line 5 of the script.
### additional comments
In this moment I am very sleepy, it is 01:50 am and I forgot to eat at dinner.