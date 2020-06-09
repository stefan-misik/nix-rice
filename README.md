# *NIX Rice

This is script used to install my *NIX rice on different variants of system
configurations I use. This script can do following:

* Split the individual configuration files into system configuration variants
* Store and restore the configuration files
* Store and restore diffs of configuration files relative to some other
  configuration variant
* Show difference of the system files to the files stored in configuration
  variant
* Rebuild all diffs, in case some change is done in source variant


## Usage

```
Usage: ./rice.sh [-v] [-c VARIANT] [FILE1] [FILE2] ...
   OR: ./rice.sh -a [-v] [-c VARIANT] [-p PARENT] [FILE1] [FILE2] ...
   OR: ./rice.sh -h

  -h          Print this message
  -c VARIANT  Specify configuration variant (default is 'base')
  -a          Add the file into the rice
  -p PARENT   In combination with -a adds a difference of the
              file to the file in the configuration variant PARENT
  -l DEST     In combination with -c link all undefined files in
              DEST to files in VARIANT
  -d          Show diff of the files in the system to the specified
              configuration variant to the
  -r          Update all patches in all configuration variants
  -v          Verbose mode

If no files are listed after the last switch, the command will try
to do the operation on all files in specified configuration variant.

If -a switch is not specified, the files are installed from rice
collection into the system.
```

