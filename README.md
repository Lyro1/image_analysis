# Image Analysis
A little forensic tool to filter processes from an ISO image.

**Image Analysis** provides 3 scripts that allows you to perform the following actions:
- Get a clean and working setup of *Log2Timeline Plaso* on a Debian 9 running system.
- Generate the *.plaso* and the *.csv* files from an ISO image with `log2timeline.py` and `psort.py`.
- Get list of those files and filter them based on a trusted database of good files, using `nsrllookup`.

Usage
-
Image Analysis is a package of scripts that have been developped for **Debian 9 devices *only***. We do not guarantee that those scripts will work on any other OS. If you want to use those on other OS, you may have to modify the scripts. If you do so, please submit a *Pull Request* so that we can add your scripts to the repository and potentialy help other people.

The scripts provided by Image Analysis are autonomus. If your device does not have the required softwares, the scripts will automatically get them before executing their original process. This means that you don't have to worry about some prerequisites to run those scripts.

For a detailed explanation on each script usage, please read the [Wiki](https://github.com/Lyro1/image_analysis/wiki) pages of each scripts.

Usefull Links
-

- [Documentation](https://github.com/Lyro1/image_analysis/wiki)
- [Plaso](https://github.com/log2timeline/plaso)
- [NSRL Query](https://www.nist.gov/itl/ssd/software-quality-group/nsrl-download/rds-query-tools)
